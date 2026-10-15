extends SceneTree
## Requires an actual rendering display; headless dummy screenshots are rejected.
const CANDIDATE_IDS := ["v1", "v2", "v3"]

func _initialize() -> void:
	call_deferred("_run")

func _candidate_index() -> int:
	var args := OS.get_cmdline_user_args()
	var has_candidate_argument := false
	for index in range(args.size()):
		var value := args[index]
		if value.begins_with("--candidate="):
			value = value.trim_prefix("--candidate=")
			has_candidate_argument = true
		elif value == "--candidate" and index + 1 < args.size():
			value = args[index + 1]
			has_candidate_argument = true
		else:
			continue
		var candidate_index := CANDIDATE_IDS.find(value.to_lower())
		if candidate_index >= 0:
			return candidate_index
	if has_candidate_argument:
		push_error("Unknown candidate argument; use --candidate=v1, v2, or v3. Defaulting to v2.")
	return 1

func _representative_mode() -> bool:
	return OS.get_cmdline_user_args().has("--representative")

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Capture requires X11/Wayland rendering; headless dummy is not evidence.")
		quit(1)
		return
	var scene = load("res://tools/art/sprite_test/sprite_test.tscn").instantiate()
	root.add_child(scene)
	var candidate_index := _candidate_index()
	scene.candidate_index = candidate_index
	var folder: String = "res://docs/art/evidence/godot_" + CANDIDATE_IDS[candidate_index]
	var zooms := [1.0] if _representative_mode() else [0.5, 0.75, 1.0, 1.25]
	DirAccess.make_dir_recursive_absolute(folder)
	for state in ["idle", "walk"]:
		for facing in ["N", "S"]:
			for value in zooms:
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
	print("Captured %d real rendered Godot viewport screenshots for %s; artistic/Android approval pending." % [zooms.size() * 4, CANDIDATE_IDS[candidate_index].to_upper()])
	quit(0)
