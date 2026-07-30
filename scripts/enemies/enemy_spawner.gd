extends Node

@export var enemy_scene: PackedScene
@export var target_path: NodePath
@export var spawn_interval: float = 0.9
@export var spawn_margin: float = 40.0

var _target: Node2D
var _timer: Timer


func _ready() -> void:
	_target = get_node_or_null(target_path) as Node2D
	if _target == null:
		push_error("EnemySpawner could not resolve target_path.")
		set_process(false)
		return

	if enemy_scene == null:
		push_error("EnemySpawner has no enemy_scene assigned.")
		set_process(false)
		return

	_timer = Timer.new()
	_timer.wait_time = maxf(0.05, spawn_interval)
	_timer.one_shot = false
	_timer.autostart = true
	_timer.timeout.connect(_spawn_enemy)
	add_child(_timer)

	_spawn_enemy()


func _spawn_enemy() -> void:
	if not is_instance_valid(_target) or enemy_scene == null:
		return

	var enemy := enemy_scene.instantiate()
	if not enemy is Node2D:
		push_error("EnemySpawner enemy_scene root must inherit Node2D.")
		enemy.queue_free()
		return

	get_parent().add_child(enemy)
	(enemy as Node2D).global_position = _random_spawn_position()

	if enemy.has_method("set_target"):
		enemy.set_target(_target)


func _random_spawn_position() -> Vector2:
	var arena_size := get_viewport().get_visible_rect().size
	var min_x := spawn_margin
	var max_x := maxf(min_x, arena_size.x - spawn_margin)
	var min_y := spawn_margin
	var max_y := maxf(min_y, arena_size.y - spawn_margin)

	match randi_range(0, 3):
		0:
			return Vector2(randf_range(min_x, max_x), min_y)
		1:
			return Vector2(max_x, randf_range(min_y, max_y))
		2:
			return Vector2(randf_range(min_x, max_x), max_y)
		_:
			return Vector2(min_x, randf_range(min_y, max_y))
