extends RefCounted

const Assets = preload("res://scripts/core/asset_catalog.gd")
const UNIT_SHADER = preload("res://scripts/ui/combat_flash.gdshader")
const PIXEL_FONT = preload("res://assets/fonts/fusion-pixel-12px-proportional-zh_hans.otf")
const INK := Color("#10131c")
const GOLD := Color("#d1ae77")
const PALE := Color("#eee0c7")
const MUTED := Color("#a49e99")
const TEAL := Color("#7dbab4")
const RED := Color("#bf6b65")
const LINE := Color("#524539")
static var display_font: FontVariation

static func font(face: String) -> Font:
	if face != "display":
		return PIXEL_FONT
	if display_font == null:
		display_font = FontVariation.new()
		display_font.base_font = PIXEL_FONT
		display_font.spacing_glyph = 1
	return display_font

static func at(parent: Node, control: Control, x: float, y: float, w: float, h: float) -> Control:
	parent.add_child(control)
	control.position = Vector2(x,y)
	control.size = Vector2(w,h)
	return control

static func label(parent: Node, value: String, x: float, y: float, w: float, h: float, px := 16, tint := PALE, face := "body", align := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var node := Label.new()
	node.text = value
	node.horizontal_alignment = align
	node.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.add_theme_font_override("font",font(face))
	node.add_theme_font_size_override("font_size",px)
	node.add_theme_color_override("font_color",tint)
	at(parent,node,x,y,w,h)
	return node

static func style(fill: Color, edge: Color, width := 1, radius := 0) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = edge
	box.set_border_width_all(width)
	box.set_corner_radius_all(radius)
	box.content_margin_left = 10
	box.content_margin_right = 10
	box.content_margin_top = 4
	box.content_margin_bottom = 4
	return box

static func panel(parent: Node, x: float, y: float, w: float, h: float, fill := Color("#131821"), edge := LINE) -> Panel:
	var node := Panel.new()
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.add_theme_stylebox_override("panel",style(fill,edge))
	at(parent,node,x,y,w,h)
	return node

static func rule(parent: Node, x: float, y: float, w: float, h := 1.0, color := LINE) -> ColorRect:
	var node := ColorRect.new()
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.color = color
	at(parent,node,x,y,w,h)
	return node

static func button(parent: Node, value: String, x: float, y: float, w: float, h: float, action: Callable, accent := false) -> Button:
	var node := Button.new()
	node.text = value
	node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	node.add_theme_font_override("font",font("body"))
	node.add_theme_font_size_override("font_size",16)
	node.add_theme_color_override("font_color",PALE)
	node.add_theme_color_override("font_disabled_color",Color("#7e7981"))
	node.add_theme_color_override("font_hover_color",Color("#fff0d0"))
	node.add_theme_stylebox_override("normal",style(Color("#51382c") if accent else Color("#1c202a"),Color("#a37c50") if accent else LINE))
	node.add_theme_stylebox_override("hover",style(Color("#675037") if accent else Color("#32343d"),GOLD))
	node.add_theme_stylebox_override("pressed",style(Color("#382e24"),GOLD))
	node.add_theme_stylebox_override("disabled",style(Color("#1b1c24"),Color("#38323a")))
	var focus := style(Color.TRANSPARENT,TEAL)
	focus.draw_center = false
	node.add_theme_stylebox_override("focus",focus)
	if action.is_valid():
		node.pressed.connect(action)
	at(parent,node,x,y,w,h)
	return node

static func sprite(parent: Node, id: String, center_x: float, bottom: float, scale_value := 1.0, tint := Color.WHITE, flipped := false) -> TextureRect:
	return _draw_sprite(parent,Assets.sprite(id),center_x,bottom,scale_value,tint,flipped)

static func _draw_sprite(parent: Node, texture: Texture2D, center_x: float, bottom: float, scale_value: float, tint: Color, flipped: bool) -> TextureRect:
	var node := TextureRect.new()
	if texture == null:
		return node
	node.texture = texture
	node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	node.stretch_mode = TextureRect.STRETCH_SCALE
	node.modulate = tint
	node.flip_h = flipped
	var extent := (node.texture.get_size() * scale_value).round()
	at(parent,node,roundf(center_x - extent.x / 2.0),roundf(bottom - extent.y),extent.x,extent.y)
	return node

static func unit_sprite(parent: Node, id: String, center_x: float, bottom: float, bounds: Vector2, tint := Color.WHITE, face_left := false, portrait := false) -> TextureRect:
	var texture := Assets.sprite(id,0,portrait)
	if texture == null:
		return TextureRect.new()
	if not portrait:
		bounds.x = Assets.display_width(id,bounds.x)
	var extent := texture.get_size()
	var scale_value := minf(bounds.x / extent.x,bounds.y / extent.y)
	var sprite_node := _draw_sprite(parent,texture,center_x,bottom,scale_value,tint,face_left != Assets.faces_left(id))
	if Assets.palette(id) == "forest":
		sprite_node.material = unit_material(true)
	return sprite_node

static func unit_material(forest_palette := false) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = UNIT_SHADER
	material.set_shader_parameter("forest_palette",forest_palette)
	return material

static func unit_portrait(parent: Node, id: String, center_x: float, bottom: float, bounds: Vector2, tint := Color.WHITE, face_left := false) -> TextureRect:
	return unit_sprite(parent,id,center_x,bottom,bounds,tint,face_left,true)

static func bar(parent: Node, x: float, y: float, w: float, h: float, fill: Color) -> ProgressBar:
	var node := ProgressBar.new()
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.show_percentage = false
	node.add_theme_stylebox_override("background",style(Color("#100e17"),Color("#453844")))
	node.add_theme_stylebox_override("fill",style(fill,fill,0))
	at(parent,node,x,y,w,h)
	return node

static func text_block(parent: Node, value: String, x: float, y: float, w: float, h: float, px := 15, tint := MUTED) -> Label:
	var node := label(parent,value,x,y,w,h,px,tint)
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	return node

static func frame(parent: Node, x: float, y: float, w: float, h: float) -> void:
	panel(parent,x,y,w,h)
	for corner in [Vector2(x,y),Vector2(x+w-12,y),Vector2(x,y+h-12),Vector2(x+w-12,y+h-12)]:
		rule(parent,corner.x,corner.y,12,1,Color("#977550"))
		rule(parent,corner.x,corner.y+11,12,1,Color("#977550"))

