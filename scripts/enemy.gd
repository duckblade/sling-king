extends Node2D

const SPEED = 40
var direction = 1
var is_dying = false
const COIN = preload("uid://b72ihqmkwc57n")

@onready var ray_cast_2dl: RayCast2D = $CharacterBody2D2/RayCast2DL
@onready var ray_cast_2dr: RayCast2D = $CharacterBody2D2/RayCast2DR
@onready var animated_sprite_2d: AnimatedSprite2D = $CharacterBody2D2/AnimatedSprite2D
@onready var killzone: Area2D = $CharacterBody2D2/Killzone
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x+=direction*SPEED*delta
	
	if (ray_cast_2dr.is_colliding()):
		direction=-1
		animated_sprite_2d.flip_h = true
	if(ray_cast_2dl.is_colliding()):
		direction=1	 
		animated_sprite_2d.flip_h = false



func _on_character_body_2d_2_body_entered(body: Node2D) -> void:
	if is_dying:
		return
	is_dying = true
	body.velocity.y = -250
	killzone.set_deferred("monitoring", false)
	animated_sprite_2d.play("hit")
	audio_stream_player_2d.play()
	await animated_sprite_2d.animation_finished
	spawn_coin()
	queue_free()

	
func spawn_coin():
	var coin = COIN.instantiate()
	coin.global_position = global_position + Vector2(0,-8)
	get_tree().current_scene.get_node("coins").add_child(coin)
	print("coin spawned!")
