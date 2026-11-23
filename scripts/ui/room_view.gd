extends Control

signal completed
signal refreshed

const UI = preload("res://scripts/ui/ui.gd")
const Content = preload("res://scripts/core/content.gd")
const Rooms = preload("res://scripts/core/event_manager.gd")
const MapView = preload("res://scripts/ui/map_controller.gd")
const Party = preload("res://scripts/core/party_manager.gd")
const Bag = preload("res://scripts/core/inventory_manager.gd")
const VISUALS := {
	"recruit":["犹在燃烧的营灯","营边的远征者在等待领队。他们各自带着旧誓与伤痕。","Scenery_16"],
	"spring":["回澜泉","石缝中流出的泉水平静如镜。泉水所余无多，全队须选择一种用法。","Scenery_36"],
	"rest":["背潮营地","厚石隔开了潮声。这是少有的机会，可以整队、磨刃或尽早睡下。","Scenery_16"],
	"treasure":["封蜡藏箱","宝箱锁芯已经腐坏。你取走其中的金币，还能从剩余的物件中选一件。","Scenery_2"],
	"shop":["灯下行商","商人一点点揭开油布。药水、旧兵刃和随葬物依次露了出来。","Scenery_17"]
}

var run
var kind: String
var target := 0

func setup(state, room_kind: String) -> void:
	run = state
	kind = room_kind
	target = int(run.pending.get("target",0))
	mouse_filter = MOUSE_FILTER_IGNORE
	var art: Array = VISUALS.get(kind,[])
	var event_data := {}
	if kind == "event":
		event_data = Rooms.event(run)
		art = [event_data.title,event_data.text,event_data.art]
	UI.frame(self,42,107,384,541)
	UI.label(self,MapView.NAMES[kind],65,125,320,30,15,UI.GOLD)
	UI.label(self,art[0],64,161,330,63,36,UI.PALE,"display")
	UI.rule(self,67,235,331)
	UI.text_block(self,art[1],67,259,319,106,16)
	UI.panel(self,101,382,265,202,Color("#101922"),Color("#323c42"))
	UI.sprite(self,art[2],233,541,1.5,Color("#dfd6cb"))
	UI.rule(self,119,550,228,1,Color("#4e534e"))
	UI.frame(self,447,107,790,541)
	if run.pending.has("resolution"):
		UI.label(self,"房间结算",476,128,722,51,32,UI.PALE,"display")
		UI.text_block(self,run.pending.resolution,478,230,698,176,21,UI.PALE)
		UI.button(self,"返回路线    >",927,568,276,46,func(): completed.emit(),true)
		return
	match kind:
		"recruit": _recruit()
		"event": _event(event_data)
		"spring": _spring()
		"shop": _shop()
		"rest": _rest()
		"treasure": _treasure()
	UI.button(self,"离开房间",477,571,166,43,func():
		if kind == "treasure":
			run.gold += _coin_reward()
		completed.emit()
	)

func _heading(title: String, detail: String) -> void:
	UI.label(self,title,477,128,716,50,30,UI.PALE,"display")
	UI.label(self,detail,478,187,708,29,15,UI.MUTED)
	UI.rule(self,478,230,724)

func _row(title: String, description: String, y: int, action: Callable) -> Button:
	var button := UI.button(self,title,477,y,251,48,action)
	UI.text_block(self,description,746,y+7,450,48,14)
	return button

func _recruit() -> void:
	_heading("招募远征同伴","可招募一名成员，队伍上限为四人。")
	if run.party.size() >= Party.LIMIT:
		UI.label(self,"队伍已满。",479,270,620,39,19,UI.GOLD)
		return
	var ids := Rooms.candidates(run)
	for i in range(ids.size()):
		var id: String = ids[i]
		var h := Content.definition("heroes",id)
		var x := 476 + i*244
		UI.panel(self,x,251,229,285,Color("#1b2330"))
		UI.label(self,h.name + "  ·  " + h.role,x+13,259,202,37,19,UI.PALE)
		UI.unit_portrait(self,h.sprite,x+116,398,Vector2(111,96))
		UI.label(self,"生命 %d · 攻击 %d · 速度 %d" % [h.hp,h.attack,h.speed],x+13,405,200,28,13,UI.GOLD)
		var names := PackedStringArray()
		for skill in h.skills:
			names.append(Content.definition("skills",skill).name)
		UI.label(self," / ".join(names),x+13,438,202,26,13,UI.MUTED)
		var button := UI.button(self,"招募",x+13,477,202,40,func():
			if run.recruit(id):
				_resolve("%s加入了远征队。" % h.name)
		,true)
		button.tooltip_text = h.passive_text

func _spring() -> void:
	_heading("分配泉水","选择接受单人治疗的远征者，或使用全队方案。")
	_select_member(254)
	_row("为全队疗伤","每名生还成员恢复最多 14 点生命。",321,func():
		Rooms.apply(run,{"heal":14})
		_resolve("泉水洗去了伤口上的盐。")
	)
	_row("治疗选中成员","单名成员恢复最多 29 点生命。",386,func():
		Party.heal(run.party[target],29)
		_resolve("%s的伤口在泉水里缓缓收拢。" % run.party[target].name)
	).disabled = run.party[target].hp <= 0
	_row("平息心绪","全队缓解 28 压力。",451,func():
		Rooms.apply(run,{"stress":-28})
		_resolve("寂静的水面带走了众人的惊惧。")
	)

func _rest() -> void:
	_heading("安排休整","选择一种休整方式。训练会永久提高该成员本轮的属性。")
	_select_member(254)
	_row("裹伤歇息","全队恢复 19 生命。",321,func():
		Rooms.apply(run,{"heal":19})
		_resolve("队伍在余火旁处理伤口。")
	)
	_row("训练选中成员","所选成员攻击 +2，生命上限 +5。",386,func():
		Party.upgrade(run.party[target])
		_resolve("%s精进了战斗技巧。" % run.party[target].name)
	).disabled = run.party[target].hp <= 0
	_row("守望与深眠","全队缓解 34 压力。",451,func():
		Rooms.apply(run,{"stress":-34})
		_resolve("潮声沉下去时，众人终于入睡。")
	)

func _select_member(y: int) -> void:
	if run.party[target].hp <= 0:
		target = run.party.find(Party.living(run.party)[0])
	for i in range(run.party.size()):
		var hero: Dictionary = run.party[i]
		UI.button(self,hero.name,477+i*162,y,150,39,func():
			run.pending.target = i
			refreshed.emit()
		,i == target).disabled = hero.hp <= 0

func _event(data: Dictionary) -> void:
	_heading("决定如何行动","风险与收益会在结算后写入本轮远征。")
	for i in range(data.choices.size()):
		var choice: Dictionary = data.choices[i]
		var button := _row(choice.label,choice.hint,257+i*88,func():
			if not Rooms.choose(run,data,i).is_empty():
				refreshed.emit()
		)
		button.disabled = run.gold < int(choice.get("cost",0))
		button.tooltip_text = choice.hint

func _treasure() -> void:
	var coins := _coin_reward()
	_heading("选择一件战利品","取走 %d 金币，可额外带走下方一件物品。" % coins)
	var items := Rooms.treasure(run)
	for i in range(items.size()):
		var id: String = items[i]
		var item := Content.definition("items",id)
		_row(item.name,item.quality + " · " + item.desc,259+i*79,func():
			run.gold += coins
			Bag.add(run,id)
			_resolve("你带走了%d枚金币，以及%s。" % [coins,item.name])
		)

func _coin_reward() -> int:
	return 15 + int(run.pending.floor)*2

func _shop() -> void:
	_heading("交易","金币 %d  ·  可购买多件商品，离开后继续远征。" % run.gold)
	var stock := Rooms.stock(run)
	for i in range(stock.size()):
		var id: String = stock[i]
		var item := Content.definition("items",id)
		var x := 477 + (i%2)*364
		var y := 251 + (i/2)*94
		var b := UI.button(self,"%s     %d 金币" % [item.name,item.cost],x,y,344,56,func():
			if Bag.buy(run,id):
				refreshed.emit()
		)
		b.tooltip_text = item.desc
		b.disabled = run.gold < int(item.cost)
		UI.label(self,"%s · %s" % [item.quality,item.desc],x+8,y+58,329,25,12,UI.MUTED)

func _resolve(message: String) -> void:
	run.pending.resolution = message
	refreshed.emit()

