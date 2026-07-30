extends Node2D

@onready var player_box: Node2D = $PlayerBox
@onready var enemy_count_label: Label = $DebugHUD/EnemyCount


func _ready() -> void:
	player_box.position = get_viewport_rect().size * 0.5


func _process(_delta: float) -> void:
	var enemy_count := get_tree().get_nodes_in_group(&"enemies").size()
	enemy_count_label.text = "ENEMIES: %d" % enemy_count
