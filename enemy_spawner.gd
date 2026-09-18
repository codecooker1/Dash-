extends Node2D

@export var enemy_scene: PackedScene
@export var initial_spawn_interval: float = 0.9
@export var min_spawn_interval: float = 0.35
@export var y_spawn_range: float = 280.0
@export var x_spawn_range: float = 280.0

var timer: float = 0.0
var current_interval: float

func _ready():
	current_interval = initial_spawn_interval

func _process(delta):
	current_interval = max(min_spawn_interval, current_interval - (0.01 * delta))

	timer -= delta
	if timer <= 0.0:
		spawn_enemy()
		timer = current_interval

func spawn_enemy():
	if not enemy_scene: return

	var enemy = enemy_scene.instantiate()
	var random_y = randf_range(-y_spawn_range, y_spawn_range)
	var random_x = randf_range(-x_spawn_range, x_spawn_range)

	enemy.global_position = Vector2(get_viewport_rect().size.x / 2.0 + random_x, get_viewport_rect().size.y / 2.0 + random_y)

	get_tree().current_scene.add_child(enemy)
