extends SceneTree
const KIT = preload("res://game/scripts/ui/crystal_kit.gd")
const STYLE = preload("res://game/scripts/ui/ui_style.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var screen := Control.new()
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(screen)
	var bg := ColorRect.new()
	bg.color = Color("131120")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.add_child(bg)
	var grid := GridContainer.new()
	grid.columns = 8
	grid.position = Vector2(20, 20)
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 8)
	screen.add_child(grid)
	for id in KIT.REGIONS:
		var texture := KIT.texture(id)
		assert(texture != null, id)
		assert(texture.get_size() == KIT.REGIONS[id].size, id)
		assert(texture.get_image().get_used_rect().has_area(), "Empty artwork: " + id)
		var box := VBoxContainer.new()
		grid.add_child(box)
		box.add_child(STYLE.picture(texture, Vector2(100, 64)))
		var title := Label.new()
		title.text = id
		STYLE.style_label(title, 11, STYLE.CREAM)
		box.add_child(title)
	await process_frame
	await process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("user://crystal-kit.png")
	print("PASS: all crystal kit regions loaded, bounded and nonempty")
	quit()

