extends Area2D

@export var lifetime: float = 2.0

var _direction := Vector2.RIGHT
var _damage := 1.0
var _speed := 100.0
var _active := true


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func configure(direction: Vector2, damage: float, speed: float) -> void:
	_direction = direction.normalized()
	_damage = maxf(0.0, damage)
	_speed = maxf(0.0, speed)


func _physics_process(delta: float) -> void:
	if not _active:
		return

	global_position += _direction * _speed * delta
	lifetime -= delta

	if lifetime <= 0.0:
		_active = false
		queue_free()


func _on_body_entered(body: Node) -> void:
	if not _active:
		return
	if not body.has_method("get_health_component"):
		return

	var health_component = body.get_health_component()
	if health_component == null:
		return

	_active = false
	monitoring = false
	health_component.take_damage(_damage)
	queue_free()
