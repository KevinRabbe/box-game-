extends Node2D

@onready var player_box = $PlayerBox
@onready var player_health: HealthComponent = $PlayerBox/HealthComponent
@onready var wave_manager: WaveManager = $WaveManager
@onready var enemy_spawner = $EnemySpawner
@onready var economy: RunEconomy = $RunEconomy
@onready var upgrade_manager: UpgradeManager = $UpgradeManager

@onready var enemy_count_label: Label = $HUD/EnemyCount
@onready var health_label: Label = $HUD/Health
@onready var wave_label: Label = $HUD/Wave
@onready var coins_label: Label = $HUD/Coins
@onready var kills_label: Label = $HUD/Kills
@onready var stats_label: Label = $HUD/Stats

@onready var damage_button: Button = $HUD/UpgradePanel/DamageButton
@onready var fire_rate_button: Button = $HUD/UpgradePanel/FireRateButton
@onready var health_button: Button = $HUD/UpgradePanel/HealthButton
@onready var range_button: Button = $HUD/UpgradePanel/RangeButton

@onready var game_over_layer: CanvasLayer = $GameOver
@onready var game_over_summary: Label = $GameOver/Overlay/Summary
@onready var restart_button: Button = $GameOver/Overlay/RestartButton
@onready var menu_button: Button = $GameOver/Overlay/MenuButton

var _game_over := false
var _boxes_destroyed: int = 0


func _ready() -> void:
	player_box.position = get_viewport_rect().size * 0.5
	player_health.health_changed.connect(_on_player_health_changed)
	player_box.died.connect(_on_player_died)
	wave_manager.wave_started.connect(_on_wave_started)
	enemy_spawner.enemy_spawned.connect(_on_enemy_spawned)
	economy.coins_changed.connect(_on_coins_changed)
	upgrade_manager.upgrades_changed.connect(_refresh_upgrade_ui)

	damage_button.pressed.connect(_buy_damage)
	fire_rate_button.pressed.connect(_buy_fire_rate)
	health_button.pressed.connect(_buy_max_health)
	range_button.pressed.connect(_buy_range)
	restart_button.pressed.connect(_restart_game)
	menu_button.pressed.connect(_return_to_menu)

	game_over_layer.visible = false
	_on_player_health_changed(player_health.current_health, player_health.max_health)
	_on_coins_changed(economy.coins)
	_refresh_upgrade_ui()
	_refresh_stats()


func _process(_delta: float) -> void:
	var enemy_count := get_tree().get_nodes_in_group(&"enemies").size()
	enemy_count_label.text = "ENEMIES: %d" % enemy_count


func _on_enemy_spawned(enemy: Node2D) -> void:
	if enemy.has_signal("defeated"):
		enemy.connect("defeated", Callable(self, "_on_enemy_defeated"))


func _on_enemy_defeated(coin_reward: int) -> void:
	if _game_over:
		return

	_boxes_destroyed += 1
	economy.add_coins(coin_reward)
	kills_label.text = "DESTROYED: %d" % _boxes_destroyed
	_refresh_upgrade_ui()


func _on_player_health_changed(current_health: float, max_health: float) -> void:
	health_label.text = "HP: %d / %d" % [roundi(current_health), roundi(max_health)]
	_refresh_stats()


func _on_wave_started(wave_number: int) -> void:
	SaveManager.record_wave(wave_number)
	if wave_manager.is_boss_wave():
		wave_label.text = "WAVE: %d  BIG BOX" % wave_number
	else:
		wave_label.text = "WAVE: %d" % wave_number


func _on_coins_changed(coins: int) -> void:
	coins_label.text = "COINS: %d" % coins
	_refresh_upgrade_ui()


func _buy_damage() -> void:
	upgrade_manager.purchase(UpgradeManager.DAMAGE)
	_refresh_after_purchase()


func _buy_fire_rate() -> void:
	upgrade_manager.purchase(UpgradeManager.FIRE_RATE)
	_refresh_after_purchase()


func _buy_max_health() -> void:
	upgrade_manager.purchase(UpgradeManager.MAX_HEALTH)
	_refresh_after_purchase()


func _buy_range() -> void:
	upgrade_manager.purchase(UpgradeManager.RANGE)
	_refresh_after_purchase()


func _refresh_after_purchase() -> void:
	_refresh_upgrade_ui()
	_refresh_stats()


func _refresh_upgrade_ui() -> void:
	if not is_instance_valid(upgrade_manager) or not is_instance_valid(economy):
		return

	_update_upgrade_button(damage_button, "DAMAGE", UpgradeManager.DAMAGE)
	_update_upgrade_button(fire_rate_button, "FIRE RATE", UpgradeManager.FIRE_RATE)
	_update_upgrade_button(health_button, "MAX HP", UpgradeManager.MAX_HEALTH)
	_update_upgrade_button(range_button, "RANGE", UpgradeManager.RANGE)


func _update_upgrade_button(button: Button, title: String, upgrade: StringName) -> void:
	var level := upgrade_manager.get_level(upgrade)
	var cost := upgrade_manager.get_cost(upgrade)
	button.text = "%s  LV.%d\n%d COINS" % [title, level, cost]
	button.disabled = _game_over or not economy.can_afford(cost)


func _refresh_stats() -> void:
	if not is_instance_valid(player_box):
		return

	stats_label.text = "DMG %.0f   RATE %.1f/s   RANGE %.0f" % [
		player_box.get_damage(),
		player_box.get_fire_rate(),
		player_box.get_range(),
	]


func _on_player_died() -> void:
	if _game_over:
		return

	_game_over = true
	wave_manager.stop()
	player_box.set_process(false)
	SaveManager.record_wave(wave_manager.current_wave)

	for enemy in get_tree().get_nodes_in_group(&"enemies"):
		enemy.queue_free()

	for projectile in $ProjectileContainer.get_children():
		projectile.queue_free()

	game_over_summary.text = "GAME OVER\nWAVE %d\n%d BOXES DESTROYED\n%d COINS" % [
		wave_manager.current_wave,
		_boxes_destroyed,
		economy.coins,
	]
	game_over_layer.visible = true
	_refresh_upgrade_ui()


func _restart_game() -> void:
	get_tree().reload_current_scene()


func _return_to_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
