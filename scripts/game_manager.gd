extends Node

var score = 0
signal score_changed(new_score)
var player_dying = false
var has_chkpt:bool=false
var last_chkpt_pos:Vector2=Vector2.ZERO

func add_point():
	score+=1
	score_changed.emit(score)
	print(score)
	SaveManager.data["coins"] = score
	SaveManager.save_game()
	
func activate_power_up(cost: int):
	score-=cost
	score_changed.emit(score)
	
func get_score():
	return score
	
func refresh_score():
	score_changed.emit(score)
	
func kill_player(body: Node2D) -> void:
	if player_dying:
		return
	player_dying = true
	print("player death y:"+str(body.global_position.y))
	body.set_dead()
	body.velocity.y = -100
	var anim = body.get_node_or_null("AnimatedSprite2D")
	if anim:
		anim.play("hit")
		await anim.animation_finished
	if has_chkpt:
		body.set_alive()
		body.velocity.y = 0
		body.global_position = last_chkpt_pos
	else:
		var shape = body.get_node_or_null("CollisionShape2D")
		if shape:
			shape.queue_free()
		score = 0
		Engine.get_main_loop().reload_current_scene()
	player_dying = false

func set_checkpoint(pos: Vector2) -> void:
	last_chkpt_pos = pos
	has_chkpt = true
	SaveManager.data["checkpoint"] = pos
	SaveManager.save_game()
