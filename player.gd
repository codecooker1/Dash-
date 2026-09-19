extends CharacterBody2D

signal score_updated(new_score)
signal aim_meter_updated(progress_ratio)

const DASH_SPEED = 1500.0
const DASH_DURATION = 0.15
const DASH_DAMPING = 6
const UPWARD_BOOST = -380.0
const MAX_AIM_TIME_REAL = 0.5
const MAX_DRAG_DIST = 300.0

var is_dashing = false
var is_aiming = false
var can_dash = true
var dash_timer = 0.0
var aim_timer = 0.0
var score = 0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var aim_line = $AimLine
@onready var debug = $"../UI/Debug"
@onready var sprite = $Sprite2D

var base_scale:Vector2 = Vector2(0.314, 0.314)

#func _ready() -> void:
	#base_scale = sprite.transform.scale
	

func _physics_process(delta:Variant) -> void:
	var real_delta = delta / max(Engine.time_scale, 0.01)
	debug.text = "Time Scale: " + str(Engine.time_scale) + "\n" + "FPS: " + str(1/delta)

	can_dash = true

	if is_aiming:
		#velocity = Vector2.ZERO
		aim_timer -= real_delta
		aim_meter_updated.emit(aim_timer / MAX_AIM_TIME_REAL)

		var mouse_pos = get_global_mouse_position()
		aim_line.points = [Vector2.ZERO, to_local(mouse_pos)]

		if aim_timer <= 0.0 or Input.is_action_just_released("dash"):
			execute_dash()

	elif is_dashing:
		dash_timer -= delta
		velocity = velocity.lerp(Vector2.ZERO, DASH_DAMPING * delta)
		if dash_timer <= 0.0:
			is_dashing = false

	else:
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("dash") and can_dash and not is_aiming:
		start_aiming()

	move_and_slide()
	
	#if velocity.length() > 50:
		#sprite.rotation = velocity.angle()
#
		#var stretch_factor = velocity.length() / DASH_SPEED
		#sprite.scale.x = base_scale.x * (1.0 + stretch_factor * 0.5)
		#sprite.scale.y = base_scale.y / (1.0 + stretch_factor * 0.5)
	#else:
		#sprite.rotation = lerp_angle(sprite.rotation, 0.0, 10.0 * delta)
		#sprite.scale = sprite.scale.lerp(Vector2(1, 1), 10.0 * delta)

func start_aiming():
	is_aiming = true
	aim_line.visible = true
	aim_timer = MAX_AIM_TIME_REAL
	
	Engine.time_scale = 0.1
	
	#var tween = create_tween()
	#tween.tween_property(Engine, "time_scale", 0.1, 0.2).set_trans(Tween.TRANS_SINE)


func execute_dash():
	is_aiming = false
	aim_line.visible = false
	
	Engine.time_scale = 1.0 
	
	#var tween = create_tween()
	#tween.tween_property(Engine, "time_scale", 1.0, 0.002).set_trans(Tween.TRANS_SINE)

	aim_meter_updated.emit(0.0) 

	var mouse_pos = get_global_mouse_position()
	var dash_target = mouse_pos - global_position
	
	var distance = dash_target.length()
	var dash_direction = dash_target.normalized()
	
	var drag_factor = clamp(distance / MAX_DRAG_DIST, 0.0, 1.0)
	
	
	velocity = dash_direction * DASH_SPEED * drag_factor

	is_dashing = true
	can_dash = false
	dash_timer = DASH_DURATION

func on_enemy_destroyed():
	can_dash = true
	velocity.y = UPWARD_BOOST
	score += 100
	score_updated.emit(score)
