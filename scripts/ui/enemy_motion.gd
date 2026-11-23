extends RefCounted

# Pose values are fractions of the sprite crop: upper body sway, rise,
# wing sweep, and lower body sway. Negative X moves towards the opponent.
const PROFILES := {
	"sentinel": {
		"hz": 1.15, "idle_hz": 0.76,
		"idle": Vector4(0.010,-0.017,0,0.007), "rush": Vector4(0.03,-0.045,0,0.014),
		"strike": Vector4(-0.14,0.045,0,0.025),
	},
	"bat": {"hz": 3.4, "idle": Vector4(0,-0.025,0.29,0), "strike": Vector4(-0.055,0.075,0.30,0)},
	"viper": {
		"hz": 1.15, "idle_hz": 0.67,
		"idle": Vector4(0.027,-0.021,0,0), "rush": Vector4(0.077,-0.075,0,0),
		"strike": Vector4(-0.23,0.11,0,0),
	},
	"wraith": {"hz": 1.15, "idle": Vector4(0.04,-0.06,0,0.09), "strike": Vector4(-0.11,-0.09,0,0.15)},
	"idol": {"hz": 0.72, "idle": Vector4(0.018,-0.06,0,0), "strike": Vector4(-0.11,0.11,0,0)},
	"priest": {"hz": 0.72, "idle": Vector4(0.023,-0.045,0,0.062), "strike": Vector4(-0.065,-0.10,0,0.13)},
}

var material: ShaderMaterial
var idle_extent: Vector4
var rush_extent: Vector4
var strike: Vector4
var pose := Vector4.ZERO
var idle_frequency: float
var rush_frequency: float

static func attach(id: String, art: TextureRect) -> RefCounted:
	var profile: Dictionary = PROFILES.get(id,{})
	if profile.is_empty():
		return null
	var motion := new()
	motion.material = art.material
	motion.idle_extent = profile.idle
	motion.rush_extent = profile.get("rush",profile.idle)
	motion.strike = profile.strike
	motion.idle_frequency = profile.get("idle_hz",profile.hz)
	motion.rush_frequency = float(profile.hz) * (3.0 if motion.rush_extent.z == 0.0 else 1.0)
	var texture: AtlasTexture = art.texture
	var region := texture.region
	var sheet := texture.atlas.get_size()
	motion.material.set_shader_parameter("deform_region",Vector4(region.position.x/sheet.x,region.position.y/sheet.y,region.size.x/sheet.x,region.size.y/sheet.y))
	motion.material.set_shader_parameter("deform_size",art.size)
	return motion

func loop(elapsed: float, rushing: bool) -> void:
	# Stepped poses preserve the pixel-art rhythm without moving the hitboxes.
	var frequency := rush_frequency if rushing else idle_frequency
	var extent := rush_extent if rushing else idle_extent
	var phase := floorf(elapsed * 16.0) / 16.0 * TAU * frequency
	var next := Vector4(sin(phase),cos(phase),sin(phase),sin(phase-PI/3.0)) * extent
	set_pose(next)

func set_pose(value: Vector4) -> void:
	if value == pose:
		return
	pose = value
	material.set_shader_parameter("deformation",value)
