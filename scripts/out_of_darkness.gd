extends Area2D

@onready var canvas_modulate: CanvasModulate = %CanvasModulate
@onready var collision_shape: CollisionShape2D = %collision

var dark_color: Color = Color(0.15, 0.15, 0.15, 1)
var light_color: Color = Color(1, 1, 1, 1)

var player_inside: Node2D = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = body

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = null

func _process(_delta: float) -> void:
	if player_inside == null:
		return
	var shape: RectangleShape2D = collision_shape.shape
	var half_width = shape.size.x / 2.0
	var left_edge = collision_shape.global_position.x 
	var right_edge = collision_shape.global_position.x + half_width

	var t = clamp((player_inside.global_position.x - left_edge) / (right_edge - left_edge), 0.0, 1.0)

	canvas_modulate.color = dark_color.lerp(light_color, t)
