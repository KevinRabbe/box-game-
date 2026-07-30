extends Node
class_name UpgradeManager

signal upgrades_changed

const DAMAGE := &"damage"
const FIRE_RATE := &"fire_rate"
const MAX_HEALTH := &"max_health"
const RANGE := &"range"

@export var player_path: NodePath
@export var economy_path: NodePath

@export var damage_base_cost: int = 20
@export var fire_rate_base_cost: int = 25
@export var max_health_base_cost: int = 25
@export var range_base_cost: int = 30

@export var damage_step: float = 3.0
@export var fire_rate_step: float = 0.2
@export var max_health_step: float = 15.0
@export var range_step: float = 25.0

var _player: Node
var _economy: RunEconomy
var _levels := {
	DAMAGE: 0,
	FIRE_RATE: 0,
	MAX_HEALTH: 0,
	RANGE: 0,
}


func _ready() -> void:
	_player = get_node_or_null(player_path)
	_economy = get_node_or_null(economy_path) as RunEconomy

	if _player == null:
		push_error("UpgradeManager could not resolve player_path.")
	if _economy == null:
		push_error("UpgradeManager could not resolve economy_path.")


func get_level(upgrade: StringName) -> int:
	return int(_levels.get(upgrade, 0))


func get_cost(upgrade: StringName) -> int:
	var level := get_level(upgrade)
	var base_cost := _get_base_cost(upgrade)
	if base_cost <= 0:
		return 0
	return int(round(base_cost * pow(1.35, level)))


func can_purchase(upgrade: StringName) -> bool:
	return _economy != null and _economy.can_afford(get_cost(upgrade))


func purchase(upgrade: StringName) -> bool:
	if _player == null or _economy == null:
		return false

	var cost := get_cost(upgrade)
	if not _economy.try_spend(cost):
		return false

	var applied := _apply_upgrade(upgrade)
	if not applied:
		_economy.add_coins(cost)
		return false

	_levels[upgrade] = get_level(upgrade) + 1
	upgrades_changed.emit()
	return true


func _get_base_cost(upgrade: StringName) -> int:
	match upgrade:
		DAMAGE:
			return damage_base_cost
		FIRE_RATE:
			return fire_rate_base_cost
		MAX_HEALTH:
			return max_health_base_cost
		RANGE:
			return range_base_cost
		_:
			return 0


func _apply_upgrade(upgrade: StringName) -> bool:
	match upgrade:
		DAMAGE:
			if _player.has_method("upgrade_damage"):
				_player.call("upgrade_damage", damage_step)
				return true
		FIRE_RATE:
			if _player.has_method("upgrade_fire_rate"):
				_player.call("upgrade_fire_rate", fire_rate_step)
				return true
		MAX_HEALTH:
			if _player.has_method("upgrade_max_health"):
				_player.call("upgrade_max_health", max_health_step)
				return true
		RANGE:
			if _player.has_method("upgrade_range"):
				_player.call("upgrade_range", range_step)
				return true

	return false
