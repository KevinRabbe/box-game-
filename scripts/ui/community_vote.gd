extends Control

@onready var vote_service: VoteService = $VoteService
@onready var status_label: Label = $Status
@onready var question_label: Label = $Question
@onready var option_a_button: Button = $OptionA
@onready var option_b_button: Button = $OptionB
@onready var results_label: Label = $Results
@onready var closes_label: Label = $Closes
@onready var back_button: Button = $BackButton

var _poll_id: String = ""
var _option_a_id: String = ""
var _option_b_id: String = ""


func _ready() -> void:
	vote_service.poll_loaded.connect(_show_poll)
	vote_service.vote_submitted.connect(_show_poll)
	vote_service.request_failed.connect(_show_error)
	option_a_button.pressed.connect(_vote_a)
	option_b_button.pressed.connect(_vote_b)
	back_button.pressed.connect(_back)

	_set_choices_enabled(false)
	results_label.text = ""
	closes_label.text = ""

	if vote_service.is_configured():
		status_label.text = "LOADING VOTE..."
		vote_service.load_active_poll(SaveManager.player_id)
	else:
		_show_development_placeholder()


func _show_poll(poll: Dictionary) -> void:
	var options_value = poll.get("options", [])
	if not options_value is Array:
		_show_error("Poll data has no options.")
		return

	var options := options_value as Array
	if options.size() != 2 or not options[0] is Dictionary or not options[1] is Dictionary:
		_show_error("BOX DEFENSE currently expects exactly two vote options.")
		return

	var option_a := options[0] as Dictionary
	var option_b := options[1] as Dictionary
	_poll_id = str(poll.get("id", ""))
	_option_a_id = str(option_a.get("id", ""))
	_option_b_id = str(option_b.get("id", ""))

	if _poll_id.is_empty() or _option_a_id.is_empty() or _option_b_id.is_empty():
		_show_error("Poll data is missing identifiers.")
		return

	question_label.text = str(poll.get("question", "WHAT SHOULD WE ADD NEXT?"))
	option_a_button.text = str(option_a.get("text", "OPTION A"))
	option_b_button.text = str(option_b.get("text", "OPTION B"))
	closes_label.text = str(poll.get("ends_text", ""))

	var player_vote := str(poll.get("player_vote", ""))
	var already_voted := not player_vote.is_empty() and player_vote != "null"
	_set_choices_enabled(not already_voted)

	var votes_a := maxi(0, int(option_a.get("votes", 0)))
	var votes_b := maxi(0, int(option_b.get("votes", 0)))
	var total := votes_a + votes_b
	if total > 0 and (already_voted or bool(poll.get("show_results", false))):
		var percent_a := roundi((float(votes_a) / float(total)) * 100.0)
		var percent_b := 100 - percent_a
		results_label.text = "%s  %d%%    VS    %s  %d%%\n%d VOTES" % [
			option_a_button.text,
			percent_a,
			option_b_button.text,
			percent_b,
			total,
		]
	else:
		results_label.text = ""

	status_label.text = "YOUR VOTE IS LOCKED IN." if already_voted else "ONE PLAYER. ONE VOTE."


func _vote_a() -> void:
	_submit(_option_a_id)


func _vote_b() -> void:
	_submit(_option_b_id)


func _submit(option_id: String) -> void:
	if _poll_id.is_empty() or option_id.is_empty():
		return
	_set_choices_enabled(false)
	status_label.text = "SUBMITTING VOTE..."
	vote_service.submit_vote(_poll_id, option_id, SaveManager.player_id)


func _set_choices_enabled(enabled: bool) -> void:
	option_a_button.disabled = not enabled
	option_b_button.disabled = not enabled


func _show_error(message: String) -> void:
	status_label.text = message.to_upper()
	_set_choices_enabled(false)


func _show_development_placeholder() -> void:
	status_label.text = "VOTING BACKEND NOT CONNECTED YET."
	question_label.text = "WHAT SHOULD WE ADD FIRST?"
	option_a_button.text = "WEAPONS"
	option_b_button.text = "NEW ENEMIES"
	results_label.text = "THE UI IS READY. THE SERVER IS NEXT."
	closes_label.text = "DEVELOPMENT BUILD"
	_set_choices_enabled(false)


func _back() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
