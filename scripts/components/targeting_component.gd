extends Node
class_name TargetingComponent

@export var target_group: StringName = &"enemies"
@export var max_range: float = 420.0


func find_nearest_target(origin: Vector2) -> Node2D:
	var best_target: Node2D = null
	var best_distance_squared := max_range * max_range

	for candidate in get_tree().get_nodes_in_group(target_group):
		if not is_instance_valid(candidate) or not candidate is Node2D:
			continue

		if candidate.has_method("is_targetable") and not candidate.is_targetable():
			continue

		var candidate_2d := candidate as Node2D
		var distance_squared := origin.distance_squared_to(candidate_2d.global_position)
		if distance_squared <= best_distance_squared:
			best_distance_squared = distance_squared
			best_target = candidate_2d

	return best_target
