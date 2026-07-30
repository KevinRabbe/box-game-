extends Node
class_name HealthComponent

signal health_changed(current_health: float, max_health: float)
signal died

@export var max_health: float = 30.0

var current_health: float
var _dead := false


func _ready() -> void:
	reset_health()


func take_damage(amount: float) -> void:
	if _dead or amount <= 0.0:
		return

	current_health = maxf(0.0, current_health - amount)
	health_changed.emit(current_health, max_health)

	if current_health <= 0.0:
		_dead = true
		died.emit()


func heal(amount: float) -> void:
	if _dead or amount <= 0.0:
		return

	current_health = minf(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)


func increase_max_health(amount: float, heal_added_health: bool = true) -> void:
	if amount <= 0.0:
		return

	max_health += amount
	if heal_added_health and not _dead:
		current_health = minf(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)


func reset_health() -> void:
	_dead = false
	current_health = maxf(0.0, max_health)
	health_changed.emit(current_health, max_health)


func is_dead() -> bool:
	return _dead
