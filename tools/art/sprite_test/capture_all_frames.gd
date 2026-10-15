extends SceneTree
## Every frame is rendered as an AtlasTexture by Godot, no raster compositing.
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

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Actual rendering display required")
		quit(1)
		return
	root.size = Vector2i(1920, 1400)
	root.content_scale_size = Vector2i(1920, 1400)
	RenderingServer.set_default_clear_color(Color("333a43"))
	var candidate_index := _candidate_index()
	var candidate_suffix: String = ["", "_candidate_v2", "_candidate_v3"][candidate_index]
	var evidence_folder: String = "res://docs/art/evidence/godot_" + CANDIDATE_IDS[candidate_index]
	DirAccess.make_dir_recursive_absolute(evidence_folder)
	var stage := Node2D.new()
	stage.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	root.add_child(stage)
	var title := Label.new()
	title.position = Vector2(24, 8)
	title.text = "Melissa Warrior %s — CORRIGIR — 20 quadros reais Godot, nearest 3×; não é validação Android" % CANDIDATE_IDS[candidate_index].to_upper()
	stage.add_child(title)
	var row := 0
	for state in ["idle", "walk"]:
		var base: String = "res://assets/characters/melissa/warrior/melissa_warrior_" + state + candidate_suffix
		var metadata: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(base + ".json"))
		var texture := load(base + ".png") as Texture2D
		for direction in range(2):
			for column in range(int(metadata["frames"])):
				var position := Vector2(24 + column * 308, 64 + row * 328)
				var label := Label.new()
				label.position = position
				label.text = "%s %s quadro %d" % [state, metadata["directions"][direction], column]
				stage.add_child(label)
				var background := ColorRect.new()
				background.position = position + Vector2(0, 28)
				background.size = Vector2(288, 288)
				background.color = Color("e9e0cc") if column % 2 else Color("28333e")
				stage.add_child(background)
				var atlas := AtlasTexture.new()
				atlas.atlas = texture
				atlas.region = Rect2(column * 96, direction * 96, 96, 96)
				var sprite := Sprite2D.new()
				sprite.centered = false
				sprite.texture = atlas
				sprite.position = background.position
				sprite.scale = Vector2(3, 3)
				stage.add_child(sprite)
			row += 1
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var result := image.save_png(evidence_folder + "/all_20_frames_3x.png")
	if result != OK:
		push_error("Screenshot save failed")
		quit(1)
		return
	print("Captured all 20 frames for %s with real Godot rendering at 3x." % CANDIDATE_IDS[candidate_index].to_upper())
	quit(0)
