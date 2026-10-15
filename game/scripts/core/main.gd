extends Control

const START_SCENE := "res://game/scenes/main_menu.tscn"
const CHARACTER_SCENE := "res://game/scenes/character_select.tscn"
const SESSION_SCENE := "res://game/scenes/session_select.tscn"
const GAME_SCENE := "res://game/scenes/first_island.tscn"
const PAUSE_SCENE := "res://game/scenes/pause_overlay.tscn"
const APPEARANCE_DATA = preload("res://game/scripts/actors/appearance_data.gd")

var screen_host: Control
var selected_character_id := "melissa"
var selected_character_name := "Melissa"
var current_screen
var gameplay
var pause_overlay


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = false
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen_host = Control.new()
	screen_host.name = "ScreenHost"
	screen_host.process_mode = Node.PROCESS_MODE_PAUSABLE
	screen_host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(screen_host)
	_show_start()


func _clear_host() -> void:
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
	_clear_host()
	current_screen = _instantiate(START_SCENE)
	if current_screen != null:
		current_screen.connect("begin_requested", Callable(self, "_show_character_select"))


func _show_character_select() -> void:
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
	_show_session()


func _show_session() -> void:
	_clear_host()
	current_screen = _instantiate(SESSION_SCENE, {"character_name": selected_character_name})
	if current_screen == null:
		return
	current_screen.connect("back_requested", Callable(self, "_show_character_select"))
	current_screen.connect("host_solo_requested", Callable(self, "_show_gameplay"))


func _show_gameplay() -> void:
	_clear_host()
	gameplay = _instantiate(
		GAME_SCENE,
		{"selected_character_id": selected_character_id, "character_name": selected_character_name}
	)
	current_screen = gameplay
	if gameplay == null:
		return
	gameplay.connect("pause_requested", Callable(self, "_show_pause"))
	gameplay.connect("interaction_requested", Callable(self, "_on_interaction_requested"))


func _show_pause() -> void:
	if gameplay == null or pause_overlay != null:
		return
	get_tree().paused = true
	pause_overlay = _instantiate(PAUSE_SCENE)
	if pause_overlay == null:
		get_tree().paused = false
		return
	pause_overlay.connect("resume_requested", Callable(self, "_resume_gameplay"))
	pause_overlay.connect("session_requested", Callable(self, "_show_session_from_pause"))
	pause_overlay.connect("start_requested", Callable(self, "_show_start"))


func _resume_gameplay() -> void:
	get_tree().paused = false
	if pause_overlay != null:
		screen_host.remove_child(pause_overlay)
		pause_overlay.queue_free()
	pause_overlay = null


func _show_session_from_pause() -> void:
	_show_session()


func _on_interaction_requested() -> void:
	if gameplay != null and gameplay.has_method("interact_with_beacon"):
		gameplay.interact_with_beacon()
