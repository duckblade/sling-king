extends VirtualJoystick


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var is_touch := DisplayServer.is_touchscreen_available()
	visible = is_touch
	set_process(is_touch)
	set_process_input(is_touch)
	set_physics_process(is_touch)
