extends RefCounted

const Run = preload("res://scripts/core/run_manager.gd")
const Map = preload("res://scripts/core/map_generator.gd")
const Party = preload("res://scripts/core/party_manager.gd")
const Content = preload("res://scripts/core/content.gd")
const Bag = preload("res://scripts/core/inventory_manager.gd")
const VERSION := 1
const PATH := "user://abyss_run.json"

static func save(run, path := PATH) -> Error:
	if run == null or not run.pending.is_empty() or not run.end_state.is_empty():
		return ERR_INVALID_DATA
	var data := {
		"version":VERSION,"seed":str(run.seed_value),"map":run.floors,"trail":run.trail,"region":run.region,
		"gold":run.gold,"bag":run.bag,"equipment":run.equipment,"events":run.events_seen,"wins":run.wins,"party":[]
	}
	for hero in run.party:
		data.party.append({"id":hero.id,"level":hero.level,"hp":hero.hp,"stress":hero.stress,"gear":hero.gear})
	var temp := path + ".tmp"
	var backup := path + ".bak"
	var file := FileAccess.open(temp,FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(data, "\t"))
	file.flush()
	var error := file.get_error()
	file.close()
	if error != OK:
		return error
	if FileAccess.file_exists(path):
		if _decode(Content.read(path)) != null:
			if FileAccess.file_exists(backup):
				error = DirAccess.remove_absolute(backup)
				if error != OK:
					return error
			error = DirAccess.rename_absolute(path,backup)
		else:
			error = DirAccess.remove_absolute(path)
		if error != OK:
			return error
	error = DirAccess.rename_absolute(temp,path)
	if error != OK and FileAccess.file_exists(backup):
		DirAccess.rename_absolute(backup,path)
	return error

static func load_run(path := PATH):
	for candidate in [path,path + ".bak"]:
		if FileAccess.file_exists(candidate):
			var run = _decode(Content.read(candidate))
			if run != null:
				return run
	return null

static func clear(path := PATH) -> void:
	for candidate in [path,path + ".bak",path + ".tmp"]:
		if FileAccess.file_exists(candidate):
			DirAccess.remove_absolute(candidate)

static func _decode(data: Dictionary):
	if data.get("version") != VERSION or data.get("region") != 1:
		return null
	if not data.get("seed") is String or not String(data.seed).is_valid_int():
		return null
	if not _whole(data.get("gold"),0,1000000) or not _whole(data.get("wins"),0,12):
		return null
	if not data.get("party") is Array or data.party.is_empty() or data.party.size() > Party.LIMIT:
		return null
	var heroes := Content.keys("heroes")
	var party := []
	for raw in data.party:
		if not raw is Dictionary or raw.get("id") not in heroes:
			return null
		var level: Variant = raw.get("level")
		if not _whole(level,1,16) or not _whole(raw.get("stress"),0,100) or not raw.get("gear") is Array or raw.gear.size() > 2:
			return null
		var types := []
		for id in raw.gear:
			if id not in Bag.GEAR:
				return null
			var type: String = Content.definition("items",id).type
			if type in types:
				return null
			types.append(type)
		var hero := Party.make(raw.id,"h%d" % party.size())
		for i in range(1,int(level)):
			Party.upgrade(hero)
		Bag.restore_gear(hero,raw.gear)
		if not _whole(raw.get("hp"),0,int(hero.max_hp)):
			return null
		hero.hp = int(raw.hp)
		hero.stress = int(raw.stress)
		party.append(hero)
	if Party.living(party).is_empty():
		return null
	if not data.get("trail") is Array or data.trail.is_empty() or data.trail.size() > 12 or data.trail[0] != "0/0":
		return null
	var run := Run.new(int(data.seed),party[0].id)
	if not data.get("map") is Array or data.map != JSON.parse_string(JSON.stringify(run.floors)):
		return null
	for i in range(1,data.trail.size()):
		if not data.trail[i] is String:
			return null
		var node := Map.find(run.floors,data.trail[i - 1])
		if data.trail[i] not in node.get("next",[]):
			return null
	if not data.get("equipment") is Array or data.equipment.size() > 512 or not data.get("events") is Array:
		return null
	if not data.equipment.all(func(id): return id in Bag.GEAR):
		return null
	var events := Content.keys("events")
	if data.events.size() > events.size() or not data.events.all(func(id): return id in events):
		return null
	if not data.get("bag") is Dictionary:
		return null
	for id in data.bag:
		if id not in Bag.CONSUMABLES or not _whole(data.bag[id],0,512):
			return null
		data.bag[id] = int(data.bag[id])
	run.party = party
	run.trail = data.trail
	run.gold = int(data.gold)
	run.wins = int(data.wins)
	run.bag = data.bag
	run.equipment = data.equipment
	run.events_seen = data.events
	return run

static func _whole(value: Variant, low: int, high: int) -> bool:
	if not (value is int or value is float):
		return false
	return value >= low and value <= high and int(value) == value

