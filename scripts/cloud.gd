extends Sprite2D

@export var min_speed := 0.5
@export var max_speed := 5.0
var speed := 0.0

@export var min_scale := 0.5
@export var max_scale := 3.0

@export var screen_left := 0.0      # visible area left edge
@export var screen_right := 1500.0  # visible area right edge

@export var offscreen_left := -2000.0   # far left, where respawns happen
@export var offscreen_right := 2000.0  # far right, where despawn/reset triggers

func _ready():
	var s = randf_range(min_scale, max_scale)
	scale = Vector2(s, s)

	var t = (s - min_scale) / (max_scale - min_scale)
	speed = lerp(min_speed, max_speed, t)

	position.y += randf_range(-2000.0, 100.0)
	position.x = randf_range(offscreen_left, screen_right)

func _process(delta):
	position.x += speed * delta

	# Ongoing recycle: reset far off-screen right -> far off-screen left, unseen by player
	if position.x > offscreen_right:
		position.x = offscreen_left
