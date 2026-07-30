extends Node2D

@onready var targeting_component: TargetingComponent = $TargetingComponent
@onready var weapon_component: WeaponComponent = $WeaponComponent


func _process(_delta: float) -> void:
	var target := targeting_component.find_nearest_target(global_position)
	if target != null:
		weapon_component.try_fire(self, target)
