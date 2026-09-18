extends CharacterBody2D

signal score_updated(new_score)
signal aim_meter_updated(progress_ratio)

const DASH_SPEED = 1400.0
const DASH_DURATION = 0.15
const UPWARD_BOOST = -380.0
const MAX_AIM_TIME_REAL = 0.5

var is_dashing = false
var is_aiming = false
var can_dash = true
var dash_timer = 0.0
var aim_timer = 0.0
var score = 0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var aim_line = $AimLine

func _physics_process(delta):
	var real_delta = delta / max(Engine.time_scale, 0.01)

	can_dash = true

	if is_aiming:
		velocity = Vector2.ZERO
		aim_timer -= real_delta
		aim_meter_updated.emit(aim_timer / MAX_AIM_TIME_REAL)

		var mouse_pos = get_global_mouse_position()
		aim_line.points = [Vector2.ZERO, to_local(mouse_pos)]

		if aim_timer <= 0.0 or Input.is_action_just_released("dash"):
			execute_dash()

	elif is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false
			velocity *= 0.25

	else:
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("dash") and can_dash and not is_aiming:
		start_aiming()

	move_and_slide()

func start_aiming():
	is_aiming = true
	aim_line.visible = true
	aim_timer = MAX_AIM_TIME_REAL
	Engine.time_scale = 0.1

func execute_dash():
	is_aiming = false
	aim_line.visible = false
	Engine.time_scale = 1.0

	aim_meter_updated.emit(0.0) 

	var mouse_pos = get_global_mouse_position()
	var dash_direction = (mouse_pos - global_position).normalized()
	velocity = dash_direction * DASH_SPEED

	is_dashing = true
	can_dash = false
	dash_timer = DASH_DURATION

func on_enemy_destroyed():
	can_dash = true
	velocity.y = UPWARD_BOOST
	score += 100
	score_updated.emit(score)
