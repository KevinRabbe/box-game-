extends Node

signal enemy_spawned(enemy: Node2D)

@export var enemy_scene: PackedScene
@export var boss_scene: PackedScene
@export var target_path: NodePath
@export var spawn_margin: float = 40.0

var _target: Node2D


func _ready() -> void:
	_target = get_node_or_null(target_path) as Node2D
	if _target == null:
		push_error("EnemySpawner could not resolve target_path.")

	if enemy_scene == null:
		push_error("EnemySpawner has no enemy_scene assigned.")


func spawn_enemy() -> Node2D:
	return _spawn_scene(enemy_scene)


func spawn_boss() -> Node2D:
	if boss_scene == null:
		push_warning("EnemySpawner has no boss_scene assigned; spawning normal enemy instead.")
		return spawn_enemy()
	return _spawn_scene(boss_scene)


func _spawn_scene(scene: PackedScene) -> Node2D:
	if not is_instance_valid(_target) or scene == null:
		return null

	var enemy := scene.instantiate()
	if not enemy is Node2D:
		push_error("EnemySpawner enemy scene root must inherit Node2D.")
		enemy.queue_free()
		return null

	get_parent().add_child(enemy)
	var enemy_node := enemy as Node2D
	enemy_node.global_position = _random_spawn_position()

	if enemy.has_method("set_target"):
		enemy.set_target(_target)

	enemy_spawned.emit(enemy_node)
	return enemy_node


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
