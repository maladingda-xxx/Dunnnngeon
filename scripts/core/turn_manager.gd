extends RefCounted

static func order(heroes: Array, enemies: Array) -> Array:
	var units := (heroes + enemies).filter(func(unit): return unit.hp > 0)
	units.sort_custom(func(a, b):
		var speed_a := int(a.speed) - (3 if a.stress >= 70 else 0)
		var speed_b := int(b.speed) - (3 if b.stress >= 70 else 0)
		return a.uid < b.uid if speed_a == speed_b else speed_a > speed_b
	)
	return units

