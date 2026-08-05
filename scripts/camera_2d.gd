extends Camera2D

var frozen := false
var original_local_position: Vector2

func _ready() -> void:
	original_local_position = position

func stop_tracking() -> void:
	if frozen:
		return
	frozen = true
	var gp := global_position
	top_level = true
	global_position = gp
	reset_smoothing()   # <-- kill any in-flight smoothing lag instantly

func resume_tracking() -> void:
	if not frozen:
		return
	frozen = false
	top_level = false
	position = original_local_position
	reset_smoothing()   # <-- also snap cleanly when resuming, avoid a smoothing "catch-up" pop
