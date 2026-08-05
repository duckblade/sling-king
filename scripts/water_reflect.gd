class_name WaterController extends ColorRect

@export var water_surface_node: Node2D
@export var reflection_viewport: SubViewport

var ripple_active : bool
var ripple_age : float
var ripple_world_pos : Vector2

func _ready() -> void:
	ripple_active = false
	ripple_age = -1.0
	ripple_world_pos = Vector2.ZERO

	if reflection_viewport:
		reflection_viewport.world_2d = get_viewport().world_2d
		var mat := material as ShaderMaterial
		mat.set_shader_parameter("reflection_tex", reflection_viewport.get_texture())
		mat.set_shader_parameter("ripple_age", -1.0)
		mat.set_shader_parameter("ripple_center", Vector2(-1000, -1000))
		mat.set_shader_parameter("ripple_lifetime", 2.5)   # <-- add this
		mat.set_shader_parameter("ripple_speed", 0.35)      # optional but safer
		mat.set_shader_parameter("ripple_width", 0.015)
		mat.set_shader_parameter("ripple_strength", 0.015)
		_sync_viewport_size()
		get_viewport().size_changed.connect(_sync_viewport_size)

func _sync_viewport_size() -> void:
	if reflection_viewport:
		reflection_viewport.size = get_viewport().get_visible_rect().size

func _process(delta: float) -> void:
	if not water_surface_node:
		return
	var cam := get_viewport().get_camera_2d()
	if not cam:
		return
	var mat := material as ShaderMaterial
	var canvas_transform := get_viewport().get_canvas_transform()
	var vp_size: Vector2 = get_viewport_rect().size

	if ripple_active:
		ripple_age += delta
		if ripple_age >= mat.get_shader_parameter("ripple_lifetime"):
			ripple_active = false
			mat.set_shader_parameter("ripple_age", -1.0)
		else:
			mat.set_shader_parameter("ripple_age", ripple_age)
			# reproject world position to screen UV every frame
			var ripple_screen_pos := canvas_transform * ripple_world_pos
			mat.set_shader_parameter("ripple_center", ripple_screen_pos / vp_size)

	var screen_pos := canvas_transform * water_surface_node.global_position
	var uv_y := screen_pos.y / vp_size.y
	var world_offset_uv: Vector2 = -canvas_transform.origin / vp_size
	mat.set_shader_parameter("water_level_uv", uv_y)
	mat.set_shader_parameter("world_offset_uv", world_offset_uv)

func create_ripple(world_position: Vector2) -> void:
	ripple_world_pos = world_position
	ripple_age = 0.0
	ripple_active = true
	
func reset_ripple() -> void:
	ripple_active = false
	ripple_age = -1.0
	ripple_world_pos = Vector2.ZERO
	var mat := material as ShaderMaterial
	mat.set_shader_parameter("ripple_age", -1.0)
	mat.set_shader_parameter("ripple_center", Vector2(-1000, -1000))	
