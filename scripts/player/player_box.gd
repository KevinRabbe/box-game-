extends StaticBody2D

signal died

@onready var health_component: HealthComponent = $HealthComponent
@onready var targeting_component: TargetingComponent = $TargetingComponent
@onready var weapon_component: WeaponComponent = $WeaponComponent


func _ready() -> void:
	health_component.died.connect(_on_died)


func _process(_delta: float) -> void:
	if health_component.is_dead():
		return

	var target := targeting_component.find_nearest_target(global_position)
	if target != null:
		weapon_component.try_fire(self, target)


func take_damage(amount: float) -> void:
	health_component.take_damage(amount)


func get_health_component() -> HealthComponent:
	return health_component


func _on_died() -> void:
	died.emit()
