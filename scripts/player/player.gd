extends CharacterBody2D


const SPEED : float = 100.0
const JUMP_VELOCITY : float = -250.0
const DASH_VELOCITY : float = 200.0;
const DASH_COOLDOWN : float = 0.5;
var dash_cooldown_timer := 0.0
const WATER_PARTICLES = preload("uid://df1ww4wi72nia")
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var dead = false
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
var already_jumped = false
var double_jump = false
var infinite_jump = false
var dash = false
var jump_cut_multip = 0.5
var walljump = false
var gravity = 0
var is_wall_sticking = false
var intro_playing := false
var input_disabled := false
var wall_jump_lock_time := 0.15  # seconds of "no horizontal input control"
var wall_jump_lock_timer := 0.0
var wall_stick_timer: float = 0.0
const WALL_STICK_TIME: float = 0.3
var was_on_water := false
var splash_cooldown := 0.0
var jumped_from_water := false
var is_dash_pressed : bool = false
var is_dashing : bool = false

@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var coin_label: Label = $"../CanvasLayer/Control2/coinLabel"
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite_2d_2: AnimatedSprite2D = $AnimatedSprite2D2
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var out_of_darkness: Area2D = $"../effects/out_of_darkness"

@onready var canvas_modulate: CanvasModulate = %CanvasModulate
@onready var reflection_camera: Camera2D = $"../SubViewport/ReflectionCamera"
@onready var camera_2d: Camera2D = %Camera2D
const CAMERA_FREEZE_Y := 93.0
var cameras_frozen := false

func _ready():
	SaveManager.load_game()
	reflection_camera.resume_tracking()
	GameManager.score_changed.connect(_on_game_manager_score_changed)
	
	if SaveManager.data["has_save"]:
		global_position = SaveManager.data["checkpoint"]
		canvas_modulate.color = Color(1, 1, 1, 1)
		#GameManager.refresh_score
	else:
		intro_playing = true
		canvas_modulate.color = Color.BLACK
		var tween = create_tween()
		tween.tween_property(
			canvas_modulate,
			"color",
			Color("#262221"),
			2.0
		)
		animated_sprite_2d.play("wake")
		await animated_sprite_2d.animation_finished
		intro_playing = false
		#await get_tree().create_timer(1).timeout
		DialogueManager.show_dialogue_balloon(load("res://assets/dialogue/intro.dialogue"), "start")

func set_dead() -> void:
	dead = true
	print("Player global DEATH pos: ", global_position)
	
func set_alive() -> void:
	dead = false	
	
func push_rigidbodies():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var body = collision.get_collider()

		if body is RigidBody2D:
			var normal = collision.get_normal()

			# Only push from the sides
			if abs(normal.x) > 0.8:
				body.apply_impulse(Vector2(-normal.x, 0) * 5)

func _physics_process(delta: float) -> void:
	_update_camera_freeze()

	if (dead || input_disabled) && !intro_playing:
		velocity += get_gravity() * delta
		reflection_camera.stop_tracking()
		move_and_slide()
		return

	reflection_camera.resume_tracking()

	_update_wall_stick(delta)
	_apply_gravity(delta)
	_handle_jump()

	var direction := Input.get_axis("move_l", "move_r")
	if wall_jump_lock_timer > 0.0:
		wall_jump_lock_timer -= delta

	_handle_dash(direction, delta)

	if not is_dashing:
		_handle_horizontal_movement(direction)

	if !intro_playing:
		_update_animation(direction)
		move_and_slide()
		push_rigidbodies()
		splash_cooldown -= delta
		if jumped_from_water:
			check_water_contact(true)
			jumped_from_water = false
		if splash_cooldown <= 0:
			check_water_contact()


func _update_camera_freeze() -> void:
	var should_freeze = global_position.y > CAMERA_FREEZE_Y
	if should_freeze != cameras_frozen:
		cameras_frozen = should_freeze
		if cameras_frozen:
			reflection_camera.stop_tracking()
			camera_2d.stop_tracking()
		else:
			reflection_camera.resume_tracking()
			camera_2d.resume_tracking()


func _update_wall_stick(delta: float) -> void:
	var on_wall = is_on_wall() && !is_on_floor() && walljump
	var no_floor_below = not ray_cast_2d.is_colliding() && walljump

	if walljump && on_wall && no_floor_below && wall_stick_timer < WALL_STICK_TIME:
		velocity = Vector2.ZERO
		gravity = 0
		already_jumped = false
		is_wall_sticking = true
		wall_stick_timer += delta
	else:
		is_wall_sticking = false
		gravity = get_gravity()
		if not on_wall:
			wall_stick_timer = 0.0


func _apply_gravity(delta: float) -> void:
	if is_on_floor():
		velocity.y = 20.0
	elif !is_wall_sticking:
		velocity += get_gravity() * delta


func _handle_jump() -> void:
	var on_wall = is_on_wall() && !is_on_floor() && walljump

	if Input.is_action_just_pressed("jump") && (!already_jumped || is_on_floor()):
		velocity.y = JUMP_VELOCITY
		audio_stream_player_2d.play()

		if infinite_jump || (is_on_wall() && !is_on_floor()) || (is_on_floor() && double_jump):
			already_jumped = false
		else:
			already_jumped = true

		if on_wall:
			wall_jump_lock_timer = wall_jump_lock_time
			var wall_normal = get_wall_normal()
			velocity.x = wall_normal.x * 50.0
			is_wall_sticking = false

		if is_on_floor():
			jumped_from_water = true

	if Input.is_action_just_released("jump") && velocity.y < 0:
		velocity.y *= jump_cut_multip


func _handle_dash(direction: float, delta: float) -> void:
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta

	if Input.is_action_just_pressed("dash") && not is_dashing && dash_cooldown_timer <= 0.0:
		is_dashing = true
		is_dash_pressed = true
		dash_cooldown_timer = DASH_COOLDOWN

		var dash_dir = sign(direction) if direction != 0 else (-1.0 if animated_sprite_2d.flip_h else 1.0)
		velocity.x = dash_dir * DASH_VELOCITY
		velocity.y = -100

		animated_sprite_2d.play("dash")


func _handle_horizontal_movement(direction: float) -> void:
	if abs(direction) < 0.01:
		direction = 0.0
	elif abs(direction) < 0.1:
		direction = 0.5 * sign(direction)
	else:
		direction = 1.0 * sign(direction)

	if direction < 0:
		animated_sprite_2d.flip_h = true
	elif direction > 0:
		animated_sprite_2d.flip_h = false

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)


func _update_animation(direction: float) -> void:
	if dead:
		animated_sprite_2d.play("hit")
		return

	if is_dashing:
		if animated_sprite_2d.animation != "dash":
			animated_sprite_2d.play("dash")
		return

	is_dash_pressed = false

	if !animated_sprite_2d.is_playing() || animated_sprite_2d.animation != "dash":
		if is_on_floor():
			if direction == 0:
				animated_sprite_2d.play("idle")
			else:
				animated_sprite_2d.play("run")
		else:
			if infinite_jump || (double_jump && already_jumped):
				animated_sprite_2d.play("infijump")
			else:
				animated_sprite_2d.play("jump")

func _on_game_manager_score_changed(new_score: Variant) -> void:
	coin_label.text = str(new_score)
	
func activate_pu() -> void:
	animated_sprite_2d.play("infijump")
	#animated_sprite_2d_2.visible=true
	animation_player.play("new_animation")
	animation_player.play("new_animation")
	double_jump = true	
	
func activate_infijump() -> void:
	animated_sprite_2d.play("infijump")
	animation_player.play("new_animation")
	infinite_jump = true

func activate_walljump() -> void:
	animated_sprite_2d.play("infijump")
	animation_player.play("new_animation")
	walljump = true

				
func check_water_contact(force := false):
	if splash_cooldown > 0:
		return

	var on_water := false

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		if collider is TileMapLayer:
			var tilemaplayer: TileMapLayer = collider
			var hit_pos = collision.get_position()

			var tile_pos = tilemaplayer.local_to_map(
				tilemaplayer.to_local(hit_pos)
			)

			var tile_data = tilemaplayer.get_cell_tile_data(tile_pos)

			if tile_data and tile_data.get_custom_data("splash"):
				on_water = true

				var has_move_input = abs(Input.get_axis("move_l", "move_r")) > 0.1
				var landed = collision.get_normal().y < -0.5

				# Splash only when:
				# - entering water from above
				# - walking movement on water
				# - jumping out (forced)
				if force || (!was_on_water && landed) || (has_move_input && is_on_floor()):
					spawn_water_splash(hit_pos)

				break

	was_on_water = on_water


func spawn_water_splash(pos):
	splash_cooldown = 0.25

	var splash = WATER_PARTICLES.instantiate()
	get_tree().current_scene.add_child(splash)

	splash.global_position = pos

	var particles = splash.get_node("GPUParticles2D")
	particles.restart()
	particles.emitting = true


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "dash":
		is_dashing = false
