extends RefCounted

const BLUE := preload("res://assets/Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/BigBlueButton_Regular.png")
const BLUE_PRESSED := preload("res://assets/Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/BigBlueButton_Pressed.png")
const RED := preload("res://assets/Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/BigRedButton_Regular.png")
const RED_PRESSED := preload("res://assets/Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/BigRedButton_Pressed.png")
const DARK_PAPER := preload("res://assets/Tiny Swords (Free Pack)/UI Elements/UI Elements/Papers/SpecialPaper.png")
const BANNER_PAPER := preload("res://assets/Tiny Swords (Free Pack)/UI Elements/UI Elements/Banners/Banner_Slots.png")
const WOOD := preload("res://assets/Tiny Swords (Free Pack)/UI Elements/UI Elements/Wood Table/WoodTable.png")
const WOOD_SLOTS := preload("res://assets/Tiny Swords (Free Pack)/UI Elements/UI Elements/Wood Table/WoodTable_Slots.png")
const RIBBONS := preload("res://assets/Tiny Swords (Free Pack)/UI Elements/UI Elements/Ribbons/SmallRibbons.png")

static var buttons: Dictionary
static var cards: Dictionary
static var panel: StyleBoxTexture
static var parchment: StyleBoxTexture
static var wood: StyleBoxTexture
static var ribbon: StyleBoxTexture
static var archive: Texture2D

static func prepare() -> void:
	if panel != null:
		return
	# The sheets leave transparent gaps between pieces. Join the trimmed
	# pieces once so StyleBoxTexture can keep the corners at a fixed size.
	var blue := _button_texture(BLUE, false)
	var blue_pressed := _button_texture(BLUE_PRESSED, true)
	var red := _button_texture(RED, false)
	var red_pressed := _button_texture(RED_PRESSED, true)
	var disabled := _box(blue_pressed, Vector4(16, 14, 16, 14), Color("#909299"), 2)
	buttons = {
		false: _button_states(blue, blue_pressed, Color("#9ebdcb"), disabled),
		true: _button_states(red, red_pressed, Color("#b99794"), disabled),
	}
	var dark := _join(DARK_PAPER, [9, 128, 256], [55, 64, 55], [20, 128, 256], [44, 64, 43])
	var paper_margins := Vector4(18, 17, 18, 17)
	panel = _box(dark, paper_margins, Color("#9a9fae"))
	parchment = _box(_map_paper(), Vector4(14, 14, 14, 14), Color.WHITE)
	parchment.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_TILE_FIT
	parchment.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_TILE_FIT
	cards = {
		false: {
			"normal": _box(dark, paper_margins, Color("#919fad")),
			"hover": _box(dark, paper_margins, Color("#b6ccd6")),
			"pressed": _box(dark, paper_margins, Color("#7f929d")),
		},
		true: {
			"normal": _box(dark, paper_margins, Color("#f9d5ad")),
			"hover": _box(dark, paper_margins, Color("#ffe9c7")),
			"pressed": _box(dark, paper_margins, Color("#d8b490")),
		},
	}
	var boards := _join(WOOD, [44, 192, 320], [84, 64, 84], [43, 192, 320], [85, 64, 103])
	wood = _box(boards, Vector4(27, 30, 27, 34), Color("#9697a1"))
	wood.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_TILE_FIT
	wood.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_TILE_FIT
	var cloth := _join(RIBBONS, [2, 128, 256], [62, 64, 62], [4], [60])
	ribbon = _box(cloth, Vector4(31, 0, 31, 0), Color("#b4d1d9"))
	archive = ImageTexture.create_from_image(WOOD_SLOTS.get_image().get_region(Rect2i(24,30,144,128)))

static func _map_paper() -> ImageTexture:
	var paper := BANNER_PAPER.get_image().get_region(Rect2i(5,5,185,183))
	var base := Color("#d6bd95")
	# Keep the torn edges while softening the grain behind the route lines.
	for y in paper.get_height():
		for x in paper.get_width():
			var pixel := paper.get_pixel(x,y)
			var tint := base.lerp(pixel,0.35)
			tint.a = pixel.a
			paper.set_pixel(x,y,tint)
	return ImageTexture.create_from_image(paper)

static func _button_texture(sheet: Texture2D, pressed: bool) -> Texture2D:
	var sides := 50 if pressed else 45
	return _join(sheet, [64 - sides, 128, 256], [sides, 64, sides], [17, 128, 256], [47, 64, 49 if pressed else 47])

static func _button_states(normal: Texture2D, pressed: Texture2D, tint: Color, disabled: StyleBoxTexture) -> Dictionary:
	var margins := Vector4(15, 12, 15, 15)
	var pressed_margins := Vector4(16, 14, 16, 14)
	return {
		"normal": _box(normal, margins, tint, -2),
		"hover": _box(normal, margins, tint.lightened(0.24), -2),
		"pressed": _box(pressed, pressed_margins, tint, 2),
		"hover_pressed": _box(pressed, pressed_margins, tint.lightened(0.18), 2),
		"disabled": disabled,
	}

static func _box(texture: Texture2D, margins: Vector4, tint: Color, text_offset := 0) -> StyleBoxTexture:
	var box := StyleBoxTexture.new()
	box.texture = texture
	box.modulate_color = tint
	box.texture_margin_left = margins.x
	box.texture_margin_top = margins.y
	box.texture_margin_right = margins.z
	box.texture_margin_bottom = margins.w
	box.content_margin_left = 8
	box.content_margin_right = 8
	box.content_margin_top = 4 + text_offset
	box.content_margin_bottom = 4 - text_offset
	return box

static func _join(sheet: Texture2D, columns: Array[int], widths: Array[int], rows: Array[int], heights: Array[int]) -> ImageTexture:
	var source := sheet.get_image()
	var width := 0
	var height := 0
	for extent in widths:
		width += extent
	for extent in heights:
		height += extent
	var joined := Image.create_empty(width, height, false, source.get_format())
	var y := 0
	for row in rows.size():
		var x := 0
		for column in columns.size():
			var region := Rect2i(columns[column], rows[row], widths[column], heights[row])
			joined.blit_rect(source, region, Vector2i(x, y))
			x += widths[column]
		y += heights[row]
	joined.resize(roundi(width / 2.0), roundi(height / 2.0), Image.INTERPOLATE_NEAREST)
	return ImageTexture.create_from_image(joined)
