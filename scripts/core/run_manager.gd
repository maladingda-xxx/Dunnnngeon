extends RefCounted

const Content = preload("res://scripts/core/content.gd")
const Map = preload("res://scripts/core/map_generator.gd")
const Party = preload("res://scripts/core/party_manager.gd")

var seed_value := 0
var floors: Array
var trail: Array = ["0/0"]
var party: Array
var gold := 24
var bag: Dictionary = {"ember":2}
var equipment: Array = []
var events_seen: Array = []
var region := 1
var pending: Dictionary = {}
var wins := 0
var end_state := ""

func _init(seed_number: int, hero_id: String) -> void:
	seed_value = seed_number
	floors = Map.generate(seed_value)
	party = [Party.make(hero_id,"h0")]

func current() -> Dictionary:
	return Map.find(floors,trail.back())

func enter(id: String) -> bool:
	if not end_state.is_empty() or not pending.is_empty() or id not in current().next:
		return false
	pending = Map.find(floors,id).duplicate(true)
	return not pending.is_empty()

func rng_for(domain: String, room := "") -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = ("%s|%s|%s" % [seed_value,room if not room.is_empty() else pending.get("id",trail.back()),domain]).hash()
	return rng

func foes(kind: String) -> Array:
	var rng := rng_for("foes")
	var depth := int(pending.floor)
	var ids := []
	match kind:
		"boss":
			ids = ["priest","acolyte"] if Party.living(party).size() > 1 else ["priest"]
		"elite":
			ids = [["wraith","viper"],["idol","acolyte"]][rng.randi_range(0,1)].duplicate()
		_:
			var pool := ["sentinel","bat","viper"] if depth <= 3 else ["sentinel","bat","viper","guard","acolyte"]
			for i in range(clampi(Party.living(party).size() - 1,1,3)):
				ids.append(pool[rng.randi_range(0,pool.size() - 1)])
	var result := []
	for i in range(ids.size()):
		var enemy := Party.make(ids[i],"e%d" % i,depth,"enemies")
		if kind == "boss" and Party.living(party).size() == 1 and i == 0:
			enemy.hp = 76
			enemy.max_hp = 76
		result.append(enemy)
	return result

func reward(kind: String) -> Dictionary:
	if pending.is_empty() or pending.has("reward"):
		return {}
	wins += 1
	var rng := rng_for("battle_reward")
	var earned := rng.randi_range(12,19) + int(pending.floor)
	if kind == "elite":
		earned += 20
	elif kind == "boss":
		earned += 40
	gold += earned
	for hero in Party.living(party):
		Party.heal(hero,4 + int(hero.level))
	var reward_data := {"gold":earned,"gear":"","item":""}
	if kind == "elite":
		reward_data.gear = ["talisman","axe","dawn"][rng.randi_range(0,2)]
		equipment.append(reward_data.gear)
	elif rng.randf() < 0.38:
		reward_data.item = ["ember","calm","salt"][rng.randi_range(0,2)]
		bag[reward_data.item] = int(bag.get(reward_data.item,0)) + 1
	pending.reward = reward_data
	return reward_data

func finish_room() -> bool:
	if pending.is_empty():
		return false
	trail.append(pending.id)
	if pending.kind == "boss":
		end_state = "victory"
	pending = {}
	return true

func recruit(id: String) -> bool:
	if party.size() >= Party.LIMIT or id not in Content.keys("heroes") or party.any(func(hero): return hero.id == id):
		return false
	party.append(Party.make(id,"h%d" % party.size()))
	return true

