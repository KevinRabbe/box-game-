extends Node
class_name WaveManager

signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)

@export var spawner_path: NodePath
@export var base_enemy_count: int = 4
@export var enemies_added_per_wave: int = 2
@export var spawn_interval: float = 0.45
@export var inter_wave_delay: float = 1.25
@export var boss_every_n_waves: int = 10

var current_wave: int = 0
var _spawner: Node
var _spawn_timer: Timer
var _inter_wave_timer: Timer
var _remaining_to_spawn: int = 0
var _waiting_for_clear := false
var _active := true
var _boss_wave := false


func _ready() -> void:
	_spawner = get_node_or_null(spawner_path)
	if _spawner == null:
		push_error("WaveManager could not resolve spawner_path.")
		_active = false
		return

	_spawn_timer = Timer.new()
	_spawn_timer.one_shot = true
	_spawn_timer.wait_time = maxf(0.05, spawn_interval)
	_spawn_timer.timeout.connect(_spawn_next_enemy)
	add_child(_spawn_timer)

	_inter_wave_timer = Timer.new()
	_inter_wave_timer.one_shot = true
	_inter_wave_timer.wait_time = maxf(0.0, inter_wave_delay)
	_inter_wave_timer.timeout.connect(_start_next_wave)
	add_child(_inter_wave_timer)

	call_deferred("_start_next_wave")


func _process(_delta: float) -> void:
	if not _active or not _waiting_for_clear:
		return

	if get_tree().get_nodes_in_group(&"enemies").is_empty():
		_waiting_for_clear = false
		wave_completed.emit(current_wave)
		_inter_wave_timer.start()


func stop() -> void:
	_active = false
	_waiting_for_clear = false
	_remaining_to_spawn = 0
	if is_instance_valid(_spawn_timer):
		_spawn_timer.stop()
	if is_instance_valid(_inter_wave_timer):
		_inter_wave_timer.stop()


func is_boss_wave() -> bool:
	return _boss_wave


func _start_next_wave() -> void:
	if not _active:
		return

	current_wave += 1
	_boss_wave = boss_every_n_waves > 0 and current_wave % boss_every_n_waves == 0

	if _boss_wave:
		_remaining_to_spawn = 1
	else:
		_remaining_to_spawn = base_enemy_count + ((current_wave - 1) * enemies_added_per_wave)

	wave_started.emit(current_wave)
	_spawn_next_enemy()


func _spawn_next_enemy() -> void:
	if not _active or _remaining_to_spawn <= 0:
		return

	if _boss_wave and _spawner.has_method("spawn_boss"):
		_spawner.call("spawn_boss")
	elif _spawner.has_method("spawn_enemy"):
		_spawner.call("spawn_enemy")

	_remaining_to_spawn -= 1
	if _remaining_to_spawn > 0:
		_spawn_timer.start()
	else:
		_waiting_for_clear = true
