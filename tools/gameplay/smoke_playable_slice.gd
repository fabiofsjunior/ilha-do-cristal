extends SceneTree
## Headless end-to-end smoke test for the first playable slice.
## This validates routing, atlas loading, map construction, movement and pause;
## it does not replace visual review or Android acceptance.

const MAIN_SCENE := preload("res://game/scenes/main.tscn")
const MAIN_MENU_SCRIPT := "res://game/scripts/ui/main_menu.gd"
const CHARACTER_SELECT_SCRIPT := "res://game/scripts/ui/character_select.gd"
const SESSION_SELECT_SCRIPT := "res://game/scripts/ui/session_select.gd"


func _initialize() -> void:
	if OS.get_environment("GAMEPLAY_TEST_SAVE_DIR").is_empty():
		OS.set_environment("GAMEPLAY_TEST_SAVE_DIR", "user://playable_slice_smoke_%d" % Time.get_ticks_usec())
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(720, 1280)
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
	var map_size: Array = gameplay.get("_layout").get("grid_size", [])
	var expected_base_cells := int(map_size[0]) * int(map_size[1]) if map_size.size() >= 2 else 0
	if not _expect(base_layer != null and map_size.size() >= 2 and int(map_size[0]) == 192 and int(map_size[1]) == 132 and base_layer.get_used_cells().size() == expected_base_cells, "Island did not build all cells of the expanded 192×132 map."):
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
	if not await _test_creature_input_and_ai(gameplay, player):
		return

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

	print("Playable slice smoke test passed: menu → character → session → island, four player atlases, world harvesting, static SE creature candidates, target click, auto-attack, peaceful/retaliating fox, aggressive wolf, safe bear windup, 25,344 terrain cells, movement, water collision and pause transitions.")
	quit(0)


func _test_creature_input_and_ai(gameplay: Node2D, player: CharacterBody2D) -> bool:
	var actors: Dictionary = gameplay.get("_creature_actors")
	if not _test_world_harvest(gameplay, player):
		return false
	for species_id in ["fox", "wolf", "bear"]:
		var actor := actors.get("%s_1" % species_id) as CreatureActor
		if not _expect(actor != null and is_instance_valid(actor), "%s actor did not spawn." % species_id):
			return false
		var pose := actor.get_node_or_null("StaticCandidatePoseSE") as Sprite2D
		if not _expect(pose != null and pose.texture != null, "%s candidate SE pose did not import." % species_id):
			return false
		var metadata_path := "res://assets/creatures/%s/%s_se_candidate_v1.json" % [species_id, species_id]
		var metadata = JSON.parse_string(FileAccess.get_file_as_string(metadata_path))
		if not _expect(metadata is Dictionary and metadata.get("approved", true) == false and metadata.get("directions", []) == ["SE"], "%s candidate metadata approval/direction contract changed." % species_id):
			return false
		var idle: Dictionary = metadata.get("animations", {}).get("idle", {})
		if not _expect(int(idle.get("frames", 0)) == 1 and float(idle.get("fps", 0)) == 1.0, "%s candidate must remain a one-frame static pose." % species_id):
			return false

	var fox := actors.get("fox_1") as CreatureActor
	var fox_origin := fox.global_position
	var player_origin := player.global_position
	var state = gameplay.get("_state")
	var hp_before: float = state.hp
	fox.global_position = player.global_position + Vector2(120, 0)
	await process_frame
	var view = gameplay.get_node("Isometric3DView")
	var screen_point: Vector2 = view.camera.unproject_position(view.world_point(fox.global_position, 1.0))
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.position = screen_point
	click.pressed = true
	gameplay.get_viewport().push_input(click, true)
	await process_frame
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.position = screen_point
	release.pressed = false
	gameplay.get_viewport().push_input(release, true)
	await process_frame
	if not _expect(gameplay.get("_target") == fox, "HUD mouse filters blocked world click-to-target selection."):
		return false

	gameplay.set("_target", null)
	gameplay.set("_auto_attack_enabled", false)
	fox.global_position = player.global_position + Vector2(40.0, 0.0)
	fox.attack_remaining = 0.0
	var flee_origin_x := fox.global_position.x
	for _tick in range(3):
		await physics_frame
	if not _expect(not fox.provoked and state.hp == hp_before and fox.global_position.x > flee_origin_x, "Unprovoked fox did not flee without damaging the player."):
		return false
	fox.global_position = player.global_position + Vector2(30.0, 0.0)
	fox.attack_remaining = 0.0
	fox.take_hit(1.0)
	var retaliation_hp: float = state.hp
	await physics_frame
	if not _expect(fox.provoked and state.hp < retaliation_hp, "Provoked fox did not retaliate."):
		return false
	state.hp = hp_before
	fox.global_position = fox_origin
	fox.hp = fox.max_hp
	fox.provoked = false
	fox.attack_remaining = 0.0
	fox.windup_remaining = 0.0
	fox._sync_state()
	fox.global_position = player.global_position + Vector2(30.0, 0.0)
	fox.attack_remaining = 0.0
	gameplay.set("_target", fox)
	gameplay.set("_attack_remaining", 0.0)
	gameplay.set("_auto_attack_enabled", true)
	for _tick in range(3):
		await process_frame
	if not _expect(fox.hp < fox.max_hp and fox.provoked, "Selected target did not take a catalog basic auto-attack."):
		return false
	gameplay.set("_target", null)
	fox.global_position = fox_origin
	fox.hp = fox.max_hp
	fox.provoked = false
	fox.attack_remaining = 0.0
	fox._sync_state()
	state.hp = hp_before

	var wolf := actors.get("wolf_1") as CreatureActor
	var wolf_origin := wolf.global_position
	player.global_position = wolf_origin + Vector2(-60.0, 0.0)
	wolf.attack_remaining = 0.0
	var wolf_hp_before: float = state.hp
	for _tick in range(50):
		if state.hp < wolf_hp_before:
			break
		await physics_frame
	if not _expect(state.hp < wolf_hp_before, "Wolf did not close the short gap and attack aggressively."):
		return false
	state.hp = wolf_hp_before
	player.global_position = player_origin
	wolf.global_position = wolf_origin
	wolf.attack_remaining = 0.0
	wolf._sync_state()

	var bear := actors.get("bear_1") as CreatureActor
	var bear_origin := bear.global_position
	var beacon: Vector2 = gameplay.get("_beacon_position")
	player.global_position = beacon + Vector2(182.0, 0.0)
	bear.global_position = player.global_position + Vector2(40.0, 0.0)
	bear.attack_remaining = 0.0
	bear.windup_remaining = 0.0
	for _tick in range(3):
		await physics_frame
	if not _expect(bear.windup_remaining > 0.0, "Bear did not announce its slow strike before damage."):
		return false
	player.global_position = beacon
	for _tick in range(70):
		await physics_frame
	if not _expect(state.hp == hp_before and bear.windup_remaining == 0.0, "Bear windup damaged the player after entering crystal refuge."):
		return false
	player.global_position = player_origin
	bear.global_position = bear_origin
	bear.attack_remaining = 0.0
	bear.windup_remaining = 0.0
	bear._sync_state()
	state.hp = hp_before
	gameplay.set("_auto_attack_enabled", true)
	return true


func _test_world_harvest(gameplay: Node2D, player: CharacterBody2D) -> bool:
	var state = gameplay.get("_state")
	var player_origin := player.global_position
	var resource_nodes: Array = gameplay.get("_resource_nodes")
	var targets := ["herb_20_20", "herb_25_25", "herb_35_21", "fiber_22_18"]
	for node_id in targets:
		var resource_entry: Dictionary = {}
		for node in resource_nodes:
			if str(node.get("id", "")) == node_id:
				resource_entry = node
				break
		if not _expect(not resource_entry.is_empty(), "World resource node %s did not spawn." % node_id):
			return false
		var actor: Node2D = resource_entry.get("actor")
		player.global_position = actor.global_position
		gameplay.interact_with_nearest()
		if not _expect(state.harvested_nodes.has(node_id), "Proximity interaction did not harvest %s." % node_id):
			return false
	var gained_herbs: int = state.amount("herb")
	var gained_fiber: int = state.amount("fiber")
	if not _expect(gained_herbs == 3 and gained_fiber == 5, "World harvest quantities differed from the layout."):
		return false
	player.global_position = player_origin
	return true


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
