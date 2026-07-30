extends Node2D

@onready var player_box = $PlayerBox
@onready var player_health: HealthComponent = $PlayerBox/HealthComponent
@onready var wave_manager: WaveManager = $WaveManager
@onready var enemy_count_label: Label = $DebugHUD/EnemyCount
@onready var health_label: Label = $DebugHUD/Health
@onready var wave_label: Label = $DebugHUD/Wave
@onready var game_over_layer: CanvasLayer = $GameOver
@onready var game_over_summary: Label = $GameOver/Overlay/Summary
@onready var restart_button: Button = $GameOver/Overlay/RestartButton

var _game_over := false


func _ready() -> void:
	player_box.position = get_viewport_rect().size * 0.5
	player_health.health_changed.connect(_on_player_health_changed)
	player_box.died.connect(_on_player_died)
	wave_manager.wave_started.connect(_on_wave_started)
	restart_button.pressed.connect(_restart_game)
	game_over_layer.visible = false
	_on_player_health_changed(player_health.current_health, player_health.max_health)


func _process(_delta: float) -> void:
	var enemy_count := get_tree().get_nodes_in_group(&"enemies").size()
	enemy_count_label.text = "ENEMIES: %d" % enemy_count


func _on_player_health_changed(current_health: float, max_health: float) -> void:
	health_label.text = "HP: %d / %d" % [roundi(current_health), roundi(max_health)]


func _on_wave_started(wave_number: int) -> void:
	wave_label.text = "WAVE: %d" % wave_number


func _on_player_died() -> void:
	if _game_over:
		return

	_game_over = true
	wave_manager.stop()
	player_box.set_process(false)

	for enemy in get_tree().get_nodes_in_group(&"enemies"):
		enemy.queue_free()

	for projectile in $ProjectileContainer.get_children():
		projectile.queue_free()

	game_over_summary.text = "GAME OVER\nWAVE %d" % wave_manager.current_wave
	game_over_layer.visible = true


func _restart_game() -> void:
	get_tree().reload_current_scene()
