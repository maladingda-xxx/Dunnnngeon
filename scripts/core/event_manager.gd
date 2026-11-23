extends RefCounted

const Content = preload("res://scripts/core/content.gd")
const Party = preload("res://scripts/core/party_manager.gd")
const Bag = preload("res://scripts/core/inventory_manager.gd")

static func mystery(run) -> String:
	var kinds := ["event","event","treasure","spring","battle","shop"]
	return kinds[run.rng_for("mystery").randi_range(0,kinds.size()-1)]

static func candidates(run) -> Array:
	var ids := Content.keys("heroes")
	ids = ids.filter(func(id): return not run.party.any(func(hero): return hero.id == id))
	var rng: RandomNumberGenerator = run.rng_for("recruit")
	var result := []
	while not ids.is_empty() and result.size() < 3:
		result.append(ids.pop_at(rng.randi_range(0,ids.size()-1)))
	return result

static func event(run) -> Dictionary:
	if run.pending.has("event_id"):
		var existing := Content.definition("events",run.pending.event_id)
		existing.id = run.pending.event_id
		return existing
	var ids := Content.keys("events")
	var pool := ids.filter(func(id): return id not in run.events_seen)
	if pool.is_empty():
		pool = ids
	var id: String = pool[run.rng_for("event").randi_range(0,pool.size()-1)]
	var chosen := Content.definition("events",id)
	run.pending.event_id = id
	chosen.id = id
	return chosen

static func choose(run, event_data: Dictionary, option: int) -> String:
	if run.pending.is_empty() or run.pending.has("resolution") or option < 0 or option >= event_data.choices.size():
		return ""
	var action: Dictionary = event_data.choices[option]
	var cost := int(action.get("cost",0))
	if run.gold < cost:
		return ""
	run.gold -= cost
	var passed: bool = run.rng_for("choice_%d" % option).randf() < float(action.get("chance",1.0))
	apply(run,action.effects if passed else action.get("failure",{}))
	if event_data.id not in run.events_seen:
		run.events_seen.append(event_data.id)
	run.pending.resolution = action.result if passed else action.fail_text
	return run.pending.resolution

static func apply(run, effects: Dictionary) -> void:
	var living := Party.living(run.party)
	for hero in living:
		if effects.has("heal"):
			Party.heal(hero,int(effects.heal))
		if effects.has("stress"):
			Party.stress(hero,int(effects.stress))
	if not living.is_empty():
		var lead: Dictionary = living[0]
		if effects.has("hurt"):
			lead.hp = maxi(1,int(lead.hp)-int(effects.hurt))
		if effects.has("lead_stress"):
			Party.stress(lead,int(effects.lead_stress))
	run.gold = maxi(0,run.gold + int(effects.get("gold",0)))
	if effects.has("item"):
		for i in range(int(effects.get("quantity",1))):
			Bag.add(run,effects.item)

static func treasure(run) -> Array:
	var rng: RandomNumberGenerator = run.rng_for("treasure")
	var depth := int(run.pending.floor)
	var pool := Bag.GEAR.slice(0,3 if depth < 4 else (6 if depth < 8 else 8))
	return [pool[rng.randi_range(0,pool.size()-1)],Bag.CONSUMABLES[rng.randi_range(0,2)]]

static func stock(run) -> Array:
	var rng: RandomNumberGenerator = run.rng_for("shop")
	var pool := Bag.GEAR.duplicate()
	var items := Bag.CONSUMABLES.duplicate()
	for i in range(3):
		items.append(pool.pop_at(rng.randi_range(0,pool.size()-1)))
	return items

