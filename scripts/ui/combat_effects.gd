extends Node2D

const Assets = preload("res://scripts/core/asset_catalog.gd")

func dust(at: Vector2) -> void:
	_sprite_clip("Combat_Dust",at-Vector2(0,10),1.1,Color("#a39994"),0.034)

func heal(at: Vector2, enemy: bool) -> void:
	var art := "Combat_Heal_Red" if enemy else "Combat_Heal_Blue"
	_sprite_clip(art,at-Vector2(0,48),0.9,Color.WHITE,0.04)

func travel(from: Vector2, to: Vector2, arrow: bool, tint: Color, duration: float) -> Tween:
	var trail := Line2D.new()
	trail.width = 2.0 if arrow else 4.0
	trail.default_color = tint
	trail.modulate.a = 0.68
	add_child(trail)
	var head: Node2D
	if arrow:
		var texture := Sprite2D.new()
		texture.texture = Assets.sprite("Combat_Arrow")
		texture.texture_filter = TEXTURE_FILTER_NEAREST
		texture.rotation = (to-from).angle()
		head = texture
	else:
		var light := Polygon2D.new()
		light.polygon = PackedVector2Array([Vector2(-8,0),Vector2(0,-6),Vector2(8,0),Vector2(0,6)])
		light.color = tint.lightened(0.65)
		head = light
	head.position = from
	add_child(head)
	var motion := create_tween()
	motion.tween_method(func(progress: float):
		head.position = from.lerp(to,progress).round()
		trail.points = PackedVector2Array([from.lerp(to,maxf(0,progress-0.24)).round(),head.position])
	,0.0,1.0,duration)
	motion.tween_callback(head.queue_free)
	motion.tween_callback(trail.queue_free)
	return motion

func impact(at: Vector2, direction: float, tint: Color, heavy: bool, magic: bool) -> void:
	if magic or heavy:
		_sprite_clip("Combat_Burst",at,1.1 if heavy else 0.82,tint.lightened(0.48),0.032)
	for index in range(12 if heavy else 7):
		var angle := lerpf(-1.65,1.65,float(index % 7)/6.0)
		var outward := Vector2(cos(angle)*direction,sin(angle))
		var ray := Line2D.new()
		ray.position = at + outward*9.0
		ray.points = PackedVector2Array([Vector2.ZERO,outward*(7+(index%3)*4)])
		ray.width = 2.0 if index%3 == 1 else 3.0
		ray.default_color = Color("#fff3cb") if index%3 == 0 else tint
		add_child(ray)
		var flight := create_tween().set_parallel(true)
		flight.tween_property(ray,"position",at+outward*(30+(index%4)*10),0.19).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		flight.tween_property(ray,"modulate:a",0.0,0.16).set_delay(0.04)
		flight.chain().tween_callback(ray.queue_free)

func _sprite_clip(id: String, at: Vector2, art_scale: float, tint: Color, frame_time: float) -> void:
	var stamp := Sprite2D.new()
	stamp.texture = Assets.sprite(id)
	stamp.texture_filter = TEXTURE_FILTER_NEAREST
	stamp.position = at.round()
	stamp.scale = Vector2.ONE * art_scale
	stamp.modulate = tint
	add_child(stamp)
	var playback := create_tween()
	for frame in range(1,Assets.frame_count(id)):
		playback.tween_interval(frame_time)
		playback.tween_callback(stamp.set_texture.bind(Assets.sprite(id,frame)))
	playback.tween_property(stamp,"modulate:a",0.0,frame_time*2.0)
	playback.tween_callback(stamp.queue_free)
