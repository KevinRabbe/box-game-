extends Control

@onready var highest_wave_label: Label = $HighestWave
@onready var play_button: Button = $PlayButton
@onready var vote_button: Button = $VoteButton


func _ready() -> void:
	highest_wave_label.text = "HIGHEST WAVE: %d" % SaveManager.highest_wave
	play_button.pressed.connect(_play)
	vote_button.pressed.connect(_open_vote)


func _play() -> void:
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")


func _open_vote() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/community_vote.tscn")
