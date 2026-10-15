extends SceneTree
## Headless end-to-end smoke test for the first playable slice.
## This validates routing, atlas loading, map construction, movement and pause;
## it does not replace visual review or Android acceptance.

const MAIN_SCENE := preload("res://game/scenes/main.tscn")
const MAIN_MENU_SCRIPT := "res://game/scripts/ui/main_menu.gd"
const CHARACTER_SELECT_SCRIPT := "res://game/scripts/ui/character_select.gd"
const SESSION_SELECT_SCRIPT := "res://game/scripts/ui/session_select.gd"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var app := MAIN_SCENE.instantiate() as Control
	root.add_child(app)
	await process_frame
	if not _expect(_script_path(app.get("current_screen")) == MAIN_MENU_SCRIPT, "Initial screen did not load the main menu."):
		return

	var start_screen: Node = app.get("current_screen")
	start_screen.emit_signal("begin_requested")
	await process_frame
	if not _expect(_script_path(app.get("current_screen")) == CHARACTER_SELECT_SCRIPT, "Visitor flow did not open character selection."):
		return

	var character_screen: Node = app.get("current_screen")
	character_screen.emit_signal("confirm_requested", "helena")
	await process_frame
	if not _expect(_script_path(app.get("current_screen")) == SESSION_SELECT_SCRIPT, "Character confirmation did not open session selection."):
		return
	if not _expect(str(app.get("selected_character_id")) == "helena", "Chosen appearance was not preserved."):
		return

	var session_screen: Node = app.get("current_screen")
	session_screen.emit_signal("host_solo_requested")
	await process_frame
	var gameplay: Node2D = app.get("gameplay") as Node2D
	if not _expect(gameplay != null and is_instance_valid(gameplay), "Hosting locally did not load the island scene."):
		return
	if not _expect(str(gameplay.get("selected_character_id")) == "helena", "Island scene lost the chosen appearance."):
		return

	var base_layer := gameplay.get_node_or_null("BaseTiles") as TileMapLayer
	var path_layer := gameplay.get_node_or_null("Paths") as TileMapLayer
	if not _expect(base_layer != null and base_layer.get_used_cells().size() == 2816, "Island did not build all 64×44 base cells."):
		return
	if not _expect(path_layer != null and path_layer.get_used_cells().size() > 0, "Island path overlay was not composed."):
		return

	var player := gameplay.get_node_or_null("Actors/LocalPlayer") as CharacterBody2D
	if not _expect(player != null, "Local player was not created."):
		return
	var sprite := player.get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if not _expect(sprite != null and sprite.sprite_frames != null, "Player animation atlas did not load."):
		return
	if not _expect(sprite.sprite_frames.get_frame_count("idle_N") == 4, "Nested Helena idle metadata did not produce four frames."):
		return
	if not _expect(sprite.sprite_frames.get_frame_count("walk_SE") == 6, "Nested Helena walk metadata did not produce six frames."):
		return
	for appearance_id in ["melissa", "helena", "maira", "fabio"]:
		player.selected_character_id = appearance_id
		player._build_animations()
		if not _expect(sprite.sprite_frames.get_frame_count("idle_N") == 4, "%s idle atlas failed to load all frames." % appearance_id):
			return
		if not _expect(sprite.sprite_frames.get_frame_count("walk_NW") == 6, "%s walk atlas failed to load all frames." % appearance_id):
			return
	player.selected_character_id = "helena"
	player._build_animations()

	var start_position := player.global_position
	player.set_joystick_vector(Vector2.RIGHT)
	for _tick in range(10):
		await physics_frame
	player.set_joystick_vector(Vector2.ZERO)
	if not _expect(player.global_position.x > start_position.x + 1.0, "Joystick input did not move the player."):
		return

	player.global_position = Vector2(300.0, 500.0)
	player.set_joystick_vector(Vector2.LEFT)
	for _tick in range(60):
		await physics_frame
	player.set_joystick_vector(Vector2.ZERO)
	if not _expect(player.global_position.x >= 260.0, "Player crossed the blocked-water collision boundary."):
		return

	gameplay.emit_signal("pause_requested")
	await process_frame
	var pause_overlay: Node = app.get("pause_overlay")
	if not _expect(paused and pause_overlay != null and is_instance_valid(pause_overlay), "Pause did not open an overlay and stop gameplay."):
		return
	pause_overlay.emit_signal("resume_requested")
	await process_frame
	if not _expect(not paused and app.get("pause_overlay") == null, "Resume did not close the pause overlay."):
		return

	gameplay.emit_signal("pause_requested")
	await process_frame
	pause_overlay = app.get("pause_overlay")
	pause_overlay.emit_signal("session_requested")
	await process_frame
	if not _expect(not paused and _script_path(app.get("current_screen")) == SESSION_SELECT_SCRIPT, "Pause return-to-session transition failed."):
		return
	var return_session: Node = app.get("current_screen")
	return_session.emit_signal("host_solo_requested")
	await process_frame
	gameplay = app.get("gameplay") as Node2D
	if not _expect(gameplay != null and is_instance_valid(gameplay), "Returning from session did not reopen the island."):
		return

	gameplay.emit_signal("pause_requested")
	await process_frame
	pause_overlay = app.get("pause_overlay")
	pause_overlay.emit_signal("start_requested")
	await process_frame
	if not _expect(not paused and _script_path(app.get("current_screen")) == MAIN_MENU_SCRIPT, "Pause return-to-start transition failed."):
		return

	print("Playable slice smoke test passed: menu → character → session → island, four character atlases, 2,816 terrain cells, movement, water collision and pause transitions.")
	quit(0)


func _script_path(node_value: Variant) -> String:
	if not node_value is Node or node_value.get_script() == null:
		return ""
	return str(node_value.get_script().resource_path)


func _expect(condition: bool, message: String) -> bool:
	if condition:
		return true
	push_error(message)
	quit(1)
	return false
