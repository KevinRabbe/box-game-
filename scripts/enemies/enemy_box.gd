extends CharacterBody2D

signal defeated(coin_reward: int)

@onready var health_component: HealthComponent = $HealthComponent
@onready var movement_component: MovementComponent = $MovementComponent
@onready var contact_damage_component: ContactDamageComponent = $ContactDamageComponent
@onready var reward_component: RewardComponent = $RewardComponent

var _target: Node2D


func _ready() -> void:
	health_component.died.connect(_on_died)


func set_target(target: Node2D) -> void:
	_target = target


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(_target):
		velocity = Vector2.ZERO
		return

	velocity = movement_component.velocity_toward(global_position, _target.global_position)
	move_and_slide()

	for collision_index in get_slide_collision_count():
		var collision := get_slide_collision(collision_index)
		if collision.get_collider() == _target:
			contact_damage_component.apply_to(_target)
			remove_from_group(&"enemies")
			queue_free()
			return


func get_health_component() -> HealthComponent:
	return health_component


func is_targetable() -> bool:
	return not health_component.is_dead()


func _on_died() -> void:
	defeated.emit(reward_component.get_coin_reward())
	remove_from_group(&"enemies")
	queue_free()
