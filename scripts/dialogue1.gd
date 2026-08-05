extends Area2D

var nb_times_entered: int = 0
var TIMES: int = 2


func _on_body_entered(_body: Node2D) -> void:
	nb_times_entered+=1
	if nb_times_entered == TIMES:
		DialogueManager.show_dialogue_balloon(load("res://assets/dialogue/time_to_go_up.dialogue"), "start")
