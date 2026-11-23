extends SceneTree

const Map = preload("res://scripts/core/map_generator.gd")
const Run = preload("res://scripts/core/run_manager.gd")
const Combat = preload("res://scripts/core/combat_manager.gd")
const Party = preload("res://scripts/core/party_manager.gd")
const Content = preload("res://scripts/core/content.gd")
const Assets = preload("res://scripts/core/asset_catalog.gd")
const CombatView = preload("res://scripts/ui/combat_view.gd")
const Rooms = preload("res://scripts/core/event_manager.gd")
const Bag = preload("res://scripts/core/inventory_manager.gd")
const Save = preload("res://scripts/core/save_manager.gd")
const QA_SAVE := "user://abyss_regression.json"
const Main = preload("res://scenes/main/main.tscn")

var failures := 0
var assertions := 0

func _initialize() -> void:
	call_deferred("_run_tests")

func _expect(condition: bool, detail: String) -> void:
	assertions += 1
	if not condition:
		failures += 1
		push_error(detail)

func _run_tests() -> void:
	_atlas_validity()
	_unit_art_validity()
	_map_invariants()
	_combat_rules()
	_status_duration()
	_storage_and_gear()
	_full_seeded_run()
	await _combat_animation()
	await _ui_loop()
	await _room_screens()
	Save.clear(QA_SAVE)
	print("Abyss Expedition: %d assertions, %d failures." % [assertions,failures])
	quit(1 if failures > 0 else 0)

func _atlas_validity() -> void:
	var entries := Content.read("res://data/atlas.json")
	_expect(entries.size() == 278,"Unexpected number of source images")
	for id in entries:
		var texture := Assets.sprite(id)
		_expect(texture != null and texture.atlas != null,"Missing texture " + id)
		if texture != null and texture.atlas != null:
			var source := Rect2(Vector2.ZERO,texture.atlas.get_size())
			_expect(texture.region.has_area() and source.encloses(texture.region),"Out-of-bounds sprite region " + id)

func _unit_art_validity() -> void:
	var unit_art := Content.read("res://data/unit_art.json")
	for book in ["heroes","enemies"]:
		for key in Content.keys(book):
			var id: String = Content.definition(book,key).sprite
			_expect(unit_art.has(id),"Missing presentation asset for " + key)
			for frame in range(Assets.frame_count(id)):
				var texture := Assets.sprite(id,frame)
				var detail := "%s frame %d" % [id,frame]
				_expect(texture != null and texture.atlas != null,"Missing " + detail)
				if texture != null and texture.atlas != null:
					var source := Rect2(Vector2.ZERO,texture.atlas.get_size())
					_expect(texture.region.has_area() and source.encloses(texture.region),"Out-of-bounds " + detail)
					if unit_art.get(id,{}).has("portrait_region"):
						var portrait := Assets.sprite(id,frame,true)
						_expect(portrait.region.has_area() and texture.region.encloses(portrait.region),"Out-of-bounds portrait " + detail)
			var idle := Assets.sprite(id)
			var clips: Dictionary = unit_art.get(id,{}).get("clips",{})
			for clip in clips:
				var source_path: String = clips[clip].get("source",idle.atlas.resource_path)
				var expected_size := idle.get_size()
				if clips[clip].has("region"):
					expected_size = Vector2(clips[clip].region[2],clips[clip].region[3])
				_expect(Assets.release_frame(id,clip) in range(Assets.frame_count(id,clip)),"Invalid release frame " + id + " " + clip)
				for frame in range(Assets.frame_count(id,clip)):
					var texture := Assets.sprite(id,frame,false,clip)
					var detail := "%s %s frame %d" % [id,clip,frame]
					_expect(texture != null and texture.atlas != null,"Missing " + detail)
					if texture != null and texture.atlas != null:
						var source := Rect2(Vector2.ZERO,texture.atlas.get_size())
						_expect(source.encloses(texture.region) and texture.get_size() == expected_size,"Misaligned " + detail)
						_expect(texture.atlas.resource_path == source_path,"Wrong sprite sheet " + detail)

func _map_invariants() -> void:
	for seed_number in range(160):
		var floors := Map.generate(seed_number)
		_expect(floors == Map.generate(seed_number),"Unstable map seed %d" % seed_number)
		_expect(floors.size() == 13 and floors.back()[0].kind == "boss","Invalid region shape")
		var sources := {"0/0":true}
		for depth in range(floors.size()):
			var next := {}
			for room in floors[depth]:
				_expect(sources.has(room.id),"Unreachable room " + room.id)
				_expect(depth == floors.size()-1 or not room.next.is_empty(),"Dead end " + room.id)
				for edge in room.next:
					var target := Map.find(floors,edge)
					_expect(not target.is_empty() and target.floor == depth + 1,"Invalid edge " + edge)
					_expect(not (room.kind == "elite" and target.kind == "elite"),"Consecutive elites")
					next[edge] = true
			sources = next

func _combat_rules() -> void:
	var state := Run.new(15,"rogue")
	_expect(not state.enter("12/0"),"Gate could jump to boss")
	_expect(state.enter(state.current().next[0]),"Cannot enter first node")
	_expect(not state.enter(state.current().next[0]),"Can enter a second concurrent room")
	var foes := state.foes("battle")
	foes[0].dodge = 0.0
	foes[0].hp = 6
	var model := Combat.new(state.party,foes,4)
	model.start()
	_expect(not model.act_player("strike","e999"),"Invalid target accepted")
	_expect(model.act_player("bleed","e0"),"Valid action rejected")
	_expect(model.result == "victory" and foes[0].turns == 0,"Dead foe gained a turn")
	var coins := state.gold
	_expect(not state.reward("battle").is_empty() and state.gold > coins,"No battle reward")
	coins = state.gold
	_expect(state.reward("battle").is_empty() and state.gold == coins,"Reward duplicated")
	_expect(state.finish_room() and not state.finish_room(),"Room committed twice")
	for id in ["mage","warrior","cleric"]:
		_expect(state.recruit(id),"Recruitment rejected")
	_expect(not state.recruit("ranger"),"Party capacity exceeded")
	var strong := Party.make("warrior","h0")
	var boss := Party.make("priest","e0",12,"enemies")
	strong.attack = 80
	boss.dodge = 0.0
	var final := Combat.new([strong],[boss],4)
	final.start()
	final.act_player("strike","e0")
	_expect(final.phase == 2 and final.result.is_empty(),"Boss phase transition was skipped")
	final.act_enemy()
	final.act_player("strike","e0")
	_expect(final.result == "victory","Boss combat did not end")
	var fragile := Party.make("knight","h0")
	fragile.hp = 1
	fragile.dodge = 0.0
	var loss := Combat.new([fragile],[Party.make("priest","e0",12,"enemies")],14)
	loss.start()
	loss.act_enemy()
	_expect(loss.result == "defeat","Total party defeat did not end combat")

func _combat_animation() -> void:
	for hero_id in ["warrior","ranger"]:
		var hero := Party.make(hero_id,"h0")
		hero.crit = 1.0
		var guard := Party.make("guard","e0",1,"enemies")
		guard.dodge = 0.0
		guard.hp = 1
		var model := Combat.new([hero],[guard],4)
		var combat := CombatView.new()
		root.add_child(combat)
		combat.setup(model,"测试遭遇",1)
		await create_timer(0.4).timeout
		var actor: Dictionary = combat.units.h0
		var victim: Dictionary = combat.units.e0
		var melee: bool = hero_id == "warrior"
		var impact_seen := [false]
		model.impacted.connect(func(_from, _to, _value, _kind):
			impact_seen[0] = true
			_expect(actor.art.texture.atlas.resource_path.ends_with("Warrior_Attack1.png" if melee else "Archer_Shoot.png"),"Impact occurred outside the attack animation")
			_expect(actor.rig.position.x > actor.home.x+200.0 if melee else actor.rig.position == actor.home,"Attack occurred at the wrong position")
		)
		combat._skill("strike" if melee else "arrow")
		combat._target("e0")
		_expect(guard.hp == 1 and combat.busy and victim.bar.value == 1,"Applied damage during windup")
		if melee:
			_expect(actor.running and actor.art.texture.atlas.resource_path.ends_with("Warrior_Run.png"),"Melee did not start with a native run")
		else:
			_expect(not actor.running and actor.art.texture.atlas.resource_path.ends_with("Archer_Shoot.png"),"Ranged attack did not shoot from its slot")
		for attempt in range(16):
			if not actor.active and model.result == "victory":
				break
			await create_timer(0.2).timeout
		_expect(impact_seen[0] and guard.hp == 0 and victim.bar.value == 0,"Animated hit did not update HP")
		_expect(victim.dying and absf(victim.pose.rotation) > 1.0,"Unit without death art did not fall")
		_expect(actor.rig.position == actor.home and not actor.active,"Attacker did not return to its slot")
		combat.queue_free()

func _ui_loop() -> void:
	var game := Main.instantiate()
	game.save_path = QA_SAVE
	root.add_child(game)
	await process_frame
	_expect(game.view == "title","Launch did not open menu")
	game._show_choice()
	game._choose_hero("warrior")
	game.seed_field.text = "151"
	game._begin()
	await process_frame
	_expect(game.view == "map","Character selection did not open map")
	game._enter(game.run.current().next[0])
	await process_frame
	_expect(game.view == "combat","Map did not open combat")
	if game.view != "combat":
		game.queue_free()
		return
	var combat = game.combat_view
	for attempt in range(18):
		await create_timer(0.62).timeout
		if game.view != "combat":
			break
		if combat.battle.is_player():
			var victim: Array = Party.living(combat.battle.enemies)
			if not victim.is_empty():
				combat._skill("strike")
				combat._target(victim[0].uid)
	await create_timer(1.1).timeout
	_expect(game.view == "reward","Combat did not open reward")
	if game.view == "reward":
		game._finish_room()
		await process_frame
		_expect(game.view == "map" and game.run.trail.size() == 2,"Reward did not return to map")
	if game.view == "map":
		var saved_gold: int = game.run.gold
		game.run.party[0].hp -= 6
		game._pack()
		_expect(paused and game.overlay != null,"Backpack did not pause input")
		game._consume("ember")
		_expect(game.run.bag.ember == 1 and game.run.party[0].hp == game.run.party[0].max_hp,"Backpack did not use a healing item")
		game._close_modal()
		_expect(not paused,"Closing backpack did not resume play")
		game._show_title()
		_expect(game.run != null and game.run.trail.size() == 2 and game.run.gold == saved_gold,"Main menu did not restore checkpoint")
	game.audio.stop()
	await create_timer(0.25).timeout
	game.queue_free()
	await process_frame


func _status_duration() -> void:
	var hero := Party.make("rogue","h0")
	var enemy := Party.make("guard","e0",5,"enemies")
	hero.dodge = 0.0
	enemy.dodge = 0.0
	var model := Combat.new([hero],[enemy],733)
	model.start()
	_expect(model.act_player("bleed","e0"),"Bleed action rejected")
	_expect(enemy.statuses.bleed.duration == 2,"Bleed missing before target action")
	model.act_enemy()
	_expect(enemy.statuses.bleed.duration == 1,"First tick did not decrement duration")
	_expect(not model.act_player("bleed","e0"),"Cooldown failed")
	model.act_player("strike","e0")
	if enemy.hp > 0:
		model.act_enemy()
	_expect(not enemy.statuses.has("bleed"),"Bleed did not expire")

func _storage_and_gear() -> void:
	Save.clear(QA_SAVE)
	var run := Run.new(9271,"warrior")
	var hero: Dictionary = run.party[0]
	var start_max: int = hero.max_hp
	Bag.add(run,"seal")
	_expect(Bag.equip(run,hero,"seal") and hero.max_hp == start_max + 7,"Equip did not change stats")
	_expect(Bag.unequip(run,hero,"seal") and hero.max_hp == start_max,"Unequip did not restore base stats")
	Bag.equip(run,hero,"seal")
	Party.upgrade(hero)
	hero.hp -= 9
	Party.stress(hero,30)
	_expect(Bag.use(run,hero,"ember") and run.bag.ember == 1,"Potion did not apply")
	_expect(not Bag.use(run,hero,"ember") and run.bag.ember == 1,"Potion consumed at full HP")
	_expect(run.enter(run.current().next[0]),"Could not prepare pending save")
	_expect(Save.save(run,QA_SAVE) == ERR_INVALID_DATA,"Saved during a room")
	run.finish_room()
	run.recruit("knight")
	run.events_seen = ["bell"]
	var written := Save.save(run,QA_SAVE)
	_expect(written == OK,"Checkpoint was not written")
	var restored = Save.load_run(QA_SAVE)
	_expect(restored != null,"Valid save was rejected")
	if restored != null:
		_expect(restored.floors == run.floors and restored.trail == run.trail,"Map roundtrip changed")
		_expect(restored.party == run.party and restored.bag == run.bag and restored.events_seen == run.events_seen,"Party or progression roundtrip changed")
	run.gold += 6
	_expect(Save.save(run,QA_SAVE) == OK,"Checkpoint overwrite failed")
	var corrupted := FileAccess.open(QA_SAVE,FileAccess.WRITE)
	corrupted.store_string('{"broken":')
	corrupted.close()
	restored = Save.load_run(QA_SAVE)
	_expect(restored != null and restored.gold == run.gold - 6,"Damaged checkpoint did not fall back")
	Save.clear(QA_SAVE)

func _full_seeded_run() -> void:
	var first := _play_run(151)
	var second := _play_run(151)
	_expect(first == second,"Matching seed and choices diverged")
	_expect(first.end == "victory" and first.floors == 12,"Unmodified run failed to reach victory: %s" % str(first))
	_expect(first.phase == 2,"Unmodified run missed phase two")

func _play_run(seed_value: int) -> Dictionary:
	var run := Run.new(seed_value,"mage")
	var boss_phase := 0
	while run.end_state.is_empty():
		var rooms: Array = run.current().next.map(func(id): return Map.find(run.floors,id))
		rooms.sort_custom(func(a,b): return _room_rank(a.kind,run.party.size()) < _room_rank(b.kind,run.party.size()))
		run.enter(rooms[0].id)
		var kind: String = run.pending.kind
		if kind == "mystery":
			kind = Rooms.mystery(run)
		match kind:
			"battle","elite","boss":
				var result := _play_combat(run,kind)
				if kind == "boss":
					boss_phase = result.phase
				if result.result != "victory":
					run.end_state = "defeat"
					break
				run.reward(kind)
			"recruit":
				if run.party.size() < 4:
					var ids := Rooms.candidates(run)
					var preferred := ["knight","cleric","ranger","rogue","warrior"]
					ids.sort_custom(func(a,b): return preferred.find(a) < preferred.find(b))
					run.recruit(ids[0])
			"rest":
				if Party.living(run.party).any(func(hero): return hero.hp * 2 < hero.max_hp):
					Rooms.apply(run,{"heal":19})
				else:
					Party.upgrade(Party.living(run.party)[0])
			"spring":
				Rooms.apply(run,{"heal":14})
			"treasure":
				Bag.add(run,Rooms.treasure(run)[0])
			"shop":
				if run.gold >= 13:
					Bag.buy(run,"ember")
			"event":
				var data := Rooms.event(run)
				Rooms.choose(run,data,1)
		for id in run.equipment.duplicate():
			var item := Content.definition("items",id)
			for hero in Party.living(run.party):
				if not hero.gear.any(func(equipped): return Content.definition("items",equipped).type == item.type):
					Bag.equip(run,hero,id)
					break
		run.finish_room()
	return {"end":run.end_state,"floors":run.trail.size()-1,"phase":boss_phase,"gold":run.gold,"heroes":Party.living(run.party).map(func(h): return h.hp),"trail":run.trail}

func _room_rank(kind: String, party_size: int) -> int:
	if kind == "recruit" and party_size < 4:
		return 0
	return ["rest","spring","treasure","shop","event","recruit","battle","mystery","elite","boss"].find(kind) + 1

func _play_combat(run, kind: String) -> Dictionary:
	var battle := Combat.new(run.party,run.foes(kind),run.rng_for("combat").seed)
	battle.start()
	for action in range(160):
		if not battle.result.is_empty():
			break
		if not battle.is_player():
			battle.act_enemy()
			continue
		var options := Party.living(battle.enemies)
		options.sort_custom(func(a,b): return a.hp < b.hp)
		var allies := Party.living(run.party)
		allies.sort_custom(func(a,b): return float(a.hp) / a.max_hp < float(b.hp) / b.max_hp)
		var wound: Dictionary = allies[0]
		if wound.hp * 2 < wound.max_hp:
			Bag.use(run,wound,"ember")
		var actor := battle.actor
		var id: String = actor.skills[0]
		for skill in actor.skills.slice(1):
			if actor.cooldowns.has(skill):
				continue
			if skill in ["mend","cleanse"] and wound.hp > wound.max_hp - 12:
				continue
			if skill in ["ward","brace"]:
				continue
			if skill in ["nova","cleave","volley"] and options.size() == 1:
				continue
			id = skill
			break
		var spec := Content.definition("skills",id)
		battle.act_player(id,wound.uid if spec.mode == "ally" else options[0].uid)
	return {"phase":battle.phase,"result":battle.result}

func _room_screens() -> void:
	var game := Main.instantiate()
	game.save_path = QA_SAVE
	root.add_child(game)
	await process_frame
	var kinds := ["recruit","spring","rest","treasure","shop","event","mystery","elite","boss"]
	for kind in kinds:
		var route := _find_route(kind)
		_expect(not route.is_empty(),"Could not find route to " + kind)
		if route.is_empty():
			continue
		game.run = Run.new(route.seed,"warrior")
		game.run.trail = route.trail
		var first: Dictionary = game.run.party[0]
		first.hp -= 8
		first.stress = 14
		game._show_map()
		game._enter(route.id)
		await process_frame
		_expect(game.view == "combat" if kind in ["elite","boss"] else game.view in ["room","combat"],"Unexpected screen for " + kind)
		if game.view == "combat":
			if kind == "boss":
				var boss: Dictionary = game.combat_view.battle.enemies[0]
				boss.dodge = 0.0
				game.combat_view.battle.actor.attack = 100
				await create_timer(0.7).timeout
				if game.combat_view.battle.is_player():
					game.combat_view._skill("strike")
					game.combat_view._target(boss.uid)
				for attempt in range(10):
					if game.view != "combat":
						break
					await create_timer(0.2).timeout
				_expect(game.view == "reward","Boss UI did not show reward")
				if game.view == "reward":
					game._finish_room()
					_expect(game.view == "end" and game.run.end_state == "victory","Boss reward did not show victory ending")
			continue
		var choice := {"recruit":"招募","spring":"为全队疗伤","rest":"训练选中成员","treasure":"离开房间","shop":"余烬药剂","event":"","mystery":"离开房间"}[kind] as String
		var coin_delta: int = game.run.gold
		for button in game.screen.find_children("*","Button",true,false):
			if not button.disabled and (button.text.begins_with(choice) if not choice.is_empty() else button.get_parent().name.begins_with("@Control")) and button.text not in ["暂停","离开房间"]:
				button.pressed.emit()
				break
		if kind == "shop":
			_expect(game.run.gold < coin_delta and game.run.bag.ember == 3,"Shop purchase did not affect inventory")
		if kind == "recruit":
			_expect(game.run.party.size() == 2,"Recruit button did not add member")
		if kind == "spring":
			_expect(first.hp == first.max_hp,"Spring did not heal")
		if kind == "rest":
			_expect(first.level == 2,"Camp did not level member")
		if kind == "event":
			_expect(game.run.events_seen.size() == 1,"Event choice was not recorded")
		for button in game.screen.find_children("*","Button",true,false):
			if button.text.begins_with("返回路线") or button.text == "离开房间":
				button.pressed.emit()
				break
		_expect(game.view == "map" and game.run.trail.back() == route.id,"Room did not return to map: " + kind)
	game.run = Run.new(151,"knight")
	game.run.party[0].hp = 1
	game.run.party[0].dodge = 0.0
	game._enter(game.run.current().next[0])
	await create_timer(2.3).timeout
	_expect(game.view == "end" and game.run.end_state == "defeat","Defeat UI did not show ending")
	game.audio.stop()
	await create_timer(0.25).timeout
	game.queue_free()
	await process_frame

func _find_route(kind: String) -> Dictionary:
	for seed_value in range(12):
		var layers := Map.generate(seed_value)
		var paths := {"0/0":["0/0"]}
		for layer in layers:
			for room in layer:
				if room.kind == kind:
					var past: Array = paths[room.id].duplicate()
					past.pop_back()
					return {"seed":seed_value,"trail":past,"id":room.id}
				for next in room.next:
					var past: Array = paths[room.id].duplicate()
					past.append(next)
					paths[next] = past
	return {}
