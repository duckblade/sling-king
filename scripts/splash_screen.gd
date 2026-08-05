extends Node2D
@onready var menu: Control = $Menu
@onready var continue_btn: Button = $Menu/CenterContainer/VBoxContainer/Continue

func _ready() -> void:
	await get_tree().create_timer(2.1).timeout
	menu.visible = true
	menu.modulate.a = 0.0
	
	var tween = create_tween()
	tween.tween_property(menu, "modulate:a", 1.0, 0.5)	
	
	continue_btn.grab_focus()

func _on_continue_pressed():
	SaveManager.load_game()
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_quit_pressed():
	get_tree().quit()


func _on_new_game_pressed() -> void:
	SaveManager.delete_save()
	get_tree().change_scene_to_file("res://scenes/game.tscn")
