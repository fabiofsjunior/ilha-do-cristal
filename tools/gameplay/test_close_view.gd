extends SceneTree
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void:
	OS.set_environment("GAMEPLAY_TEST_SAVE_DIR", "user://close_view_%d" % Time.get_ticks_usec())
	call_deferred("run")
func run() -> void:
	var game = load("res://game/scenes/first_island.tscn").instantiate()
	root.add_child(game)
	await process_frame
	var hud = game.get_node("HUD")
	for dimensions in [Vector2i(1280,720), Vector2i(720,1280), Vector2i(1920,1080)]:
		root.size = dimensions
		await process_frame
		hud._layout_safe_area()
		game._change_zoom(0)
		check(game._iso_view.follow_speed == 5.0, "Camera smoothing disabled")
		check(game._iso_view.camera.projection == Camera3D.PROJECTION_ORTHOGONAL and game._iso_view.camera.size <= 24.0, "Orthographic camera not configured")
		check(game._iso_view.camera.current, "3D camera is not active")
		check(game._iso_view.camera.rotation_degrees.is_equal_approx(Vector3(-30,45,0)), "Camera angles changed")
		var legacy_ground := game._iso_view.get_node_or_null("OriginalBeachAndStartGround") as MeshInstance3D
		var expanded_ground := game._iso_view.get_node_or_null("ExpandedTerrain_BaseTiles") as MeshInstance3D
		check(legacy_ground != null and expanded_ground != null and expanded_ground.mesh is ArrayMesh, "Legacy start patch or expanded 3D island surface missing")
		check(game._iso_view.actor_sprites.size() >= 2, "Player and monster 3D sprites missing")
		check(not hud._target_label.visible, "Empty target HUD visible")
		check(not hud._auto_attack_button.visible, "Autoattack button visible")
		check(hud._portrait.texture.region.size.y < 48, "Portrait shows full body")
		var screen := root.get_visible_rect()

		for control in [hud._portrait.get_parent(),hud._minimap,hud._interact_button,hud._joystick]:
			check(screen.grow(1).encloses(control.get_global_rect()), "Control outside viewport: %s" % control.name)
		for button in hud._skill_buttons.values():
			check(screen.grow(1).encloses(button.get_global_rect()), "Skill outside viewport: %s / %s" % [button.get_global_rect(),screen])
	game._set_target(game._creature_actors["fox_1"])
	await process_frame
	game._update_hud()
	check(hud._target_label.visible, "Selected target hidden")
	var target = game._creature_actors["fox_1"]
	var marker := game._iso_view.selection_sprites.get("fox_1") as Sprite3D
	check(is_instance_valid(marker) and marker.visible, "Selected enemy ground marker missing")
	if is_instance_valid(marker):
		check(marker.billboard == BaseMaterial3D.BILLBOARD_DISABLED, "Target marker is still a vertical billboard")
		check(is_equal_approx(marker.rotation_degrees.x, -90.0), "Target marker is not flat and facing upward on the ground")
		check(marker.texture.get_size() == Vector2(48, 48), "Target marker texture is oversized")
		check(marker.position.distance_to(Vector3(target.global_position.x / 32.0, 0.035, target.global_position.y / 32.0 + 0.5)) < 0.001, "Target marker is not aligned with enemy feet")
	check(game.get_node("Actors").y_sort_enabled, "Depth sorting disabled")
	print("Close view regression: %d failures" % failures)
	quit(failures)
