extends Area2D

var nb_times_entered: int = 0
var TIMES: int = 1

func _on_body_entered(body: Node2D) -> void:
	nb_times_entered+=1
	if nb_times_entered == TIMES:
		DialogueManager.show_dialogue_balloon(load("res://assets/dialogue/contemplation.dialogue"), "start")
