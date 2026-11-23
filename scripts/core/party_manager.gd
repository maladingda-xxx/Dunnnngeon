extends RefCounted

const Content = preload("res://scripts/core/content.gd")
const LIMIT := 4

static func make(id: String, uid: String, depth := 1, book := "heroes") -> Dictionary:
	var source := Content.definition(book,id)
	var health := int(source.hp)
	var power := int(source.attack)
	if book == "enemies":
		health += maxi(0,depth - 1) * int(source.get("growth",2))
		power += floori(float(depth - 1) / 3)
	return {"id":id,"uid":uid,"name":source.name,"role":source.role,"sprite":source.sprite,
		"hp":health,"max_hp":health,"attack":power,"defense":int(source.defense),"speed":int(source.speed),
		"crit":float(source.get("crit",0.08)),"dodge":float(source.get("dodge",0.05)),
		"stress":0,"level":1,"statuses":{},"cooldowns":{},"skills":source.get("skills",[]),
		"passive":source.get("passive",""),"ai":source.get("ai",""),"gear":[],"turns":0}

static func living(party: Array) -> Array:
	return party.filter(func(hero): return hero.hp > 0)

static func heal(hero: Dictionary, amount: int) -> int:
	if hero.hp <= 0:
		return 0
	var healed := mini(amount, int(hero.max_hp) - int(hero.hp))
	hero.hp += healed
	return healed

static func stress(hero: Dictionary, amount: int) -> void:
	hero.stress = clampi(int(hero.stress) + amount, 0, 100)

static func upgrade(hero: Dictionary) -> void:
	hero.level += 1
	hero.max_hp += 5
	hero.attack += 2
	heal(hero, 5)

