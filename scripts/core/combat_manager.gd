extends RefCounted

signal narrated(message: String)
signal impacted(actor: String, target: String, number: String, kind: String)
signal finished(victory: bool)

const Content = preload("res://scripts/core/content.gd")
const Party = preload("res://scripts/core/party_manager.gd")
const Turns = preload("res://scripts/core/turn_manager.gd")
const AI = preload("res://scripts/core/enemy_ai.gd")
const STATUS := {"poison":"中毒","bleed":"流血","stun":"眩晕","shield":"护盾","buff":"强攻","weaken":"破防","regen":"回春"}

var heroes: Array
var enemies: Array
var rng := RandomNumberGenerator.new()
var round_number := 0
var phase := 1
var actor: Dictionary = {}
var result := ""
var queue: Array
var active_statuses: Dictionary = {}
var log_entries: Array[String] = []

func _init(party: Array, foes: Array, seed_value: int) -> void:
	heroes = party
	enemies = foes
	rng.seed = seed_value
	for unit in heroes:
		unit.statuses = {}
		unit.cooldowns = {}
		unit.turns = 0

func start() -> void:
	advance()

func is_player() -> bool:
	return not actor.is_empty() and String(actor.uid).begins_with("h")

func advance() -> void:
	actor = {}
	while result.is_empty():
		if _check_end():
			return
		if queue.is_empty():
			round_number += 1
			queue = Turns.order(heroes,enemies)
		actor = queue.pop_front()
		if actor.hp <= 0:
			continue
		actor.turns += 1
		for key in actor.cooldowns.keys():
			actor.cooldowns[key] -= 1
			if actor.cooldowns[key] <= 0:
				actor.cooldowns.erase(key)
		active_statuses = actor.statuses.duplicate(true)
		_periodic()
		if _check_end():
			return
		if actor.hp <= 0:
			actor.statuses.clear()
			continue
		if actor.statuses.has("stun"):
			_say("%s 因眩晕失去行动。" % actor.name)
			_expire()
			continue
		return

func targets(skill: Dictionary) -> Array:
	match skill.get("mode","enemy"):
		"self":
			return [actor]
		"ally", "allies":
			return Party.living(heroes if is_player() else enemies)
		_:
			return Party.living(enemies if is_player() else heroes)

func act_player(skill_id: String, target_uid := "") -> bool:
	return resolve_action(player_action(skill_id,target_uid))

func player_action(skill_id: String, target_uid: String) -> Dictionary:
	if not result.is_empty() or not is_player() or skill_id not in actor.skills or actor.cooldowns.has(skill_id):
		return {}
	var skill := Content.definition("skills",skill_id)
	return _prepare_action(skill,target_uid,skill_id)

func act_enemy() -> void:
	resolve_action(enemy_action())

func enemy_action() -> Dictionary:
	if is_player() or actor.is_empty() or not result.is_empty():
		return {}
	var action := AI.choose(actor, Party.living(enemies), Party.living(heroes), rng, phase)
	return _prepare_action(action[0],action[1].get("uid",""))

func _prepare_action(skill: Dictionary, target_uid: String, skill_id := "") -> Dictionary:
	var choices := targets(skill)
	if skill.mode in ["ally","enemy"]:
		choices = choices.filter(func(unit): return unit.uid == target_uid)
	return {} if choices.is_empty() else {
		"actor":actor.uid,"turn":actor.turns,"skill":skill,"skill_id":skill_id,"targets":choices
	}

func resolve_action(action: Dictionary, advance_turn := true) -> bool:
	if action.is_empty() or actor.is_empty() or actor.uid != action.actor or actor.turns != action.turn:
		return false
	var skill: Dictionary = action.skill
	_execute(skill,action.targets)
	if skill.has("cd") and not action.skill_id.is_empty():
		actor.cooldowns[action.skill_id] = int(skill.cd) + 1
	if advance_turn:
		advance()
	return true

func _execute(skill: Dictionary, choices: Array) -> void:
	_say("%s使用了「%s」。" % [actor.name,skill.name])
	for target in choices:
		if actor.hp <= 0:
			break
		var landed := true
		if skill.has("power"):
			landed = _attack(target,skill)
		if skill.has("heal"):
			_heal(target, int(skill.heal))
			if actor.passive == "mercy":
				Party.stress(actor,-4)
		if skill.get("cleanse",false):
			for key in ["poison","bleed","weaken","stun"]:
				target.statuses.erase(key)
			Party.stress(target,-12)
		if landed and target.hp > 0 and skill.has("effect"):
			_apply(target,skill.effect,int(skill.amount),int(skill.duration))
		if landed and skill.has("stress"):
			Party.stress(target,int(skill.stress))
	if skill.has("self_effect") and actor.hp > 0:
		_apply(actor,skill.self_effect,int(skill.self_amount),2)
	_expire()

func _attack(target: Dictionary, skill: Dictionary) -> bool:
	if rng.randf() < clampf(float(target.dodge),0.0,0.65):
		impacted.emit(actor.uid,target.uid,"闪避","miss")
		return false
	var damage := roundi(float(actor.attack) * float(skill.power)) + _strength(actor,"buff")
	var crit := float(actor.crit)
	if actor.stress >= 70:
		damage -= 2
	if actor.passive == "conduit" and skill.mode == "enemies":
		damage += 2
	if actor.passive == "scent" and target.statuses.has("bleed"):
		damage += 3
	if actor.passive == "focus" and target.statuses.has("weaken"):
		crit += 0.25
	var critical := rng.randf() < clampf(crit,0.0,0.8)
	if critical:
		damage = roundi(damage * 1.5)
	damage -= maxi(0,int(target.defense) - _strength(target,"weaken"))
	if target.passive == "grit" and target.hp * 2 < target.max_hp:
		damage -= 2
	damage = maxi(1,damage)
	var guard := mini(damage,_strength(target,"shield"))
	if guard > 0:
		target.statuses.shield.amount -= guard
		if target.statuses.shield.amount == 0:
			target.statuses.erase("shield")
		if target.passive == "riposte" and actor.uid != target.uid:
			_damage(actor,3,target.uid,"counter")
	if damage == guard:
		impacted.emit(actor.uid,target.uid,"格挡","shield")
	else:
		_damage(target,damage - guard,actor.uid,"critical" if critical else "hit")
		Party.stress(target,3 + (3 if critical else 0))
	return true

func _periodic() -> void:
	for key in ["poison","bleed","regen"]:
		if actor.hp <= 0 or not actor.statuses.has(key):
			continue
		var amount := _strength(actor,key)
		if key == "regen":
			_heal(actor,amount)
		else:
			_damage(actor,amount,actor.uid,key)

func _expire() -> void:
	for key in active_statuses:
		if actor.statuses.has(key) and actor.statuses[key].applied == active_statuses[key].applied:
			actor.statuses[key].duration -= 1
			if actor.statuses[key].duration <= 0:
				actor.statuses.erase(key)

func _apply(target: Dictionary, key: String, amount: int, duration: int) -> void:
	var old: Dictionary = target.statuses.get(key,{})
	var combined := amount
	if key in ["poison","bleed"]:
		combined = mini(12,int(old.get("amount",0)) + amount)
	elif key == "shield":
		combined = mini(32,int(old.get("amount",0)) + amount)
	else:
		combined = maxi(int(old.get("amount",0)),amount)
	target.statuses[key] = {"amount":combined,"duration":maxi(duration,int(old.get("duration",0))),"applied":int(old.get("applied",0)) + 1}
	if key == "shield":
		impacted.emit(actor.uid,target.uid,"+%d" % amount,"shield")

func _strength(unit: Dictionary, key: String) -> int:
	return int(unit.statuses.get(key,{}).get("amount",0))

func _damage(target: Dictionary, amount: int, from: String, kind: String) -> void:
	if target.hp <= 0:
		return
	target.hp = maxi(0,int(target.hp) - amount)
	impacted.emit(from,target.uid,str(amount),kind)
	if target.hp == 0:
		_say("%s倒下了。" % target.name)
		if String(target.uid).begins_with("h"):
			for ally in Party.living(heroes):
				Party.stress(ally,12)
	if target.ai == "boss" and target.hp > 0 and target.hp * 2 <= target.max_hp and phase == 1:
		phase = 2
		_say("无灯司祭裂茧，第二阶段「无灯之潮」开始！")
		target.attack += 2

func _heal(target: Dictionary, amount: int) -> void:
	var healed := Party.heal(target,amount)
	if healed > 0:
		impacted.emit(actor.uid,target.uid,"+%d" % healed,"heal")

func _check_end() -> bool:
	if not Party.living(heroes).is_empty() and not Party.living(enemies).is_empty():
		return false
	result = "defeat" if Party.living(heroes).is_empty() else "victory"
	actor = {}
	finished.emit(result == "victory")
	return true

func _say(message: String) -> void:
	log_entries.append(message)
	narrated.emit(message)

