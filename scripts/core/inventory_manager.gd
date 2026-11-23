extends RefCounted

const Content = preload("res://scripts/core/content.gd")
const Party = preload("res://scripts/core/party_manager.gd")
const CONSUMABLES := ["ember","calm","salt"]
const GEAR := ["blade","knife","seal","talisman","codex","axe","lantern","dawn"]

static func add(run, id: String) -> void:
	if id in CONSUMABLES:
		run.bag[id] = int(run.bag.get(id,0)) + 1
	elif id in GEAR:
		run.equipment.append(id)

static func buy(run, id: String) -> bool:
	if id not in CONSUMABLES and id not in GEAR:
		return false
	var cost := int(Content.definition("items",id).cost)
	if run.gold < cost:
		return false
	run.gold -= cost
	add(run,id)
	return true

static func equip(run, hero: Dictionary, id: String) -> bool:
	if hero.hp <= 0 or id not in run.equipment or id not in GEAR:
		return false
	var item := Content.definition("items",id)
	for existing in hero.gear.duplicate():
		if Content.definition("items",existing).type == item.type:
			unequip(run,hero,existing)
	run.equipment.erase(id)
	hero.gear.append(id)
	_adjust(hero,item,1)
	return true

static func unequip(run, hero: Dictionary, id: String) -> bool:
	if hero.hp <= 0 or id not in hero.gear:
		return false
	hero.gear.erase(id)
	run.equipment.append(id)
	_adjust(hero,Content.definition("items",id),-1)
	return true

static func restore_gear(hero: Dictionary, gear: Array) -> void:
	for id in gear:
		hero.gear.append(id)
		_adjust(hero,Content.definition("items",id),1)

static func use(run, hero: Dictionary, id: String) -> bool:
	if hero.hp <= 0 or id not in CONSUMABLES or int(run.bag.get(id,0)) <= 0:
		return false
	var item := Content.definition("items",id)
	var affected := false
	if item.has("heal"):
		affected = Party.heal(hero,int(item.heal)) > 0
	if item.has("stress") and hero.stress > 0:
		Party.stress(hero,int(item.stress))
		affected = true
	if item.get("cleanse",false):
		for status in ["poison","bleed","stun","weaken"]:
			affected = hero.statuses.erase(status) or affected
	if affected:
		run.bag[id] -= 1
	return affected

static func _adjust(hero: Dictionary, item: Dictionary, polarity: int) -> void:
	for stat in item.stats:
		var value: Variant = item.stats[stat]
		if stat in ["crit","dodge"]:
			hero[stat] += float(value) * polarity
		else:
			hero[stat] += int(value) * polarity
		if stat == "max_hp" and hero.hp > 0:
			hero.hp = clampi(int(hero.hp) + int(value)*polarity,1,hero.max_hp)

