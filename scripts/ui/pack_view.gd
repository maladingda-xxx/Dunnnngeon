extends Control

signal select_member(index: int)
signal equip_pressed(id: String)
signal unequip_pressed(id: String)
signal use_pressed(id: String)

const UI = preload("res://scripts/ui/ui.gd")
const Content = preload("res://scripts/core/content.gd")
const Bag = preload("res://scripts/core/inventory_manager.gd")

func setup(run, index: int, field_use: bool, combat_active: bool, message: String) -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	for i in range(run.party.size()):
		var member: Dictionary = run.party[i]
		var b := UI.button(self,member.name,27+i*125,100,114,39,func(): select_member.emit(i),i == index)
		b.tooltip_text = member.role
	var hero: Dictionary = run.party[index]
	var source := Content.definition("heroes",hero.id)
	UI.panel(self,27,159,342,339,Color("#171e2a"))
	UI.unit_portrait(self,hero.sprite,74,231,Vector2(62,66),Color.WHITE if hero.hp > 0 else Color("#746372"))
	UI.label(self,"%s  ·  %s  LV.%d" % [hero.name,hero.role,hero.level],110,169,248,30,18)
	UI.label(self,"生命 %d/%d  ·  压力 %d" % [hero.hp,hero.max_hp,hero.stress],110,201,248,24,14,UI.TEAL)
	UI.rule(self,44,242,305)
	UI.label(self,"攻击 %d   防御 %d   速度 %d" % [hero.attack,hero.defense,hero.speed],44,252,305,24,14,UI.GOLD)
	UI.label(self,"暴击 %d%%   闪避 %d%%" % [roundi(hero.crit*100),roundi(hero.dodge*100)],44,277,305,24,14,UI.GOLD)
	UI.text_block(self,source.passive_text,44,314,299,51,14)
	var names := PackedStringArray()
	for id in hero.skills:
		names.append(Content.definition("skills",id).name)
	UI.label(self," / ".join(names),44,362,302,24,13,UI.PALE)
	for i in range(hero.gear.size()):
		var id: String = hero.gear[i]
		var info := Content.definition("items",id)
		var b := UI.button(self,info.name + "  ·  卸下",44+i*148,420,140,42,func(): unequip_pressed.emit(id))
		b.tooltip_text = info.desc
		b.disabled = combat_active or hero.hp <= 0
	if hero.gear.is_empty():
		UI.label(self,"装备栏为空",44,422,289,35,14,UI.MUTED)
	UI.panel(self,386,159,486,339,Color("#171e2a"))
	UI.label(self,"消耗品",403,169,210,29,16,UI.PALE)
	for i in range(Bag.CONSUMABLES.size()):
		var id: String = Bag.CONSUMABLES[i]
		var item := Content.definition("items",id)
		var x := 401+i*152
		var amount: int = run.bag.get(id,0)
		var b := UI.button(self,"%s ×%d" % [item.name,amount],x,209,141,44,func(): use_pressed.emit(id))
		b.disabled = not field_use or hero.hp <= 0 or amount <= 0
		b.tooltip_text = item.desc
	UI.rule(self,402,268,448)
	UI.label(self,"待装备物品",402,274,230,26,16,UI.PALE)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	UI.at(self,scroll,401,309,455,167)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation",6)
	scroll.add_child(list)
	if run.equipment.is_empty():
		var empty := Label.new()
		empty.text = "探索宝箱、精英房间或商店可获得装备。"
		empty.add_theme_color_override("font_color",UI.MUTED)
		list.add_child(empty)
	for id in run.equipment:
		var info := Content.definition("items",id)
		var choice := UI.button(list,"%s    ·    %s" % [info.name,info.quality],0,0,300,36,func(): equip_pressed.emit(id))
		choice.custom_minimum_size = Vector2(0,36)
		choice.disabled = combat_active or hero.hp <= 0
		choice.tooltip_text = info.desc
	var hint := message
	if hint.is_empty():
		hint = "每个友方行动可额外使用一次消耗品。" if combat_active else "每名远征者可装备一件武器和一件护符。"
	UI.label(self,hint,28,517,640,33,14,UI.TEAL)

