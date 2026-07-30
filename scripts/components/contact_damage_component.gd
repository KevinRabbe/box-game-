extends Node
class_name ContactDamageComponent

@export var damage: float = 20.0

var _consumed := false


func apply_to(target: Node) -> bool:
	if _consumed or not is_instance_valid(target) or damage <= 0.0:
		return false

	if not target.has_method("take_damage"):
		return false

	target.call("take_damage", damage)
	_consumed = true
	return true


func reset() -> void:
	_consumed = false
