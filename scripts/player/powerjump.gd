extends Node2D

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_body_entered(body: Node2D) -> void:
	if GameManager.get_score() >= 5:
		GameManager.activate_power_up(5)
		audio_stream_player_2d.play()
		print("score="+str(GameManager.score))
		body.activate_pu()
		GameManager.set_checkpoint(body.global_position)
		DialogueManager.show_dialogue_balloon(load("res://assets/dialogue/powerjump.dialogue"), "start")
		MusicManager.play_music("exploration_2")
		await get_tree().create_timer(0.2).timeout
		queue_free()
