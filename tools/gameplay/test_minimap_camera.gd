extends SceneTree
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void:
	OS.set_environment("GAMEPLAY_TEST_SAVE_DIR", "user://minimap_%d" % Time.get_ticks_usec())
	call_deferred("run")
func run() -> void:
	var game = load("res://game/scenes/first_island.tscn").instantiate()
	root.add_child(game)
	await process_frame
	var minimap = game._hud._minimap
	for dimensions in [Vector2i(720,1280), Vector2i(1280,720), Vector2i(1080,2400)]:
		root.size = dimensions
		await process_frame
		for zoom_index in range(game.ORTHOGONAL_SIZES.size()):
			game._change_zoom(zoom_index - game._current_zoom_index)
			await process_frame
			game._update_hud()
			var view: PackedVector2Array = game._iso_view.minimap_camera_view()
			check(minimap.camera_uv(view[0]).is_equal_approx(Vector2.ZERO), "Camera origin not mapped to minimap origin")
			check(minimap.camera_uv(view[0]+view[1]).is_equal_approx(Vector2(1,0)), "Camera right rotated or mirrored")
			check(minimap.camera_uv(view[0]+view[2]).is_equal_approx(Vector2(0,1)), "Camera down rotated or mirrored")
			var center := view[0]+(view[1]+view[2])*0.5
			check(minimap.marker_visible(center), "Visible center marker culled")
			check(not minimap.marker_visible(view[0]), "Rectangle corner leaks beyond circle")
			check(not minimap.marker_visible(center+view[1]*2), "Off-camera enemy visible")
			var screen: Vector2 = game._iso_view.camera.unproject_position(game._iso_view.world_point(center))
			check(screen.distance_to(root.get_visible_rect().size*0.5) < 0.1, "Minimap ground center differs from camera center")
		game._change_zoom(-100)
		var wide: PackedVector2Array = game._iso_view.minimap_camera_view()
		game._change_zoom(100)
		var close: PackedVector2Array = game._iso_view.minimap_camera_view()
		check(wide[1].length() > close[1].length(), "Camera zoom does not shrink minimap world area")
	game.queue_free()
	await process_frame
	print("Minimap camera regression: %d failures" % failures)
	quit(failures)
