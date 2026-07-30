extends Node
class_name VoteService

signal poll_loaded(poll: Dictionary)
signal vote_submitted(poll: Dictionary)
signal request_failed(message: String)

@export var base_url: String = ""

var _request: HTTPRequest
var _mode: StringName = &"idle"


func _ready() -> void:
	_request = HTTPRequest.new()
	_request.timeout = 10.0
	_request.request_completed.connect(_on_request_completed)
	add_child(_request)


func load_active_poll(player_id: String) -> void:
	if not _can_start_request():
		return

	_mode = &"load"
	var url := "%s/polls/active?player_id=%s" % [_clean_base_url(), player_id.uri_encode()]
	var error := _request.request(url, ["Accept: application/json"], HTTPClient.METHOD_GET)
	if error != OK:
		_mode = &"idle"
		request_failed.emit("Could not start poll request.")


func submit_vote(poll_id: String, option_id: String, player_id: String) -> void:
	if not _can_start_request():
		return

	_mode = &"vote"
	var payload := {
		"poll_id": poll_id,
		"option_id": option_id,
		"player_id": player_id,
	}
	var headers := ["Content-Type: application/json", "Accept: application/json"]
	var error := _request.request(
		"%s/votes" % _clean_base_url(),
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(payload)
	)
	if error != OK:
		_mode = &"idle"
		request_failed.emit("Could not start vote request.")


func is_configured() -> bool:
	return not base_url.strip_edges().is_empty()


func _can_start_request() -> bool:
	if not is_configured():
		request_failed.emit("Voting backend is not connected in this build yet.")
		return false
	if _request == null or _request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		request_failed.emit("A voting request is already running.")
		return false
	return true


func _clean_base_url() -> String:
	return base_url.strip_edges().trim_suffix("/")


func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var completed_mode := _mode
	_mode = &"idle"

	if result != HTTPRequest.RESULT_SUCCESS:
		request_failed.emit("Voting service could not be reached.")
		return

	if response_code < 200 or response_code >= 300:
		request_failed.emit("Voting service returned HTTP %d." % response_code)
		return

	var parsed = JSON.parse_string(body.get_string_from_utf8())
	if not parsed is Dictionary:
		request_failed.emit("Voting service returned invalid data.")
		return

	var data := parsed as Dictionary
	if completed_mode == &"load":
		poll_loaded.emit(data)
	elif completed_mode == &"vote":
		vote_submitted.emit(data)
