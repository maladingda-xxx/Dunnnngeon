extends RefCounted

static func choose(actor: Dictionary, allies: Array, heroes: Array, rng: RandomNumberGenerator, phase: int) -> Array:
	var target: Dictionary = heroes[rng.randi_range(0,heroes.size() - 1)]
	var wound: Dictionary = allies[0]
	for ally in allies:
		if float(ally.hp) / ally.max_hp < float(wound.hp) / wound.max_hp:
			wound = ally
	var skill := {"name":"撕击","mode":"enemy","power":1.0}
	match actor.ai:
		"boss":
			if phase == 2 and int(actor.turns) % 2 == 0:
				return [{"name":"无灯之潮","mode":"enemies","motion":"magic","power":0.95,"effect":"bleed","amount":3,"duration":2},{}]
			if phase == 1 and int(actor.turns) % 3 == 0:
				return [{"name":"封蜡外壳","mode":"self","effect":"shield","amount":15,"duration":2},actor]
			skill = {"name":"覆墓钟声","mode":"enemy","motion":"magic","power":1.35,"stress":9}
		"support":
			if wound.hp <= wound.max_hp - 8 and int(actor.turns) % 2 == 0:
				return [{"name":"残灯回响","mode":"ally","heal":10},wound]
			skill = {"name":"腐蚀祷词","mode":"enemy","motion":"magic","power":0.8,"effect":"weaken","amount":2,"duration":2}
		"guard":
			if int(actor.turns) % 3 == 1:
				return [{"name":"楔石掩护","mode":"ally","effect":"shield","amount":9,"duration":2},wound]
			skill = {"name":"重压","mode":"enemy","power":1.2}
		"poison":
			if int(actor.turns) % 2 == 1:
				skill = {"name":"毒牙","mode":"enemy","power":0.9,"effect":"poison","amount":3,"duration":2}
			if actor.id == "wraith":
				skill.motion = "magic"
	return [skill,target]

