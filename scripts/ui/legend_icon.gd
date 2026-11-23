extends Control

const MapView = preload("res://scripts/ui/map_controller.gd")
var kind := "gate"

func _draw() -> void:
	var ink := Color(MapView.COLORS[kind]).lightened(0.27)
	draw_circle(Vector2(15,15),14,ink.darkened(0.46),true,-1,true)
	draw_arc(Vector2(15,15),13.5,0,TAU,30,ink,1.0,true)
	MapView.glyph(self,kind,Vector2(15,15),Color("#e2c9a0"),0.88)

