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


func upgrade_damage(amount: float) -> void:
	weapon_component.damage = maxf(0.0, weapon_component.damage + amount)


func upgrade_fire_rate(amount: float) -> void:
	weapon_component.fire_rate = maxf(0.01, weapon_component.fire_rate + amount)


func upgrade_max_health(amount: float) -> void:
	health_component.increase_max_health(amount, true)


func upgrade_range(amount: float) -> void:
	targeting_component.max_range = maxf(0.0, targeting_component.max_range + amount)


func get_damage() -> float:
	return weapon_component.damage


func get_fire_rate() -> float:
	return weapon_component.fire_rate


func get_range() -> float:
	return targeting_component.max_range


func _on_died() -> void:
	died.emit()
