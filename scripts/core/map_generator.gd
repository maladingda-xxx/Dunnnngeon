extends RefCounted

const Content = preload("res://scripts/core/content.gd")

static func generate(seed_value: int) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var config := Content.read("res://data/region.json")
	var floors: Array = [[{"id":"0/0","floor":0,"lane":0,"kind":"gate","next":[]}]]
	var last := int(config.floors)
	for depth in range(1, last + 1):
		var count := 1 if depth == last else rng.randi_range(2, 4)
		var layer: Array = []
		var required: Array = config.guaranteed.get(str(depth), [])
		var shift := rng.randi_range(0, count - 1)
		var mysteries := 0
		for lane in range(count):
			var slot := posmod(lane - shift, count)
			var kind := "boss"
			if depth < last:
				kind = _roll_kind(rng, config, depth, mysteries)
				if depth == 1:
					kind = "battle"
				elif slot < required.size():
					kind = required[slot]
			if kind == "mystery":
				mysteries += 1
			layer.append({"id":"%d/%d" % [depth,lane],"floor":depth,"lane":lane,"kind":kind,"next":[]})
		var previous: Array = floors.back()
		for i in range(previous.size()):
			var center := 0.5 if previous.size() == 1 else float(i) / (previous.size() - 1)
			var preferred := roundi(center * (count - 1))
			_connect(previous[i],layer[preferred])
			if count > 1:
				var alternate := preferred + (-1 if preferred == count - 1 else 1)
				_connect(previous[i],layer[alternate])
			if depth == 1:
				for room in layer:
					_connect(previous[i],room)
			elif depth in [2, 4, 6, 8, 10, 11]:
				for room in layer:
					if room.kind in ["recruit","spring","rest"] and previous[i].next.size() < 3:
						_connect(previous[i],room)
		for room in layer:
			if not previous.any(func(parent): return room.id in parent.next):
				var nearest := roundi(float(room.lane) * (previous.size() - 1) / maxi(1,count - 1))
				_connect(previous[nearest],room)
		floors.append(layer)
	return floors

static func _connect(parent: Dictionary, room: Dictionary) -> void:
	if parent.kind == "elite" and room.kind == "elite":
		room.kind = "battle"
	if room.id not in parent.next:
		parent.next.append(room.id)

static func _roll_kind(rng: RandomNumberGenerator, config: Dictionary, depth: int, mysteries: int) -> String:
	var weights: Dictionary = config.weights.duplicate()
	if depth < int(config.minimum_elite_floor):
		weights.erase("elite")
	if mysteries >= int(config.maximum_mysteries):
		weights.erase("mystery")
	var total := 0
	for weight in weights.values():
		total += int(weight)
	var roll := rng.randi_range(1,total)
	for kind in weights:
		roll -= int(weights[kind])
		if roll <= 0:
			return kind
	return "battle"

static func find(floors: Array, id: String) -> Dictionary:
	var chunks := id.split("/")
	if chunks.size() != 2 or not chunks[0].is_valid_int() or not chunks[1].is_valid_int():
		return {}
	var floor_index := int(chunks[0])
	var lane := int(chunks[1])
	if floor_index < 0 or floor_index >= floors.size() or lane < 0 or lane >= floors[floor_index].size():
		return {}
	return floors[floor_index][lane]

