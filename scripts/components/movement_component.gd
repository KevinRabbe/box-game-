extends Node
class_name MovementComponent

@export var speed: float = 90.0


func velocity_toward(from_position: Vector2, target_position: Vector2) -> Vector2:
	var offset := target_position - from_position
	if offset.length_squared() < 0.25:
		return Vector2.ZERO

	return offset.normalized() * speed
