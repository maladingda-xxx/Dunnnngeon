extends RefCounted

const Content = preload("res://scripts/core/content.gd")
static var entries: Dictionary
static var textures: Dictionary

static func _entry(id: String) -> Dictionary:
	if entries.is_empty():
		entries = Content.read("res://data/atlas.json")
		entries.merge(Content.read("res://data/unit_art.json"))
	return entries.get(id,{})

static func frame_count(id: String, clip := "idle") -> int:
	var entry := _entry(id)
	if clip == "idle":
		return int(entry.get("frames",1))
	return int(entry.get("clips",{}).get(clip,{}).get("frames",0))

static func faces_left(id: String) -> bool:
	return _entry(id).get("faces_left",false)

static func palette(id: String) -> String:
	return _entry(id).get("palette","")

static func display_width(id: String, fallback: float) -> float:
	return float(_entry(id).get("display_width",fallback))

static func clip_offset(id: String, clip: String) -> Vector2:
	var entry := _entry(id)
	var animation: Dictionary = entry.get("clips",{}).get(clip,{})
	if not animation.has("region"):
		return Vector2.ZERO
	var idle: Array = entry.region
	var bounds: Array = animation.region
	var adjustment: Array = animation.get("offset",[0,0])
	return Vector2(bounds[0]-idle[0]+adjustment[0],bounds[1]-idle[1]+adjustment[1])

static func release_frame(id: String, clip: String) -> int:
	var animation: Dictionary = _entry(id).get("clips",{}).get(clip,{})
	return int(animation.get("release",mini(2,frame_count(id,clip)-1)))

static func sprite(id: String, frame := 0, portrait := false, clip := "idle") -> AtlasTexture:
	var entry := _entry(id)
	if entry.is_empty():
		return null
	var count := frame_count(id,clip)
	if count == 0:
		return null
	var animation: Dictionary = entry.get("clips",{}).get(clip,{})
	var atlas: Dictionary = animation if animation.has("source") else entry
	var first := int(animation.get("start",0))
	var frame_index := first + posmod(frame,count)
	var region_key := "portrait_region" if portrait and atlas.has("portrait_region") else "region"
	var key := "%s:%s:%d:%s" % [id,clip,frame_index,region_key]
	if textures.has(key):
		return textures[key]
	var bounds: Array = atlas[region_key]
	var column := frame_index
	var row := 0
	if atlas.has("columns"):
		var columns := int(atlas.columns)
		column = frame_index % columns
		row = floori(float(frame_index) / columns)
	var left := int(bounds[0]) + column * int(atlas.get("stride",entry.get("stride",0)))
	var row_offsets: Array = atlas.get("row_offsets",[0])
	var top := int(bounds[1]) + int(row_offsets[row])
	var texture := AtlasTexture.new()
	texture.atlas = load(atlas.source)
	texture.region = Rect2(left,top,bounds[2],bounds[3])
	texture.filter_clip = true
	textures[key] = texture
	return texture

