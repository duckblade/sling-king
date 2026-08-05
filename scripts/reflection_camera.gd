extends Camera2D
@export var main_camera: Camera2D
@export var water_world_y: float = -70.0

var tracking_enabled: bool = true

func _ready():
	enabled = true

func _physics_process(_delta):
	if not main_camera or not tracking_enabled:
		return

	global_position = Vector2(
		main_camera.global_position.x,
		2.0 * water_world_y - main_camera.global_position.y
	)
	zoom = main_camera.zoom
	rotation = main_camera.rotation

func stop_tracking() -> void:
	if tracking_enabled:
		tracking_enabled = false

func resume_tracking() -> void:
	if !tracking_enabled:
		tracking_enabled = true
