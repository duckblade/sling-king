extends Area2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var timer: Timer = $Timer

var water_reflect: WaterController
var reflection_camera: Camera2D

func _ready() -> void:
	water_reflect = get_tree().get_first_node_in_group("water_reflect")
	reflection_camera = get_tree().get_first_node_in_group("reflection_camera")

func _on_body_entered(body: Node2D) -> void:
	if not body.has_method("set_dead"):
		return
	set_deferred("monitoring", false)
	audio_stream_player_2d.play()
	GameManager.kill_player(body)
	water_reflect.create_ripple(body.global_position)
	if reflection_camera:
		reflection_camera.stop_tracking()
	timer.start()

func _on_timer_timeout() -> void:
	set_deferred("monitoring", true)
	water_reflect.reset_ripple()
