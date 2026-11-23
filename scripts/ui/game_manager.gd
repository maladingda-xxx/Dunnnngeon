extends Control

const UI = preload("res://scripts/ui/ui.gd")
const Art = preload("res://scripts/ui/stage_art.gd")
const Content = preload("res://scripts/core/content.gd")
const Run = preload("res://scripts/core/run_manager.gd")
const MapView = preload("res://scripts/ui/map_controller.gd")
const Map = preload("res://scripts/core/map_generator.gd")
const Icon = preload("res://scripts/ui/legend_icon.gd")
const Combat = preload("res://scripts/core/combat_manager.gd")
const CombatView = preload("res://scripts/ui/combat_view.gd")
const Party = preload("res://scripts/core/party_manager.gd")
const Rooms = preload("res://scripts/core/event_manager.gd")
const Bag = preload("res://scripts/core/inventory_manager.gd")
const Save = preload("res://scripts/core/save_manager.gd")
const RoomView = preload("res://scripts/ui/room_view.gd")
const PackView = preload("res://scripts/ui/pack_view.gd")
const REGION := "盐蚀地窟"

var run
var screen: Control
var overlay: Control
var combat_view: Control
var view := ""
var seed_field: LineEdit
var selected_hero := ""
var stage: Control
var audio: AudioStreamPlayer
var effects := {}
var volume := 0.62
var pack_index := 0
var save_path := Save.PATH
var save_error := false

func _ready() -> void:
	UI.ThemeArt.prepare()
	texture_filter = TEXTURE_FILTER_LINEAR
	var ui_theme := Theme.new()
	ui_theme.default_font = UI.font("body")
	ui_theme.default_font_size = 15
	ui_theme.set_stylebox("panel","TooltipPanel",UI.style(Color("#161924"),UI.GOLD))
	ui_theme.set_color("font_color","TooltipLabel",UI.PALE)
	theme = ui_theme
	stage = Art.new()
	UI.at(self,stage,0,0,1280,720)
	var settings := ConfigFile.new()
	if settings.load("user://abyss_settings.cfg") == OK:
		volume = clampf(float(settings.get_value("audio","volume",volume)),0.0,1.0)
	audio = AudioStreamPlayer.new()
	add_child(audio)
	_audio_volume()
	_show_title()

func _screen(name: String, mode: String) -> void:
	if screen != null:
		remove_child(screen)
		screen.queue_free()
	screen = Control.new()
	screen.name = name.capitalize().replace(" ","")
	screen.mouse_filter = MOUSE_FILTER_IGNORE
	UI.at(self,screen,0,0,1280,720)
	stage.mode = mode
	stage.queue_redraw()
	view = name
	var art := stage
	art.modulate = Color("#e1dfeb")
	create_tween().tween_property(art,"modulate",Color.WHITE,0.28)
	if mode != "title":
		_header(name)

func _header(title: String) -> void:
	UI.frame(screen,22,6,1236,68)
	var identity := Icon.new()
	identity.kind = "gate"
	identity.mouse_filter = MOUSE_FILTER_IGNORE
	UI.at(screen,identity,39,24,30,30)
	UI.label(screen,"ABYSS EXPEDITION",81,11,305,32,23,UI.PALE,"display")
	UI.label(screen,"深渊远征  /  " + REGION,83,44,305,23,12,UI.MUTED)
	if run != null:
		var loc: Dictionary = run.pending if not run.pending.is_empty() else run.current()
		UI.label(screen,"第 %02d 层   /   %02d" % [loc.floor,run.floors.size()-1],482,21,178,35,16,UI.PALE)
		UI.rule(screen,663,23,1,34)
		UI.sprite(screen,"Items_5",692,50,0.38,UI.GOLD)
		UI.label(screen,str(run.gold) + "  金币",714,21,123,35,16,UI.GOLD)
		UI.rule(screen,838,23,1,34)
		UI.label(screen,"生还 %d / %d" % [Party.living(run.party).size(),run.party.size()],857,21,135,35,15,UI.TEAL)
	if title in ["map","combat","room","reward"]:
		UI.button(screen,"暂停",1119,23,113,33,_pause)

func _footer(left: String, right: String) -> void:
	UI.rule(screen,40,677,1200,1)
	UI.label(screen,left,42,682,730,25,12,UI.MUTED)
	UI.label(screen,right,762,682,475,25,12,UI.GOLD,"body",HORIZONTAL_ALIGNMENT_RIGHT)

func _show_title() -> void:
	run = Save.load_run(save_path)
	_screen("title","title")
	UI.frame(screen,32,60,617,579,UI.ThemeArt.wood)
	UI.frame(screen,50,81,581,530)
	UI.frame(screen,67,100,244,33,UI.ThemeArt.ribbon)
	UI.label(screen,"远征档案   /   第一纪",67,99,244,31,15,UI.PALE,"body",HORIZONTAL_ALIGNMENT_CENTER)
	UI.label(screen,"Abyss",66,143,660,112,96,UI.PALE,"display")
	UI.label(screen,"Expedition",67,240,665,103,84,UI.PALE,"display")
	UI.label(screen,"深 渊 远 征",74,348,590,35,23,UI.GOLD)
	UI.rule(screen,74,401,392)
	UI.label(screen,"循余火下潜，夺回无灯之城。",74,410,531,44,18,UI.MUTED)
	UI.button(screen,"开始冒险    >",74,474,246,52,_show_choice,true)
	UI.button(screen,"继续游戏",333,474,132,52,func(): _show_map()).disabled = run == null or not run.end_state.is_empty()
	UI.button(screen,"设置",74,540,119,39,_settings)
	UI.button(screen,"退出",203,540,119,39,func(): get_tree().quit())
	var warrior := Content.definition("heroes","warrior")
	UI.unit_sprite(screen,warrior.sprite,937,608,Vector2(187,178))
	UI.sprite(screen,"Scenery_16",770,607,1.05,Color("#e3ba89"))
	_footer("第一地域  ·  " + REGION,"ABYSS EXPEDITION")

func _show_choice() -> void:
	_screen("choice","archive")
	UI.label(screen,"选择远征者",42,106,800,55,43,UI.PALE,"display")
	UI.label(screen,"从六名远征者中选出一位领队。",44,173,790,28,16,UI.MUTED)
	UI.label(screen,"地图种子",902,110,112,24,13,UI.GOLD)
	seed_field = LineEdit.new()
	seed_field.max_length = 16
	seed_field.placeholder_text = "留空时随机"
	seed_field.add_theme_stylebox_override("normal",UI.style(Color("#161c27"),UI.LINE))
	seed_field.add_theme_stylebox_override("focus",UI.style(Color("#1b2431"),UI.TEAL))
	UI.at(screen,seed_field,902,138,330,43)
	var ids := Content.keys("heroes")
	for i in range(ids.size()):
		var id: String = ids[i]
		var h := Content.definition("heroes",id)
		var x := 42+i*201
		var card := UI.button(screen,"",x,214,186,326,_choose_hero.bind(id),id == selected_hero,true)
		card.tooltip_text = h.passive_text
		UI.unit_sprite(screen,h.sprite,x+93,444,Vector2(116,220))
		UI.rule(screen,x+15,452,156)
		UI.label(screen,h.name,x+11,457,164,32,24,UI.PALE,"display",HORIZONTAL_ALIGNMENT_CENTER)
		UI.label(screen,h.role,x+11,488,164,20,15,UI.GOLD,"body",HORIZONTAL_ALIGNMENT_CENTER)
		UI.label(screen,"生命 %d · 攻击 %d" % [h.hp,h.attack],x+10,510,166,25,14,UI.MUTED,"body",HORIZONTAL_ALIGNMENT_CENTER)
	UI.label(screen,"",43,549,700,35,18,UI.TEAL).name = "Selection"
	UI.button(screen,"返回",42,615,145,44,_show_title)
	UI.button(screen,"踏入地窟    >",1008,615,225,44,_begin,true).name = "Depart"
	_update_choice()
	_footer("地图库  /  一次远征从一名成员开始","CHOOSE YOUR LEADER")

func _choose_hero(id: String) -> void:
	var previous := seed_field.text
	selected_hero = id
	_show_choice()
	seed_field.text = previous
	_play("select")

func _update_choice() -> void:
	screen.get_node("Depart").disabled = selected_hero.is_empty()
	if not selected_hero.is_empty():
		var h := Content.definition("heroes",selected_hero)
		screen.get_node("Selection").text = "%s  ·  %s" % [h.name,h.passive_text]

func _begin() -> void:
	if selected_hero.is_empty():
		return
	var raw := seed_field.text.strip_edges()
	var seed_value := randi() if raw.is_empty() else (int(raw) if raw.is_valid_int() else raw.hash())
	run = Run.new(seed_value,selected_hero)
	_checkpoint()
	_play("select")
	_show_map()

func _show_map() -> void:
	_screen("map","archive")
	UI.label(screen,"远征路线",42,104,230,45,35,UI.PALE,"display")
	UI.label(screen,"区域 01  /  " + REGION,44,153,230,24,14,UI.GOLD)
	UI.frame(screen,42,198,232,302)
	UI.label(screen,"队伍",59,207,172,34,17,UI.PALE)
	UI.rule(screen,59,246,197)
	for i in range(run.party.size()):
		var actor: Dictionary = run.party[i]
		var y := 260+i*52
		UI.unit_portrait(screen,actor.sprite,79,y+40,Vector2(42,40),Color.WHITE if actor.hp > 0 else Color("#756b74"))
		UI.label(screen,"%s · %s" % [actor.name,actor.role],108,y,142,22,13,UI.PALE)
		var hp := UI.bar(screen,108,y+26,132,6,UI.RED)
		hp.max_value = actor.max_hp
		hp.value = actor.hp
		var stress := UI.bar(screen,108,y+35,132,4,UI.TEAL)
		stress.value = actor.stress
	UI.button(screen,"队伍与背包",42,511,232,42,_pack)
	UI.frame(screen,42,568,232,89)
	UI.label(screen,"本轮种子",59,575,191,24,13,UI.GOLD)
	UI.label(screen,str(run.seed_value),59,605,191,28,20,UI.PALE,"body")
	UI.frame(screen,284,89,689,581,UI.ThemeArt.wood)
	UI.frame(screen,298,98,660,561,UI.ThemeArt.parchment)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	UI.at(screen,scroll,306,102,648,552)
	var map_view := MapView.new()
	scroll.add_child(map_view)
	map_view.build(run)
	map_view.chosen.connect(_enter)
	var preview_name := UI.label(screen,"选择可达房间",1007,548,216,31,19,UI.PALE)
	var preview_body := UI.text_block(screen,"青色外环标记当前位置可达的房间。",1008,591,213,52,13)
	map_view.inspected.connect(func(id: String):
		if id.is_empty():
			preview_name.text = "选择可达房间"
			preview_body.text = "青色外环标记当前位置可达的房间。"
			return
		var room := Map.find(run.floors,id)
		preview_name.text = MapView.NAMES[room.kind]
		var reach := "可进入" if id in run.current().next else ("已访问" if id in run.trail else "未连通")
		preview_body.text = "第 %02d 层 · %s\n%s" % [room.floor,reach,MapView.DESCRIPTIONS[room.kind]]
	)
	scroll.set_deferred("scroll_vertical",map_view.scroll_target())
	UI.frame(screen,982,101,255,416)
	UI.label(screen,"地窟图例",1007,115,212,36,23,UI.PALE,"display")
	UI.rule(screen,1007,161,205)
	var i := 0
	for kind in MapView.NAMES:
		if kind == "gate":
			continue
		var y := 175+i*32
		var icon := Icon.new()
		icon.kind = kind
		icon.mouse_filter = MOUSE_FILTER_IGNORE
		UI.at(screen,icon,1009,y,30,30)
		UI.label(screen,MapView.NAMES[kind],1052,y,153,30,14,UI.PALE)
		i += 1
	UI.frame(screen,982,532,255,125)
	preview_name.move_to_front()
	preview_body.move_to_front()
	_footer("滚轮浏览地图  ·  悬停查看房间  ·  点击青色节点前进","存档写入失败" if save_error else "THE SALTWORN VAULT")

func _enter(id: String) -> void:
	if not run.enter(id):
		return
	_play("select")
	var kind: String = run.pending.kind
	if kind == "mystery":
		kind = Rooms.mystery(run)
	run.pending.actual = kind
	if kind in ["battle","elite","boss"]:
		_show_battle(kind)
	else:
		_show_room()

func _show_battle(kind: String) -> void:
	_screen("combat","combat")
	var model := Combat.new(run.party,run.foes(kind),run.rng_for("combat").seed)
	combat_view = CombatView.new()
	combat_view.mouse_filter = MOUSE_FILTER_IGNORE
	UI.at(screen,combat_view,0,0,1280,720)
	combat_view.resolved.connect(_battle_done.bind(kind))
	combat_view.pack_requested.connect(_pack)
	combat_view.sound.connect(_play)
	combat_view.setup(model,MapView.NAMES[kind],run.pending.floor)

func _battle_done(victory: bool, kind: String) -> void:
	if not victory:
		run.end_state = "defeat"
		Save.clear(save_path)
		_show_end()
		return
	var reward: Dictionary = run.reward(kind)
	_screen("reward","archive")
	UI.frame(screen,350,152,580,452)
	UI.label(screen,"敌阵瓦解",381,184,518,66,49,UI.PALE,"display",HORIZONTAL_ALIGNMENT_CENTER)
	UI.label(screen,"战斗奖励",381,258,518,31,19,UI.GOLD,"display",HORIZONTAL_ALIGNMENT_CENTER)
	UI.rule(screen,415,303,450)
	UI.sprite(screen,"Scenery_2",640,406,1.0)
	UI.label(screen,"+%d 金币  ·  生还成员恢复生命" % reward.gold,394,420,492,35,20,UI.PALE,"body",HORIZONTAL_ALIGNMENT_CENTER)
	var loot: Variant = reward.gear if not reward.gear.is_empty() else reward.item
	if not loot.is_empty():
		UI.label(screen,Content.definition("items",loot).get("name",loot),394,456,492,24,15,UI.TEAL,"body",HORIZONTAL_ALIGNMENT_CENTER)
	UI.button(screen,"完成结算    >",508,522,264,49,_finish_room,true)
	_play("victory")

func _finish_room() -> void:
	if not run.finish_room():
		return
	if run.end_state == "victory":
		Save.clear(save_path)
		_show_end()
	else:
		_checkpoint()
		_show_map()

func _checkpoint() -> void:
	save_error = Save.save(run,save_path) != OK

func _show_room() -> void:
	_screen("room","archive")
	var room := RoomView.new()
	UI.at(screen,room,0,0,1280,720)
	room.completed.connect(_finish_room)
	room.refreshed.connect(_show_room)
	room.setup(run,run.pending.actual)
	_footer("房间结果会在返回路线时存档。","SALTWORN VAULT")

func _show_end() -> void:
	var won: bool = run.end_state == "victory"
	_screen("end","archive")
	UI.frame(screen,332,131,616,483)
	UI.label(screen,"远征成功" if won else "远征失败",369,173,542,82,58,UI.PALE,"display",HORIZONTAL_ALIGNMENT_CENTER)
	UI.label(screen,"最后的灯火仍在燃烧。" if won else "潮水淹没了最后一簇火光。",369,268,542,36,20,UI.GOLD,"body",HORIZONTAL_ALIGNMENT_CENTER)
	UI.rule(screen,386,335,508)
	UI.label(screen,"探索 %02d 层  ·  战斗胜利 %02d 场  ·  金币 %d" % [run.trail.size()-1,run.wins,run.gold],378,360,526,47,16,UI.PALE,"body",HORIZONTAL_ALIGNMENT_CENTER)
	UI.label(screen,"地图种子  %s" % str(run.seed_value),369,415,542,35,15,UI.MUTED,"body",HORIZONTAL_ALIGNMENT_CENTER)
	UI.button(screen,"主菜单",433,512,181,48,_show_title)
	UI.button(screen,"再启远征",636,512,210,48,_show_choice,true)

func _modal(title: String, width := 530, height := 390) -> Control:
	_close_modal()
	get_tree().paused = true
	overlay = Control.new()
	overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.mouse_filter = MOUSE_FILTER_STOP
	UI.at(self,overlay,0,0,1280,720)
	UI.rule(overlay,0,0,1280,720,Color("#080910d2"))
	var box := Control.new()
	box.mouse_filter = MOUSE_FILTER_IGNORE
	UI.at(overlay,box,(1280-width)*0.5,(720-height)*0.5,width,height)
	UI.frame(box,0,0,width,height)
	UI.label(box,title,25,18,width-50,52,32,UI.PALE,"display")
	UI.rule(box,25,81,width-50)
	return box

func _close_modal() -> void:
	if overlay != null:
		remove_child(overlay)
		overlay.queue_free()
		overlay = null
	get_tree().paused = false

func _pause() -> void:
	var box := _modal("远征已暂停",486,316)
	UI.button(box,"继续游戏",30,106,426,48,_close_modal,true)
	UI.button(box,"音量设置",30,164,426,45,_settings)
	UI.button(box,"返回主菜单",30,219,426,45,func():
		_close_modal()
		_show_title()
	)

func _settings() -> void:
	var box := _modal("设置",520,300)
	UI.label(box,"主音量",28,104,140,30,16,UI.GOLD)
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.01
	slider.value = volume
	UI.at(box,slider,139,109,335,25)
	slider.value_changed.connect(func(value: float):
		volume = value
		_audio_volume()
		var settings := ConfigFile.new()
		settings.set_value("audio","volume",volume)
		settings.save("user://abyss_settings.cfg")
		_play("select")
	)
	UI.button(box,"完成",28,215,464,45,_close_modal,true)

func _audio_volume() -> void:
	AudioServer.set_bus_volume_db(0,linear_to_db(maxf(0.001,volume)))
	AudioServer.set_bus_mute(0,volume <= 0.0)

func _pack() -> void:
	pack_index = 0
	_draw_pack()

func _draw_pack(message := "") -> void:
	var box := _modal("队伍与背包",902,579)
	var pack := PackView.new()
	UI.at(box,pack,0,0,902,579)
	var in_combat := view == "combat"
	pack.setup(run,pack_index,not in_combat or combat_view.can_use_item(),in_combat,message)
	pack.select_member.connect(func(index: int):
		pack_index = index
		_draw_pack()
	)
	pack.equip_pressed.connect(func(id: String): _gear(id,true))
	pack.unequip_pressed.connect(func(id: String): _gear(id,false))
	pack.use_pressed.connect(_consume)
	UI.button(box,"关闭",704,517,166,36,_close_modal)

func _gear(id: String, equip: bool) -> void:
	var hero: Dictionary = run.party[pack_index]
	if view != "map":
		return
	var changed := Bag.equip(run,hero,id) if equip else Bag.unequip(run,hero,id)
	if changed:
		_checkpoint()
		_refresh_map_under_overlay()
		_draw_pack("已更新%s的装备。" % hero.name)

func _consume(id: String) -> void:
	var hero: Dictionary = run.party[pack_index]
	var in_combat := view == "combat"
	if in_combat and not combat_view.can_use_item():
		return
	if not Bag.use(run,hero,id):
		_draw_pack("该成员当前无需使用此物品。")
		return
	if in_combat:
		combat_view.record_item()
	else:
		_checkpoint()
		_refresh_map_under_overlay()
	_draw_pack("已为%s使用%s。" % [hero.name,Content.definition("items",id).name])

func _refresh_map_under_overlay() -> void:
	if view == "map":
		_show_map()
		overlay.move_to_front()

func _play(name: String) -> void:
	if volume <= 0.0:
		return
	if not effects.has(name):
		var wave := AudioStreamWAV.new()
		wave.format = AudioStreamWAV.FORMAT_16_BITS
		wave.mix_rate = 22050
		var duration := 0.20 if name in ["victory","critical"] else 0.10
		var length := roundi(wave.mix_rate*duration)
		var bytes := PackedByteArray()
		bytes.resize(length*2)
		for i in range(length):
			var t := float(i)/wave.mix_rate
			var s: float
			match name:
				"hit", "critical":
					var pitch := 64.0 if name == "critical" else 104.0
					var thud := sin(TAU*t*(pitch+110.0*exp(-t*35.0))) * exp(-t*26.0)
					var crack := (sin(TAU*t*769.0)+sin(TAU*t*1381.0)) * exp(-t*100.0)
					var ring := sin(TAU*t*460.0)*exp(-t*23.0) if name == "critical" else 0.0
					s = thud*0.75+crack*0.24+ring*0.24
				"release":
					s = sin(TAU*t*(680.0-3400.0*t))*sin(PI*t/duration)*exp(-t*26.0)*0.29
				"heal":
					s = (sin(TAU*t*523.25)+sin(TAU*t*783.99))*sin(PI*t/duration)*0.19
				_:
					var frequency := 392.0 if name == "victory" else 540.0
					s = sin(TAU*t*frequency) * (1.0-float(i)/length) * (0.55*cos(TAU*t*42.0)+0.45)*0.47
			bytes.encode_s16(i*2,roundi(s*9500))
		wave.data = bytes
		effects[name] = wave
	audio.process_mode = Node.PROCESS_MODE_ALWAYS
	audio.stream = effects[name]
	audio.play()

func _exit_tree() -> void:
	if audio != null:
		audio.stop()
		audio.stream = null

func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo or event.keycode != KEY_ESCAPE:
		return
	if overlay != null:
		_close_modal()
	elif view == "choice":
		_show_title()
	elif view == "combat" and combat_view.cancel_target():
		pass
	elif view in ["map","combat","room","reward"]:
		_pause()
	else:
		return
	get_viewport().set_input_as_handled()


