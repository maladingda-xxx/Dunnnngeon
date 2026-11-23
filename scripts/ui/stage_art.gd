extends Control

const Assets = preload("res://scripts/core/asset_catalog.gd")
var mode := "title"

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	texture_filter = TEXTURE_FILTER_NEAREST

func _draw() -> void:
	draw_rect(Rect2(0,0,1280,720),Color("#0b1019"))
	match mode:
		"title": _ruin(false)
		"combat": _ruin(true)
		_: _archive()

func _poly(points: Array, hex: String) -> void:
	var vertices := PackedVector2Array()
	for pos in points:
		vertices.append(Vector2(pos[0],pos[1]))
	draw_colored_polygon(vertices,Color(hex))

func _block(x: float, y: float, w: float, h: float, hex: String) -> void:
	draw_rect(Rect2(x,y,w,h),Color(hex))

func _archive() -> void:
	for y in range(84,680,16):
		var ratio := float(y - 84) / 596.0
		draw_rect(Rect2(0,y,1280,16),Color("#171d28").lerp(Color("#0d111b"),ratio))
	var rng := RandomNumberGenerator.new()
	rng.seed = 1450
	for i in range(820):
		var x := rng.randi_range(0,1279)
		var y := rng.randi_range(0,719)
		draw_rect(Rect2(x,y,2,2),Color("#b1a68a19"))
	for cx in [86,1190]:
		for r in [54,62,105,113,179]:
			draw_arc(Vector2(cx,580),r,0,TAU,64,Color("#ba9c7826"),1.0,true)
		draw_line(Vector2(cx,86),Vector2(cx,720),Color("#ba9c781d"))
		draw_line(Vector2(cx-110,580),Vector2(cx+110,580),Color("#ba9c781d"))

func _ruin(combat: bool) -> void:
	var floor_y := 418 if combat else 606
	var center := 641 if combat else 946
	for y in range(0, floor_y+6,4):
		var fade := float(y) / floor_y
		draw_rect(Rect2(0,y,1280,4),Color("#10121f").lerp(Color("#233947"),fade * fade))
	_poly([[0,0],[380,0],[420,88],[349,139],[301,251],[236,269],[157,377],[0,429]],"#111522")
	_poly([[1280,0],[1043,0],[1012,96],[1099,159],[1138,293],[1228,338],[1280,400]],"#171926")
	_poly([[0,0],[1280,0],[1280,63],[1172,69],[1117,120],[1031,121],[947,63],[865,81],[771,38],[704,63],[607,51],[527,96],[476,78],[397,122],[344,99],[273,154],[161,136],[117,171],[0,161]],"#10121d")
	var rng := RandomNumberGenerator.new()
	rng.seed = 172
	var masonry := Assets.sprite("Tiles_24")
	for column in range(2,18):
		var x := column * 72 - 53
		if abs(x-center) > (228 if combat else 280):
			masonry.draw_rect(get_canvas_item(),Rect2(x,floor_y-124,72,72),false,Color("#70828d44"))
			masonry.draw_rect(get_canvas_item(),Rect2(x-8,floor_y-52,72,56),false,Color("#68778646"))
	for i in range(720):
		var x := rng.randi_range(0,319)*4
		var y := rng.randi_range(12,floor_y/4)*4
		var hue := Color("#829ea218") if i % 5 == 0 else Color("#05091125")
		draw_rect(Rect2(x,y,rng.randi_range(1,4)*4,4),hue)
	for offset in [-387,-241,243,388]:
		_pillar(center + offset, floor_y, floor_y * 0.67,36 if absi(offset) > 300 else 24)
	_arch(center,floor_y,204 if combat else 266,263 if combat else 383)
	if combat:
		for x in [117,1162]:
			_torch(x,floor_y-121)
	else:
		for x in [center-208,center+208]:
			_torch(x,floor_y-136)
	for i in range(18):
		var ghost_x := center + rng.randi_range(-144,144)
		var y := floor_y - rng.randi_range(12,140)
		draw_rect(Rect2(ghost_x,y,rng.randi_range(1,3)*2,2),Color("#79b9b65b"))
	_block(0,floor_y,1280,720-floor_y,"#121a24")
	_block(0,floor_y,1280,4,"#43606a")
	_block(0,floor_y+4,1280,8,"#242e3a")
	for i in range(130):
		var x := rng.randi_range(0,319)*4
		var y := floor_y + rng.randi_range(2, (720-floor_y)/4 - 2)*4
		var perspective := maxi(12,roundi((y-floor_y)*0.6))
		_block(x,y,rng.randi_range(8,perspective)*2,2,"#273640" if i%4 == 0 else "#0c141d")
	for x in [10,1269]:
		_pillar(x,floor_y,440,50)
	_poly([[0,0],[60,0],[47,201],[24,313],[20,floor_y],[0,floor_y]],"#0b0f19")
	_poly([[1280,0],[1232,0],[1243,152],[1257,303],[1260,floor_y],[1280,floor_y]],"#0b0f19")
	if not combat:
		for i in range(25):
			draw_rect(Rect2(i*20,0,20,720),Color(0.026,0.036,0.065,1.0-float(i)/26.0))
	for i in range(36):
		var x := rng.randi_range(0,1260)
		var y := rng.randi_range(100,floor_y-30)
		draw_rect(Rect2(x,y,2,2),Color("#d4a475") if i%6 == 0 else Color("#68989966"))

func _pillar(x: int, base: int, height: int, radius: int) -> void:
	_block(x-radius,base-height,2*radius,height,"#1a2532")
	_block(x-radius-8,base-height,2*radius+16,14,"#293540")
	_block(x-radius-7,base-19,2*radius+14,19,"#141b28")
	_block(x-radius+4,base-height+19,4,height-44,"#33454f")
	_block(x+radius-10,base-height+13,10,height-32,"#111923")
	for y in range(base-height+40,base-19,23):
		_block(x-radius,y,2*radius,2,"#101824")
		_block(x-radius+9,y+2,12,2,"#293940")

func _arch(cx: int, base: int, width: int, height: int) -> void:
	var half := width
	var shoulder := base - height * 0.63
	var top := base - height
	_poly([[cx-half,base],[cx-half,shoulder],[cx-half+40,top+48],[cx-54,top+18],[cx,top-13],[cx+54,top+18],[cx+half-40,top+48],[cx+half,shoulder],[cx+half,base]],"#263542")
	_poly([[cx-half+8,base],[cx-half+8,shoulder],[cx-half+46,top+52],[cx-49,top+23],[cx,top-4],[cx+49,top+23],[cx+half-46,top+52],[cx+half-8,shoulder],[cx+half-8,base]],"#314754")
	_poly([[cx-half+20,base],[cx-half+20,shoulder+5],[cx-half+59,top+64],[cx-43,top+34],[cx,top+11],[cx+43,top+34],[cx+half-59,top+64],[cx+half-20,shoulder+5],[cx+half-20,base]],"#131e2b")
	var inner := half - 44
	_poly([[cx-inner,base],[cx-inner,shoulder+17],[cx-inner+34,top+77],[cx,top+41],[cx+inner-34,top+77],[cx+inner,shoulder+17],[cx+inner,base]],"#0c1724")
	for i in range(17):
		var y := base - 5 - i*4
		draw_rect(Rect2(cx-inner+8,y,inner*2-16,4),Color("#488c92").lerp(Color("#172c38"),float(i)/16.0))
	for side in [-1,1]:
		for y in range(roundi(shoulder)+16,base-8,24):
			_block(cx + side * (half-11) - 9,y,18,2,"#111b29")
		_block(cx + side * (half-28) - 12,base-9,26,9,"#3c5660")
		_block(cx + side * (inner-10),base-106,2,88,"#2e6975")
	draw_arc(Vector2(cx, top+102),27,0,TAU,24,Color("#578388"),2.0,true)
	draw_arc(Vector2(cx, top+102),18,0,TAU,20,Color("#426270"),1.0,true)
	_poly([[cx,top+86],[cx+9,top+102],[cx,top+118],[cx-9,top+102]],"#71a7a3")

func _torch(x: int, y: int) -> void:
	for i in range(10,0,-1):
		draw_circle(Vector2(x,y),i*6,Color(0.86,0.42,0.18,0.016))
	_block(x-6,y+8,12,17,"#1b1820")
	_block(x-3,y+7,6,21,"#80563c")
	_poly([[x-8,y+9],[x-12,y-1],[x-7,y-11],[x-5,y-4],[x+1,y-22],[x+7,y-11],[x+12,y+2],[x+8,y+9]],"#aa583d")
	_poly([[x-5,y+7],[x-6,y+1],[x-1,y-4],[x+1,y-13],[x+7,y+1],[x+4,y+7]],"#f3b76a")

