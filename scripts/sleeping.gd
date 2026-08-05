extends Node2D

const COIN = preload("uid://b72ihqmkwc57n")
@onready var animated_sprite_2d: AnimatedSprite2D = $CharacterBody2D/AnimatedSprite2D
var hits_taken = 0
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var collision_shape_2d: CollisionShape2D = $CharacterBody2D/CollisionShape2D

	
func spawn_coin():
	var coin = COIN.instantiate()
	coin.global_position = global_position + Vector2(0,-8)
	get_tree().current_scene.get_node("coins").add_child(coin)
	print("coin spawned!")


func _on_character_body_2d_body_entered(body: Node2D) -> void:
	var is_falling_from_above = body.global_position.y < global_position.y and body.velocity.y > 0
	if is_falling_from_above:
		body.velocity.y = -250
		animated_sprite_2d.play("hit")
		if hits_taken >= 5:
			await get_tree().create_timer(0.4).timeout
			spawn_coin()
			queue_free()
		else:
			get_node("CharacterBody2D/CollisionShape2D").set_deferred("disabled", true)
			await get_tree().create_timer(0.6).timeout
			hits_taken += 1
			audio_stream_player_2d.play()
			animated_sprite_2d.play("default")
			get_node("CharacterBody2D/CollisionShape2D").set_deferred("disabled", false)


	
