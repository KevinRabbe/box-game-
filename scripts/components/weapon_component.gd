extends Node
class_name WeaponComponent

@export var projectile_scene: PackedScene
@export var projectile_container_path: NodePath
@export var damage: float = 10.0
@export var fire_rate: float = 2.0
@export var projectile_speed: float = 700.0

var _cooldown_remaining := 0.0


func _process(delta: float) -> void:
	_cooldown_remaining = maxf(0.0, _cooldown_remaining - delta)


func try_fire(origin: Node2D, target: Node2D) -> bool:
	if _cooldown_remaining > 0.0:
		return false
	if projectile_scene == null:
		push_warning("WeaponComponent has no projectile_scene assigned.")
		return false
	if not is_instance_valid(origin) or not is_instance_valid(target):
		return false
	if fire_rate <= 0.0:
		return false

	var direction := origin.global_position.direction_to(target.global_position)
	if direction == Vector2.ZERO:
		return false

	var projectile_container := get_node_or_null(projectile_container_path)
	if projectile_container == null:
		push_warning("WeaponComponent could not resolve projectile_container_path.")
		return false

	var projectile := projectile_scene.instantiate()
	projectile_container.add_child(projectile)

	if projectile is Node2D:
		(projectile as Node2D).global_position = origin.global_position

	if projectile.has_method("configure"):
		projectile.configure(direction, damage, projectile_speed)
	else:
		push_warning("Projectile scene does not implement configure(direction, damage, speed).")
		projectile.queue_free()
		return false

	_cooldown_remaining = 1.0 / fire_rate
	return true
