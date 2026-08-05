extends Node2D
const CLOUD = preload("uid://cwxrjipqrd7rg")
var cloud_count := 100

func _ready():
	for i in cloud_count:
		var cloud = CLOUD.instantiate()
		add_child(cloud)
