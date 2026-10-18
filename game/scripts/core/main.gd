extends Control

const START_SCENE := "res://game/scenes/main_menu.tscn"
const CHARACTER_SCENE := "res://game/scenes/character_select.tscn"
const SESSION_SCENE := "res://game/scenes/session_select.tscn"
const GAME_SCENE := "res://game/scenes/first_island.tscn"
const PAUSE_SCENE := "res://game/scenes/pause_overlay.tscn"
const APPEARANCE_DATA = preload("res://game/scripts/actors/appearance_data.gd")
const EXPEDITION_STATE = preload("res://game/scripts/save/expedition_state.gd")

var lan
var selected_vocation_id := "warrior"
var screen_host: Control
var selected_character_id := "melissa"
var selected_character_name := "Melissa"
var current_screen
var gameplay
var pause_overlay
var simplified_interface := false
var _lan_pause_input := true


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = false
	selected_character_id = EXPEDITION_STATE.active_character_id(OS.get_environment("GAMEPLAY_TEST_SAVE_DIR"))
	var remembered_profile: Dictionary = APPEARANCE_DATA.profile_for_id(selected_character_id)
	selected_character_name = str(remembered_profile.get("name", "Melissa"))
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen_host = Control.new()
	screen_host.name = "ScreenHost"
	screen_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen_host.process_mode = Node.PROCESS_MODE_PAUSABLE
	screen_host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(screen_host)
	lan = preload("res://game/scripts/network/lan_session.gd").new()
	lan.name = "LanSession"
	add_child(lan)
	lan.connected.connect(_show_gameplay)
	lan.status_changed.connect(_on_lan_status)
	lan.disconnected.connect(_on_lan_disconnected)
	_show_start()


func _clear_host() -> void:
	if gameplay != null and is_instance_valid(gameplay) and gameplay.has_method("save_progress"):
		gameplay.save_progress()
	get_tree().paused = false
	for child in screen_host.get_children():
		screen_host.remove_child(child)
		child.queue_free()
	current_screen = null
	gameplay = null
	pause_overlay = null


func _instantiate(path: String, initial_values: Dictionary = {}) -> Node:
	var packed := load(path) as PackedScene
	if packed == null:
		push_error("Cena indisponível: %s" % path)
		return null
	var node := packed.instantiate()
	for key in initial_values:
		node.set(key, initial_values[key])
	screen_host.add_child(node)
	return node


func _show_start() -> void:
	if lan != null: lan.close()
	_clear_host()
	current_screen = _instantiate(START_SCENE)
	if current_screen != null:
		current_screen.connect("begin_requested", Callable(self, "_show_character_select"))


func _show_character_select() -> void:
	if lan != null: lan.close()
	_clear_host()
	current_screen = _instantiate(CHARACTER_SCENE, {"selected_character_id": selected_character_id})
	if current_screen == null:
		return
	current_screen.connect("back_requested", Callable(self, "_show_start"))
	current_screen.connect("confirm_requested", Callable(self, "_on_character_confirmed"))


func _on_character_confirmed(character_id: String) -> void:
	selected_character_id = character_id
	var profile: Dictionary = APPEARANCE_DATA.profile_for_id(character_id)
	selected_character_name = str(profile.get("name", character_id.capitalize()))
	selected_vocation_id = str(current_screen.get("selected_vocation_id"))
	_show_session()


func _show_session() -> void:
	lan.close()
	_clear_host()
	current_screen = _instantiate(SESSION_SCENE, {"character_name": selected_character_name})
	if current_screen == null:
		return
	current_screen.connect("back_requested", Callable(self, "_show_character_select"))
	current_screen.connect("host_solo_requested", Callable(self, "_show_gameplay"))
	current_screen.connect("host_lan_requested", _host_lan)
	current_screen.connect("join_lan_requested", _join_lan)
	current_screen.lan = lan


func _show_gameplay() -> void:
	_clear_host()
	gameplay = _instantiate(
		GAME_SCENE,
		{"selected_character_id": selected_character_id, "character_name": selected_character_name, "selected_vocation_id": selected_vocation_id}
	)
	current_screen = gameplay
	if gameplay == null:
		return
	lan.attach_world(gameplay)
	if not lan.room_code.is_empty():
		_on_lan_status(lan.room_description())
	gameplay.get_node("HUD").set_simplified(simplified_interface)
	gameplay.connect("pause_requested", Callable(self, "_show_pause"))
	gameplay.connect("interaction_requested", Callable(self, "_on_interaction_requested"))


func _show_pause() -> void:
	if gameplay == null or pause_overlay != null:
		return
	gameplay.get_node("HUD").release_movement()
	if multiplayer.has_multiplayer_peer():
		_lan_pause_input = gameplay._player.input_enabled
		gameplay._player.set_input_enabled(false)
	else:
		get_tree().paused = true
	pause_overlay = _instantiate(PAUSE_SCENE, {"simplified": simplified_interface})
	if pause_overlay == null:
		get_tree().paused = false
		return
	pause_overlay.connect("resume_requested", Callable(self, "_resume_gameplay"))
	pause_overlay.connect("session_requested", Callable(self, "_show_session_from_pause"))
	pause_overlay.connect("start_requested", Callable(self, "_show_start"))
	pause_overlay.connect("save_requested", Callable(self, "_save_from_pause"))
	pause_overlay.connect("zoom_requested", func(delta: int) -> void: gameplay.get_node("HUD").zoom_requested.emit(delta))
	pause_overlay.connect("simplified_changed", func(enabled: bool) -> void:
		simplified_interface = enabled
		gameplay.get_node("HUD").set_simplified(enabled)
	)
	_save_from_pause()

func _save_from_pause() -> void:
	if gameplay != null and pause_overlay != null:
		pause_overlay.show_save_result(bool(gameplay.save_progress()))


func _resume_gameplay() -> void:
	get_tree().paused = false
	if multiplayer.has_multiplayer_peer() and is_instance_valid(gameplay):
		gameplay._player.set_input_enabled(_lan_pause_input)
	if pause_overlay != null:
		screen_host.remove_child(pause_overlay)
		pause_overlay.queue_free()
	pause_overlay = null


func _show_session_from_pause() -> void:
	if gameplay != null and is_instance_valid(gameplay) and gameplay.has_method("save_progress"):
		gameplay.save_progress()
	_show_session()


func _on_interaction_requested() -> void:
	if gameplay != null and gameplay.has_method("interact_with_beacon"):
		gameplay.interact_with_beacon()


func _notification(what: int) -> void:
	if what in [NOTIFICATION_WM_CLOSE_REQUEST, NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT]:
		if gameplay != null and is_instance_valid(gameplay) and gameplay.has_method("save_progress"):
			gameplay.save_progress()
		if what == NOTIFICATION_WM_CLOSE_REQUEST:
			get_tree().quit()



func _host_lan() -> void:
	if lan.host(selected_character_id) == OK: _show_gameplay()

func _join_lan(address: String) -> void:
	lan.join(address, selected_character_id)

func _on_lan_status(message: String) -> void:
	print("LAN: ", message)
	if is_instance_valid(current_screen) and current_screen.has_method("show_status"):
		current_screen.show_status(message)
	if is_instance_valid(gameplay) and is_instance_valid(gameplay._hud):
		gameplay._hud.set_status(message)

func _on_lan_disconnected(reason: String) -> void:
	call_deferred("_return_after_disconnect", reason)

func _return_after_disconnect(reason: String) -> void:
	_show_session()
	_on_lan_status(reason)
