extends Control

signal resolved(victory: bool)
signal pack_requested
signal sound(name: String)

const UI = preload("res://scripts/ui/ui.gd")
const Content = preload("res://scripts/core/content.gd")
const Assets = preload("res://scripts/core/asset_catalog.gd")
const Combat = preload("res://scripts/core/combat_manager.gd")
const CombatFX = preload("res://scripts/ui/combat_effects.gd")
const RUN_FRAME_TIME := 0.043

var field: Node2D
var effects: CombatFX
var shake: Tween
var impact_level := 0
var action_motion := ""

var battle
var units: Dictionary
var commands: Control
var timeline: Control
var turn_label: Label
var phase_label: Label
var log_label: Label
var active_label: Label
var status_label: Label
var prompt: Label
var skill_keys: Array[String] = []
var selected := ""
var busy := true
var clock := 0.0
var item_turn := ""

func setup(model, room_name: String, depth: int) -> void:
	battle = model
	battle.impacted.connect(_impact)
	battle.narrated.connect(_narrate)
	UI.panel(self,40,91,298,63,Color("#111822de"))
	UI.label(self,room_name,57,97,256,26,20,UI.PALE,"display")
	UI.label(self,"楼层 %02d  /  盐蚀地窟" % depth,57,124,261,23,12,UI.GOLD)
	UI.panel(self,1009,96,230,48,Color("#111822de"))
	phase_label = UI.label(self,"",1022,96,204,48,15,UI.TEAL,"body",HORIZONTAL_ALIGNMENT_CENTER)
	UI.rule(self,424,110,432,1,Color("#797064"))
	UI.rule(self,518,106,244,9,Color("#171f2a"))
	turn_label = UI.label(self,"",524,94,232,34,16,UI.GOLD,"body",HORIZONTAL_ALIGNMENT_CENTER)
	timeline = Control.new()
	timeline.mouse_filter = MOUSE_FILTER_IGNORE
	UI.at(self,timeline,388,130,504,62)
	UI.label(self,"远征队",46,172,110,24,13,UI.TEAL)
	UI.label(self,"潮骸",1120,172,110,24,13,UI.RED,"body",HORIZONTAL_ALIGNMENT_RIGHT)
	field = Node2D.new()
	add_child(field)
	for i in range(battle.heroes.size()):
		if battle.heroes[i].hp > 0:
			_unit(battle.heroes[i],456-i*112,true)
	var giant: bool = battle.enemies[0].id in ["idol","priest"]
	for i in range(battle.enemies.size()):
		var enemy: Dictionary = battle.enemies[i]
		var x := (859 if i == 0 else 1092) if giant else 789+i*153
		_unit(enemy,x,false,giant and i == 0)
	for spot in [96,1184]:
		UI.sprite(field,"Scenery_16",spot,417,0.75,Color("#d1aa80"))
	for spot in [19,1256]:
		UI.sprite(field,"Scenery_20",spot,423,0.55,Color("#609093"))
	effects = CombatFX.new()
	field.add_child(effects)
	UI.frame(self,40,497,718,163)
	UI.frame(self,774,497,466,163)
	UI.rule(self,58,537,683)
	UI.rule(self,793,537,428)
	active_label = UI.label(self,"",59,504,235,28,17,UI.PALE)
	status_label = UI.label(self,"",288,506,440,26,12,UI.TEAL,"body",HORIZONTAL_ALIGNMENT_RIGHT)
	UI.label(self,"遭遇记录",796,505,290,26,16,UI.GOLD)
	log_label = UI.text_block(self,"敌群挡住了去路。",797,550,424,97,14)
	commands = Control.new()
	commands.mouse_filter = MOUSE_FILTER_IGNORE
	UI.at(self,commands,0,0,1280,720)
	prompt = UI.label(self,"",43,668,1000,30,14,UI.MUTED)
	UI.button(self,"打开背包",1086,669,153,32,func(): pack_requested.emit())
	battle.start()
	_sync()
	_continue_later()

func _unit(data: Dictionary, cx: int, friendly: bool, large := false) -> void:
	UI.rule(field,cx-39,413,78,5,Color("#0b1019"))
	UI.rule(field,cx-29,418,58,3,Color("#0b1019"))
	var marker := UI.rule(self,cx-43,424,86,2,Color.TRANSPARENT)
	var bounds := Vector2(110,225) if friendly else Vector2(137,151)
	if large:
		bounds = Vector2(246,212)
	var hover := 45.0 if data.id == "bat" else (14.0 if data.id == "wraith" else 0.0)
	var light := Color("#dbe7ef") if friendly else Color("#ece0e5")
	var home := Vector2(cx,419-hover)
	var rig := Node2D.new()
	rig.position = home
	field.add_child(rig)
	var pose := Node2D.new()
	rig.add_child(pose)
	var art := UI.unit_sprite(pose,data.sprite,0,0,bounds,light,not friendly)
	if art.material == null:
		art.material = UI.unit_material()
	var hp := UI.bar(self,cx-46,436,92,7,Color("#9d4d4c") if friendly else Color("#b95348"))
	var stress := UI.bar(self,cx-46,446,92,4,Color("#628b91"))
	stress.visible = friendly
	var name_label := UI.label(self,data.name,cx-72,453,144,26,13,UI.PALE,"body",HORIZONTAL_ALIGNMENT_CENTER)
	var number := UI.label(self,"",cx-72,475,144,16,11,UI.MUTED,"body",HORIZONTAL_ALIGNMENT_CENTER)
	var hit_button := Button.new()
	for style_name in ["normal","hover","pressed","disabled","focus"]:
		hit_button.add_theme_stylebox_override(style_name,StyleBoxEmpty.new())
	hit_button.mouse_default_cursor_shape = CURSOR_POINTING_HAND
	var hit_width := 108.0 if friendly else maxf(108.0,art.size.x)
	var hit_top := minf(251.0,home.y+art.position.y)
	UI.at(self,hit_button,cx-hit_width/2.0,hit_top,hit_width,490.0-hit_top)
	hit_button.mouse_entered.connect(func():
		if data.hp > 0:
			marker.color = UI.GOLD
	)
	hit_button.mouse_exited.connect(func(): _sync_units())
	hit_button.pressed.connect(_target.bind(data.uid))
	units[data.uid] = {
		"data":data,"cx":cx,"home":home,"rig":rig,"pose":pose,"art":art,"rest_flip":art.flip_h,
		"base_extent":art.size,"art_scale":art.size.x/art.texture.get_width(),
		"bar":hp,"stress":stress,"marker":marker,"label":name_label,"number":number,"button":hit_button,
		"dying":false,"active":false,"running":false,"hover":hover,
		"frames":Assets.frame_count(data.sprite),"frame":0,"clip_tween":null,"reaction":null
	}

func _process(delta: float) -> void:
	clock += delta
	for slot in units.values():
		if slot.data.hp <= 0:
			continue
		var clip: Tween = slot.clip_tween
		if slot.running:
			var stride := floori((clock-float(slot.run_start))/RUN_FRAME_TIME)
			if Assets.frame_count(slot.data.sprite,"run") > 0:
				_set_pose(slot,"run",stride)
			else:
				slot.pose.position.y = -absf(sin((clock-float(slot.run_start))*30.0))*13.0
		elif not slot.active and (clip == null or not clip.is_running()):
			var idle_time := clock + float(slot.cx)/400.0
			if slot.hover > 0.0:
				slot.rig.position.y = slot.home.y + roundf(sin(idle_time*3.0)*4.0)
			var frame := floori(idle_time*8.0) % int(slot.frames)
			if frame != slot.frame:
				_set_pose(slot,"idle",frame)
				slot.frame = frame

func _set_pose(slot: Dictionary, clip: String, frame: int) -> void:
	var id: String = slot.data.sprite
	var texture := Assets.sprite(id,frame,false,clip)
	var art: TextureRect = slot.art
	var extent := texture.get_size()*float(slot.art_scale)
	var offset := Assets.clip_offset(id,clip)*float(slot.art_scale)
	var base: Vector2 = slot.base_extent
	if art.flip_h:
		offset.x = base.x-offset.x-extent.x
	art.texture = texture
	art.position = (Vector2(-base.x/2.0,-base.y)+offset).round()
	art.size = extent.round()

func _play_clip(slot: Dictionary, clip: String, frame_time: float, first := 0, release := -1) -> Tween:
	var count := Assets.frame_count(slot.data.sprite,clip)
	if count == 0:
		return null
	if slot.clip_tween != null:
		slot.clip_tween.kill()
	slot.frame = -1
	_set_pose(slot,clip,first)
	var playback := create_tween()
	slot.clip_tween = playback
	for frame in range(first+1,count if release == -1 else release+1):
		playback.tween_interval(frame_time)
		playback.tween_callback(_set_pose.bind(slot,clip,frame))
	if release == -1:
		playback.tween_interval(frame_time)
	return playback

func _dash(slot: Dictionary, destination: Vector2, retreat: bool) -> void:
	var rig: Node2D = slot.rig
	var pose: Node2D = slot.pose
	var direction := signf(destination.x-rig.position.x)
	var distance := rig.position.distance_to(destination)
	var duration := clampf(distance/(2100.0 if retreat else 1850.0),0.12,0.33)
	if slot.clip_tween != null:
		slot.clip_tween.kill()
	slot.art.flip_h = (direction < 0.0) != Assets.faces_left(slot.data.sprite)
	slot.running = true
	slot.run_start = clock
	if Assets.frame_count(slot.data.sprite,"run") > 0:
		_set_pose(slot,"run",0)
	else:
		pose.rotation = direction*0.12
	effects.dust(rig.position)
	var movement := create_tween()
	movement.tween_property(rig,"position",destination,duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await movement.finished
	slot.running = false
	pose.position = Vector2.ZERO
	pose.rotation = 0
	effects.dust(destination)

func _animate_action(action: Dictionary) -> void:
	var slot: Dictionary = units[action.actor]
	var skill: Dictionary = action.skill
	var targets: Array = action.targets
	var motion: String = skill.get("motion","melee" if skill.has("power") else "support")
	var direction := 1.0 if String(action.actor).begins_with("h") else -1.0
	slot.active = true
	if motion == "melee":
		var front: Dictionary = units[targets[0].uid]
		for unit in targets:
			var candidate: Dictionary = units[unit.uid]
			if absf(candidate.cx-slot.cx) < absf(front.cx-slot.cx):
				front = candidate
		var reach := 124.0 if slot.data.id == "knight" else 61.0
		if front.base_extent.x > 170.0:
			reach += 35.0
		if slot.base_extent.x > 170.0:
			reach += 45.0
		await _dash(slot,Vector2(front.cx-direction*reach,slot.home.y),false)

	var clip: String = skill.get("animation","attack")
	if motion == "support" and skill.get("effect","") == "shield":
		clip = "guard"
	var frame_time := 0.072
	if Assets.frame_count(slot.data.sprite,clip) > 6:
		frame_time = 0.047
	var playback: Tween
	if Assets.frame_count(slot.data.sprite,clip) > 0:
		var release_frame := Assets.release_frame(slot.data.sprite,clip)
		if release_frame > 0:
			var windup := _play_clip(slot,clip,frame_time,0,release_frame)
			await windup.finished
		playback = _play_clip(slot,clip,frame_time,release_frame)
	else:
		var pose: Node2D = slot.pose
		var windup := create_tween().set_parallel(true)
		windup.tween_property(pose,"scale",Vector2(0.94,1.08),0.08)
		windup.tween_property(pose,"rotation",-direction*0.10,0.08)
		await windup.finished
		var release := create_tween().set_parallel(true)
		release.tween_property(pose,"scale",Vector2.ONE,0.12)
		release.tween_property(pose,"rotation",0.0,0.12)
		if motion == "melee":
			pose.position.x = direction*14.0
			release.tween_property(pose,"position",Vector2.ZERO,0.12)
	if motion == "arrow" or motion == "magic":
		sound.emit("release")
		var from: Vector2 = _contact(slot)+Vector2(direction*27,0)
		var flight_time := 0.0
		for unit in targets:
			var to := _contact(units[unit.uid])
			flight_time = maxf(flight_time,clampf(from.distance_to(to)/3200.0,0.08,0.20))
		var flight: Tween
		for unit in targets:
			flight = effects.travel(from,_contact(units[unit.uid]),motion == "arrow",_spell_tint(action.actor,motion),flight_time)
		await flight.finished
	elif motion == "support" and slot.data.id in ["cleric","acolyte"]:
		sound.emit("heal")
		for unit in targets:
			effects.heal(units[unit.uid].rig.position,direction < 0)

	impact_level = 0
	action_motion = motion
	battle.resolve_action(action,false)
	action_motion = ""
	_sync_units()
	if impact_level > 0:
		_hit_feedback(impact_level)
		var can_pause := playback != null and playback.is_valid() and playback.is_running()
		if can_pause:
			playback.pause()
		await get_tree().create_timer(0.105 if impact_level == 2 else 0.062,false).timeout
		if can_pause and playback.is_valid():
			playback.play()
	if playback != null and playback.is_valid() and playback.is_running():
		await playback.finished
	if motion == "melee" and slot.data.hp > 0:
		await _dash(slot,slot.home,true)
	if slot.data.hp > 0:
		slot.art.flip_h = slot.rest_flip
		_set_pose(slot,"idle",0)
	slot.active = false
	battle.advance()
	_sync()
	_continue_later()

func _contact(slot: Dictionary) -> Vector2:
	var height := minf(float(slot.base_extent.y)*0.44,86.0)
	return slot.rig.position - Vector2(0,height)

func _spell_tint(uid: String, motion: String) -> Color:
	if motion == "arrow":
		return Color("#efd0a0")
	return Color("#89e5fb") if uid.begins_with("h") else Color("#ef93cd")

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo() or busy or not event is InputEventKey:
		return
	if not is_visible_in_tree():
		return
	var index: int = event.keycode - KEY_1
	if index >= 0 and index < skill_keys.size():
		_skill(skill_keys[index])
		get_viewport().set_input_as_handled()

func _sync_units() -> void:
	var eligible := []
	if not selected.is_empty() and battle.is_player():
		eligible = battle.targets(Content.definition("skills",selected))
	for slot in units.values():
		var data: Dictionary = slot.data
		slot.bar.max_value = data.max_hp
		slot.bar.value = data.hp
		slot.stress.value = data.stress
		slot.number.text = "%d / %d" % [data.hp,data.max_hp]
		var flags := PackedStringArray()
		for key in data.statuses:
			flags.append("%s %d" % [Combat.STATUS[key],data.statuses[key].duration])
		if data.hp > 0 and not flags.is_empty():
			slot.number.text += "  ·  " + flags[0].split(" ")[0]
		slot.button.tooltip_text = "%s · %s\n生命 %d/%d   压力 %d\n%s" % [data.name,data.role,data.hp,data.max_hp,data.stress," / ".join(flags)]
		slot.button.disabled = data.hp <= 0
		slot.marker.color = Color.TRANSPARENT
		if data == battle.actor:
			slot.marker.color = UI.GOLD
		if data in eligible:
			slot.marker.color = UI.TEAL
		if data.hp <= 0:
			slot.label.modulate.a = 0.42
			if not slot.dying:
				_fall(slot)

func _fall(slot: Dictionary) -> void:
	slot.dying = true
	if slot.reaction != null:
		slot.reaction.kill()
	var pose: Node2D = slot.pose
	var art: TextureRect = slot.art
	pose.rotation = 0.0
	pose.position = Vector2.ZERO
	pose.scale = Vector2.ONE
	var falling := create_tween().set_parallel(true)
	if _play_clip(slot,"defeat",0.14) != null:
		falling.tween_property(art,"modulate:a",0.48,0.25).set_delay(0.23)
	else:
		if slot.clip_tween != null:
			slot.clip_tween.kill()
		_set_pose(slot,"idle",0)
		var lean := -1.0 if slot.data.uid.begins_with("h") else 1.0
		var shift := Vector2(-lean*float(slot.base_extent.y)*0.37,-minf(float(slot.base_extent.x)*0.44,47.0))
		falling.tween_property(pose,"rotation",lean*1.45,0.24).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		falling.tween_property(pose,"position",shift,0.24)
		falling.tween_property(art,"modulate:a",0.28,0.29).set_delay(0.11)

func _sync_timeline() -> void:
	for child in timeline.get_children():
		timeline.remove_child(child)
		child.queue_free()
	if battle.actor.is_empty():
		return
	var upcoming: Array = [battle.actor]
	upcoming.append_array(battle.queue.filter(func(unit): return unit.hp > 0))
	var start := 252 - upcoming.size()*24
	for i in range(upcoming.size()):
		var unit: Dictionary = upcoming[i]
		var x := start+i*48
		var color := UI.GOLD if i == 0 else (UI.TEAL if String(unit.uid).begins_with("h") else UI.RED)
		UI.panel(timeline,x,4,40,38,Color("#141b25e0"),color.darkened(0.43))
		UI.unit_portrait(timeline,unit.sprite,x+20,37,Vector2(34,30),Color.WHITE,not String(unit.uid).begins_with("h"))
		UI.rule(timeline,x+5,40,30,2,color)
		var area := Control.new()
		area.mouse_filter = MOUSE_FILTER_PASS
		area.tooltip_text = "%s · %s" % [unit.name,"当前行动" if i == 0 else "本轮第 %d 位待行动" % (i+1)]
		UI.at(timeline,area,x,4,40,38)

func _sync() -> void:
	_sync_units()
	_sync_timeline()
	turn_label.text = "TURN  %02d" % battle.round_number
	phase_label.text = "首领 · 第二阶段" if battle.phase == 2 else ("首领 · 第一阶段" if battle.enemies[0].ai == "boss" else "回合制遭遇")
	for child in commands.get_children():
		commands.remove_child(child)
		child.queue_free()
	skill_keys.clear()
	if not battle.result.is_empty():
		active_label.text = "战斗结束"
		status_label.text = ""
		prompt.text = ""
		return
	var actor: Dictionary = battle.actor
	active_label.text = "%s  ·  %s" % [actor.name,actor.role]
	status_label.text = "行动中" if battle.is_player() else "敌方行动"
	if actor.stress >= 70:
		status_label.text += " · 动摇（速度 -3 / 伤害 -2）"
	if not battle.is_player():
		prompt.text = "等待敌方行动结束。"
		return
	prompt.text = "选择技能后点击高亮目标。数字键 1–3 可选择技能。"
	for i in range(actor.skills.size()):
		var id: String = actor.skills[i]
		skill_keys.append(id)
		var skill := Content.definition("skills",id)
		var x := 59 + i*177
		var label_text: String = "  " + skill.name
		if actor.cooldowns.has(id):
			label_text += " · %d" % actor.cooldowns[id]
		var b := UI.button(commands,label_text,x,552,164,61,_skill.bind(id),id == selected)
		b.alignment = HORIZONTAL_ALIGNMENT_RIGHT
		b.tooltip_text = skill.desc
		b.disabled = busy or actor.cooldowns.has(id)
		UI.sprite(commands,skill.icon,x+22,596,0.36)
		UI.label(commands,"%d" % (i+1),x+11,619,30,24,12,UI.GOLD,"body")
	UI.button(commands,"取消选中",596,552,140,61,_cancel).disabled = selected.is_empty()

func _skill(id: String) -> void:
	if busy or not battle.is_player() or battle.actor.cooldowns.has(id) or id not in battle.actor.skills:
		return
	var skill := Content.definition("skills",id)
	if skill.mode in ["self","allies","enemies"]:
		_perform(id,"")
	else:
		selected = id
		_sync()
		prompt.text = "已选择「%s」 · 点击高亮的%s。" % [skill.name,"队友" if skill.mode == "ally" else "敌人"]

func can_use_item() -> bool:
	return not busy and battle.is_player() and item_turn != _turn_id()

func record_item() -> void:
	item_turn = _turn_id()
	_sync_units()

func _turn_id() -> String:
	return "%s/%d" % [battle.actor.uid,battle.actor.turns]

func cancel_target() -> bool:
	if selected.is_empty():
		return false
	_cancel()
	return true

func _cancel() -> void:
	selected = ""
	_sync()

func _target(id: String) -> void:
	if busy or selected.is_empty():
		return
	if battle.targets(Content.definition("skills",selected)).any(func(unit): return unit.uid == id):
		_perform(selected,id)

func _perform(id: String, target: String) -> void:
	var action: Dictionary = battle.player_action(id,target)
	if action.is_empty():
		return
	busy = true
	selected = ""
	_sync()
	_animate_action(action)

func _continue_later() -> void:
	busy = true
	if not battle.result.is_empty():
		await get_tree().create_timer(0.52,false).timeout
		if is_inside_tree():
			resolved.emit(battle.result == "victory")
		return
	await get_tree().create_timer(0.26,false).timeout
	if not is_inside_tree():
		return
	if battle.is_player():
		busy = false
		_sync()
	else:
		_animate_action(battle.enemy_action())

func _narrate(_message: String) -> void:
	var tail: Array = battle.log_entries.slice(maxi(0,battle.log_entries.size()-4))
	log_label.text = "\n".join(tail)

func _impact(actor_uid: String, target_uid: String, number: String, kind: String) -> void:
	if not units.has(target_uid):
		return
	var target: Dictionary = units[target_uid]
	var heavy := kind == "critical"
	var tint := UI.RED
	if kind in ["heal","shield"]:
		tint = UI.TEAL
	elif kind == "miss":
		tint = UI.MUTED
	elif heavy:
		tint = Color("#ffd28b")
	var contact := _contact(target)
	var text := "暴击 " + number if heavy else number
	var damage := UI.label(self,text,contact.x-64,contact.y-55,128,39,32 if heavy else 24,tint,"body",HORIZONTAL_ALIGNMENT_CENTER)
	damage.add_theme_color_override("font_outline_color",Color("#17101c"))
	damage.add_theme_constant_override("outline_size",5)
	damage.pivot_offset = damage.size/2.0
	damage.scale = Vector2.ONE*1.25 if heavy else Vector2.ONE*0.86
	var popup := create_tween().set_parallel(true)
	popup.tween_property(damage,"scale",Vector2.ONE,0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	popup.tween_property(damage,"position:y",damage.position.y-37,0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	popup.tween_property(damage,"modulate:a",0.0,0.23).set_delay(0.33)
	popup.chain().tween_callback(damage.queue_free)
	var direction := 1.0 if actor_uid.begins_with("h") else -1.0
	match kind:
		"hit", "critical", "counter":
			var magic := kind != "counter" and action_motion == "magic"
			effects.impact(contact,direction,_spell_tint(actor_uid,"magic") if magic else tint,heavy,magic)
			impact_level = maxi(impact_level,2 if heavy else 1)
			_react(target,direction,heavy,false)
		"bleed", "poison":
			_react(target,direction,false,false)
		"miss":
			_react(target,direction,false,true)
		"shield":
			if number == "格挡":
				effects.impact(contact,-direction,UI.TEAL,false,false)
				impact_level = maxi(impact_level,1)
				_react(target,direction,false,false)

func _react(target: Dictionary, direction: float, heavy: bool, dodge: bool) -> void:
	var material: ShaderMaterial = target.art.material
	if not dodge:
		material.set_shader_parameter("flash",0.92 if heavy else 0.67)
		create_tween().tween_method(func(value: float): material.set_shader_parameter("flash",value),0.92 if heavy else 0.67,0.0,0.13)
	if target.data.hp <= 0:
		return
	if target.reaction != null:
		target.reaction.kill()
	if not dodge:
		_play_clip(target,"hurt",0.085)
	var pose: Node2D = target.pose
	pose.position.x = direction*(24 if heavy else (16 if dodge else 12))
	pose.rotation = direction*(0.17 if heavy else 0.085)
	var recoil := create_tween().set_parallel(true)
	target.reaction = recoil
	recoil.tween_property(pose,"position",Vector2.ZERO,0.20).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	recoil.tween_property(pose,"rotation",0.0,0.20).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _hit_feedback(level: int) -> void:
	sound.emit("critical" if level == 2 else "hit")
	if shake != null:
		shake.kill()
	var strength := 8.0 if level == 2 else 3.0
	field.position = Vector2(-strength,strength/2.0)
	shake = create_tween()
	shake.tween_property(field,"position",Vector2(strength,-strength/3.0),0.036)
	shake.tween_property(field,"position",Vector2(-strength/2.0,0),0.040)
	shake.tween_property(field,"position",Vector2.ZERO,0.065)
