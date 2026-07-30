extends Node

const SAVE_PATH := "user://box_defense_save.json"
const SAVE_VERSION := 1

var highest_wave: int = 0
var player_id: String = ""


func _ready() -> void:
	load_save()


func record_wave(wave: int) -> void:
	if wave <= highest_wave:
		return

	highest_wave = wave
	save()


func save() -> void:
	_ensure_player_id()
	var data := {
		"save_version": SAVE_VERSION,
		"highest_wave": highest_wave,
		"player_id": player_id,
	}

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("SaveManager could not open save file for writing.")
		return

	file.store_string(JSON.stringify(data))


func load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		_ensure_player_id()
		save()
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("SaveManager could not open save file for reading.")
		_ensure_player_id()
		return

	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		push_warning("SaveManager found invalid save data. Starting with safe defaults.")
		_ensure_player_id()
		return

	var data := parsed as Dictionary
	highest_wave = maxi(0, int(data.get("highest_wave", 0)))
	player_id = str(data.get("player_id", ""))
	_ensure_player_id()


func _ensure_player_id() -> void:
	if not player_id.is_empty():
		return

	var crypto := Crypto.new()
	var random_bytes := crypto.generate_random_bytes(16)
	if random_bytes.size() == 16:
		player_id = random_bytes.hex_encode()
	else:
		player_id = "%s-%s" % [str(Time.get_unix_time_from_system()), str(randi())]
