extends Control

signal chosen(id: String)
signal inspected(id: String)

const UI = preload("res://scripts/ui/ui.gd")
const NAMES := {"gate":"远征入口","battle":"普通战斗","elite":"精英战斗","boss":"区域首领","recruit":"招募营地","spring":"治疗泉水","treasure":"宝藏房间","event":"随机事件","shop":"商人据点","rest":"休息营地","mystery":"神秘房间"}
const DESCRIPTIONS := {"gate":"从淹没的拱门出发。","battle":"击溃潮骸，赢得金币与补给。","elite":"迎战强敌，夺取高品质装备。","boss":"穿过最后一道门，终结潮汐。","recruit":"从远征者中招募一名同伴。","spring":"选择治疗伤口或缓解压力。","treasure":"打开宝箱，从战利品中做出选择。","event":"面对旧世界遗留的抉择。","shop":"用金币购买药剂与装备。","rest":"恢复生命、减压或强化一名队友。","mystery":"踏入房间后才会揭示内容。"}
const COLORS := {"gate":"#436766","battle":"#8c5245","elite":"#a5494c","boss":"#983c43","recruit":"#416054","spring":"#347477","treasure":"#876336","event":"#645449","shop":"#776043","rest":"#865937","mystery":"#665e6b"}
const STEP := 93
const HEIGHT := 1244

var run
var hovered := ""
var markers := {}
var points := {}

func build(state) -> void:
	run = state
	mouse_filter = MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(638,HEIGHT)
	var empty := StyleBoxEmpty.new()
	for layer in run.floors:
		for room in layer:
			var lane_space := 118.0 if layer.size() > 2 else 188.0
			var depth := int(room.floor)
			var x: float = 319.0 + (float(room.lane) - (layer.size()-1)*0.5) * lane_space
			var y := HEIGHT - 65 - depth * STEP
			if depth > 0 and depth < run.floors.size() - 1:
				x += ((depth * 17 + int(room.lane)*11) % 27) - 13
				y += ((depth * 11 + int(room.lane)*7) % 19) - 9
			var p := Vector2(x,y)
			points[room.id] = p
			var b := Button.new()
			b.mouse_default_cursor_shape = CURSOR_POINTING_HAND
			b.tooltip_text = "%s · %s" % [NAMES[room.kind],DESCRIPTIONS[room.kind]]
			for s in ["normal","hover","pressed","disabled"]:
				b.add_theme_stylebox_override(s,empty)
			var focus := UI.style(Color.TRANSPARENT,Color("#176b6b"),2,24)
			b.add_theme_stylebox_override("focus",focus)
			UI.at(self,b,p.x-24,p.y-24,48,48)
			b.mouse_entered.connect(_hover.bind(room.id))
			b.mouse_exited.connect(_hover.bind(""))
			b.focus_entered.connect(_hover.bind(room.id))
			b.pressed.connect(_select.bind(room.id))
			markers[room.id] = b
	queue_redraw()

func scroll_target() -> int:
	var p: Vector2 = points[run.trail.back()]
	return clampi(roundi(p.y) - 395,0,HEIGHT-552)

func _hover(id: String) -> void:
	hovered = id
	inspected.emit(id)
	queue_redraw()

func _select(id: String) -> void:
	if id in run.current().next:
		chosen.emit(id)
	else:
		_hover(id)

func _draw() -> void:
	if run == null:
		return
	for row in range(HEIGHT-65,-1,-STEP):
		draw_line(Vector2(32,row),Vector2(606,row),Color("#725f4c31"),1)
		var depth := (HEIGHT - 65 - row) / STEP
		draw_string(UI.font("body"),Vector2(29,row-7),"%02d" % depth,HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("#594936"))
		for x in [48,592]:
			draw_circle(Vector2(x,row),2,Color("#7c634d"))
	_compass(Vector2(547,HEIGHT-158),38)
	_compass(Vector2(94,HEIGHT-444),31)
	_compass(Vector2(528,266),42)
	var next: Array = run.current().next
	for layer in run.floors:
		for room in layer:
			var from: Vector2 = points[room.id]
			for target in room.next:
				var to: Vector2 = points[target]
				var path: bool = room.id in run.trail and target in run.trail
				var selected: bool = room.id == run.trail.back() and (target in next)
				var ink := Color("#73604a8a")
				if path:
					ink = Color("#604631")
				elif selected:
					ink = Color("#315f5a") if hovered != target else Color("#226a66")
				var vector := from.direction_to(to)
				var a := from + vector * 22
				var b := to - vector * 22
				if path:
					draw_line(a,b,ink,3,true)
				else:
					draw_dashed_line(a,b,ink,2.0 if selected else 1.0,5.0,true,true)
	for layer in run.floors:
		for room in layer:
			var p: Vector2 = points[room.id]
			var available: bool = room.id in next
			var visited: bool = room.id in run.trail
			var selected: bool = room.id == hovered
			var ink := Color(COLORS[room.kind])
			var size_value := 24 if room.kind == "boss" else 19
			if available or visited or selected:
				draw_circle(p,size_value+5,Color("#dfc79b") if available or selected else Color("#a48863"),true,-1,true)
				draw_arc(p,size_value+5,-PI/2,PI*1.5,38,Color("#2f6860") if available else Color("#624c3c"),2.0,true)
			draw_circle(p,size_value,ink if available or visited or selected else ink.darkened(0.13),true,-1,true)
			draw_arc(p,size_value-3,0,TAU,26,Color("#f4dcb185"),1.0,true)
			glyph(self,room.kind,p,Color("#f0dcb4"),1.1)
			if room.id == run.trail.back():
				draw_circle(p+Vector2(0,29),3,Color("#345c56"))

func _compass(at: Vector2, radius: float) -> void:
	var ink := Color("#6b534340")
	draw_arc(at,radius,0,TAU,48,ink,1,true)
	draw_arc(at,radius-5,0,TAU,42,ink,1,true)
	for i in range(8):
		var angle := TAU * i / 8
		var ray := Vector2.from_angle(angle)
		draw_line(at+ray*9,at+ray*(radius+8),ink,1,true)
	var star := PackedVector2Array()
	for i in range(8):
		star.append(at + Vector2.from_angle(TAU*i/8.0) * (radius*0.8 if i%2==0 else radius*0.18))
	draw_colored_polygon(star,ink)

static func glyph(canvas: CanvasItem, kind: String, p: Vector2, ink: Color, zoom := 1.0) -> void:
	var shapes := {
		"gate":[[[-8,9],[-8,-2],[0,-10],[8,-2],[8,9]],[[0,0],[0,8]]],
		"battle":[[[-9,9],[8,-8],[5,-8]],[[9,9],[-8,-8],[-5,-8]],[[-9,3],[-3,9]],[[3,9],[9,3]]],
		"elite":[[[-9,-6],[-5,-10],[0,-7],[5,-10],[9,-6],[8,3],[4,4],[4,8],[-4,8],[-4,4],[-8,3],[-9,-6]],[[-5,-1],[-3,-1]],[[3,-1],[5,-1]]],
		"boss":[[[-10,-8],[-6,-3],[-5,7],[5,7],[6,-3],[10,-8]],[[0,-11],[6,-3],[0,3],[-6,-3],[0,-11]],[[0,3],[0,11]]],
		"recruit":[[[-8,8],[-8,4],[-4,1],[4,1],[8,4],[8,8],[-8,8]],[[-3,-7],[3,-7],[4,-3],[0,0],[-4,-3],[-3,-7]],[[8,-5],[13,-5]],[[10.5,-8],[10.5,-2]]],
		"spring":[[[0,-10],[7,-1],[7,3],[3,8],[-3,8],[-7,3],[-7,-1],[0,-10]],[[-3,3],[0,5],[4,2]]],
		"treasure":[[[-10,-3],[-6,-7],[6,-7],[10,-3],[7,7],[-7,7],[-10,-3],[10,-3]],[[0,-3],[0,2]]],
		"event":[[[0,-9],[7,-6],[7,5],[0,8],[-7,5],[-7,-6],[0,-9]],[[0,-4],[0,2]],[[0,5],[0,6]]],
		"shop":[[[-8,8],[-8,-1],[8,-1],[8,8],[-8,8]],[[-10,-1],[-7,-7],[7,-7],[10,-1]],[[0,3],[0,8]]],
		"rest":[[[0,-10],[2,-5],[1,-1],[6,-3],[8,3],[3,8],[-4,8],[-8,3],[-4,-4],[-3,1],[0,-10]]],
		"mystery":[[[-5,-5],[-3,-8],[4,-8],[6,-5],[5,-2],[0,1],[0,4]],[[0,7],[0,9]]]
	}
	for shape in shapes[kind]:
		var vertices := PackedVector2Array()
		for v in shape:
			vertices.append(p + Vector2(v[0],v[1])*zoom)
		canvas.draw_polyline(vertices,ink,1.75,true)


