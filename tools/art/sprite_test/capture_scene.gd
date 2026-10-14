extends SceneTree
## Requires an actual rendering display; headless dummy screenshots are rejected.
func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Capture requires X11/Wayland rendering; headless dummy is not evidence.")
		quit(1)
		return
	var scene = load("res://tools/art/sprite_test/sprite_test.tscn").instantiate()
	root.add_child(scene)
	var folder := "res://docs/art/evidence/godot_v2"
	DirAccess.make_dir_recursive_absolute(folder)
	for state in ["idle", "walk"]:
		for facing in ["N", "S"]:
			for value in [0.5, 0.75, 1.0, 1.25]:
				scene.animation_name = state
				scene.direction = facing
				scene.zoom_value = value
				scene._refresh()
				scene.actor.pause()
				scene.actor.frame = 0
				await process_frame
				await RenderingServer.frame_post_draw
				var image := root.get_texture().get_image()
				if image == null or image.is_empty():
					push_error("Rendered viewport empty")
					quit(1)
					return
				var path := "%s/%s_%s_zoom%d.png" % [folder, state, facing, roundi(value * 100)]
				var result := image.save_png(path)
				if result != OK:
					push_error("Screenshot save failed: " + path)
					quit(1)
					return
	print("Captured 16 real rendered Godot viewport screenshots; artistic/Android approval pending.")
	quit(0)
