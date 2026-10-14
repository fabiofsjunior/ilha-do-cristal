extends SceneTree
## Every frame is rendered as an AtlasTexture by Godot, no raster compositing.
func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Actual rendering display required")
		quit(1)
		return
	root.size = Vector2i(1920, 1400)
	root.content_scale_size = Vector2i(1920, 1400)
	RenderingServer.set_default_clear_color(Color("333a43"))
	var stage := Node2D.new()
	stage.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	root.add_child(stage)
	var title := Label.new()
	title.position = Vector2(24, 8)
	title.text = "Melissa Warrior V2 — CORRIGIR — 20 quadros reais Godot, nearest 3×; não é validação Android"
	stage.add_child(title)
	var row := 0
	for state in ["idle", "walk"]:
		var base: String = "res://assets/characters/melissa/warrior/melissa_warrior_" + state + "_candidate_v2"
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
	var result := image.save_png("res://docs/art/evidence/godot_v2/all_20_frames_3x.png")
	if result != OK:
		push_error("Screenshot save failed")
		quit(1)
		return
	print("Captured all20 frames with real Godot rendering at3x.")
	quit(0)
