extends Node2D
@onready var menu_intro: AnimatedSprite2D = $CanvasLayer/Control/TextureRect/menu_intro

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menu_intro.play()
	await menu_intro.animation_finished
	menu_intro.visible = false
	#await get_tree().create_timer(3).timeout
	get_tree().change_scene_to_file("res://scenes/SplashScreen.tscn")
