extends SceneTree
## Regression: the HUD attributes button opens, commits, saves, and closes the modal.

var failures := 0


func _initialize() -> void:
	OS.set_environment("GAMEPLAY_TEST_SAVE_DIR", "user://attributes_hud_%d" % Time.get_ticks_usec())
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(720, 1280)
	var game = load("res://game/scenes/first_island.tscn").instantiate()
	root.add_child(game)
	await process_frame
	var hud = game.get_node("HUD")
	_check(hud._nav_buttons.size() == 6, "Attributes button was not added to the HUD navigation row.")
	if failures > 0:
		quit(failures)
		return
	var attributes_button: Button = hud._nav_buttons[2]
	_check(attributes_button.text == "ATR" and attributes_button.tooltip_text == "Atributos", "Attributes button label or tooltip is missing.")
	game._state.available_attribute_points = 2
	attributes_button.emit_signal("pressed")
	await process_frame
	var window: Control = hud._attributes_window
	_check(window.visible and paused, "HUD button did not open a blocking attributes modal.")
	_check(window.mouse_filter == Control.MOUSE_FILTER_STOP, "Attributes modal does not block taps behind it.")
	_check(hud._joystick.blocked, "Opening attributes did not release/block the joystick.")
	window._add_buttons["FOR"].emit_signal("pressed")
	window._add_buttons["INT"].emit_signal("pressed")
	_check(window.confirm_changes(), "Attributes modal rejected valid point allocation.")
	_check(game._state.raw_attributes["FOR"] == 1 and game._state.raw_attributes["INT"] == 1, "Confirm did not apply the allocated attributes.")
	_check(game._state.available_attribute_points == 0, "Confirm did not spend the available attribute points.")
	_check(game._state.revision > 0, "Committed attributes were not persisted by the gameplay handler.")
	_check(hud._hp_bar.max_value == game._state.max_hp_mp().x, "HUD did not refresh after attribute changes.")
	window.close_window()
	_check(not window.visible and not paused, "Closing attributes did not hide the modal and resume gameplay.")
	_check(not hud._joystick.blocked, "Closing attributes left joystick blocked.")
	if failures == 0:
		print("Attributes HUD integration passed: nav button, modal pause/input block, point commit/save, HUD refresh and resume.")
	quit(failures)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)
