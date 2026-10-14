extends Node2D
## Technical QA only; missing atlases stay visible as an error, never placeholders.
const BASE := "res://assets/characters/melissa/warrior/"
const DIRECTIONS := ["N", "NE", "E", "SE", "S", "SO", "O", "NO"]
var actor := AnimatedSprite2D.new()
var info := Label.new()
var direction := "S"
var animation_name := "idle"
var sqm := 48
var zoom_value := 0.75
var specimen := Node2D.new()
var available := false
var candidate_suffix := "_candidate_v2"

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("333a43"))
	add_child(specimen)
	specimen.position = Vector2(900, 400)
	specimen.add_child(actor)
	actor.position = Vector2(-48, -80)
	actor.centered = false
	actor.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var ui := CanvasLayer.new()
	ui.name = "CanvasLayer"
	add_child(ui)
	var box := VBoxContainer.new()
	box.name = "VBoxContainer"
	box.position = Vector2(24, 20)
	ui.add_child(box)
	var title := Label.new()
	title.text = "Melissa Warrior — CANDIDATO CORRIGIR; aprovação visual/Android pendente"
	box.add_child(title)
	var candidate := OptionButton.new()
	candidate.name = "Candidate"
	candidate.add_item("v1 — candidato anterior")
	candidate.add_item("v2 — candidato overhead")
	candidate.select(1)
	candidate.item_selected.connect(func(index: int): candidate_suffix = ["", "_candidate_v2"][index]; _refresh())
	box.add_child(candidate)
	var background := OptionButton.new()
	background.add_item("Fundo escuro")
	background.add_item("Fundo claro")
	background.item_selected.connect(func(index: int): RenderingServer.set_default_clear_color([Color("333a43"), Color("e9e0cc")][index]))
	box.add_child(background)
	var directions := OptionButton.new()
	directions.name = "Direction"
	for d in DIRECTIONS:
		directions.add_item(d)
	directions.select(4)
	directions.item_selected.connect(func(index: int): direction = DIRECTIONS[index]; _refresh())
	box.add_child(directions)
	var states := OptionButton.new()
	states.name = "State"
	for state in ["idle", "walk"]:
		states.add_item(state)
	states.item_selected.connect(func(index: int): animation_name = ["idle", "walk"][index]; _refresh())
	box.add_child(states)
	var zoom := HSlider.new()
	zoom.name = "Zoom"
	zoom.min_value = 0.5
	zoom.max_value = 1.25
	zoom.step = 0.01
	zoom.value = zoom_value
	zoom.custom_minimum_size.x = 400
	zoom.value_changed.connect(func(value: float): zoom_value = value; _refresh())
	box.add_child(zoom)
	var size := OptionButton.new()
	for pixels in [32, 48]:
		size.add_item("SQM %d px (candidato)" % pixels)
	size.select(1)
	size.item_selected.connect(func(index: int): sqm = [32, 48][index]; queue_redraw())
	box.add_child(size)
	var pause := Button.new()
	pause.text = "Pausar / continuar"
	pause.pressed.connect(func():
		if actor.is_playing(): actor.pause()
		elif available: actor.play()
	)
	box.add_child(pause)
	var step := Button.new()
	step.text = "Próximo frame"
	step.pressed.connect(func():
		if available:
			actor.pause()
			actor.frame = (actor.frame + 1) % actor.sprite_frames.get_frame_count(actor.animation)
	)
	box.add_child(step)
	box.add_child(info)
	_refresh()

func _refresh() -> void:
	var controls := get_node("CanvasLayer/VBoxContainer")
	controls.get_node("Candidate").select(1 if candidate_suffix else 0)
	controls.get_node("Direction").select(DIRECTIONS.find(direction))
	controls.get_node("State").select(["idle", "walk"].find(animation_name))
	controls.get_node("Zoom").set_value_no_signal(zoom_value)
	specimen.scale = Vector2.ONE * zoom_value
	actor.stop()
	available = false
	var path := BASE + "melissa_warrior_" + animation_name + candidate_suffix + ".json"
	if not FileAccess.file_exists(path):
		info.text = "Metadados ausentes: " + path
		push_error(info.text)
		return
	var metadata = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not metadata is Dictionary:
		info.text = "JSON inválido: " + path
		push_error(info.text)
		return
	var config: Dictionary = metadata["animations"][animation_name]
	var row: int = metadata["directions"].find(direction)
	if row < 0:
		actor.visible = false
		info.text = "%s pendente — etapa 1 contém apenas N e S | zoom %.0f%%" % [direction, zoom_value * 100]
		queue_redraw()
		return
	var png_path: String = BASE + metadata["atlas"]
	if not ResourceLoader.exists(png_path):
		actor.visible = false
		info.text = "Atlas pendente: " + png_path
		queue_redraw()
		return
	var texture := load(png_path) as Texture2D
	var cell := Vector2(metadata["cell"][0], metadata["cell"][1])
	if texture.get_size() != Vector2(cell.x * int(config["frames"]), cell.y * metadata["directions"].size()):
		info.text = "Dimensões incompatíveis com contrato: " + png_path
		actor.visible = false
		push_error(info.text)
		return
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	frames.add_animation(animation_name)
	frames.set_animation_speed(animation_name, config["fps"])
	frames.set_animation_loop(animation_name, config["loop"])
	for column in range(int(config["frames"])):
		var frame := AtlasTexture.new()
		frame.atlas = texture
		frame.region = Rect2(Vector2(column * cell.x, row * cell.y), cell)
		frames.add_frame(animation_name, frame)
	actor.position = -Vector2(metadata["pivot"][0], metadata["pivot"][1])
	actor.sprite_frames = frames
	actor.visible = true
	actor.play(animation_name)
	available = true
	info.text = "%s / %s | zoom %.0f%% | célula 96×96 | pivô 48,80\nPausar + próximo frame: revisar cada quadro. Android pendente." % [animation_name, direction, zoom_value * 100]
	queue_redraw()

func _draw() -> void:
	var origin := Vector2(900, 400)
	var unit := float(sqm) * zoom_value
	for offset in range(-5, 6):
		draw_line(origin + Vector2(offset * unit, -5 * unit), origin + Vector2(offset * unit, 5 * unit), Color("53614c"))
		draw_line(origin + Vector2(-5 * unit, offset * unit), origin + Vector2(5 * unit, offset * unit), Color("53614c"))
	draw_rect(Rect2(origin - Vector2(48, 80) * zoom_value, Vector2(96, 96) * zoom_value), Color("e5be66"), false)
	draw_line(origin - Vector2(8, 0), origin + Vector2(8, 0), Color.RED)
	draw_line(origin - Vector2(0, 8), origin + Vector2(0, 8), Color.RED)
