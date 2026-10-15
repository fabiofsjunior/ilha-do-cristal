extends Node2D
## Technical QA scene for Maíra Warrior's two-direction prototype only.
const BASE := "res://assets/characters/maira/warrior/"
const DIRECTIONS := ["N", "S"]
const STATES := ["idle", "walk"]

var actor := AnimatedSprite2D.new()
var info := Label.new()
var direction := "S"
var animation_name := "idle"
var sqm := 48
var zoom_value := 0.75
var available := false
var specimen := Node2D.new()
var cell_size := Vector2(96, 96)
var pivot := Vector2(48, 80)

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("333a43"))
	add_child(specimen)
	specimen.position = Vector2(940, 430)
	specimen.add_child(actor)
	actor.centered = false
	actor.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_build_controls()
	_refresh()

func _build_controls() -> void:
	var ui := CanvasLayer.new()
	add_child(ui)
	var box := VBoxContainer.new()
	box.position = Vector2(24, 20)
	box.custom_minimum_size.x = 500
	ui.add_child(box)
	var title := Label.new()
	title.text = "Maíra Warrior — protótipo técnico | arte NÃO aprovada para produção"
	box.add_child(title)

	var directions := OptionButton.new()
	directions.name = "Direction"
	for value in DIRECTIONS:
		directions.add_item(value)
	directions.select(1)
	directions.item_selected.connect(_on_direction_selected)
	box.add_child(directions)

	var states := OptionButton.new()
	states.name = "Animation"
	for value in STATES:
		states.add_item(value)
	states.item_selected.connect(_on_animation_selected)
	box.add_child(states)

	var zoom := HSlider.new()
	zoom.name = "Zoom"
	zoom.min_value = 0.5
	zoom.max_value = 1.25
	zoom.step = 0.01
	zoom.value = zoom_value
	zoom.custom_minimum_size.x = 400
	zoom.value_changed.connect(_on_zoom_changed)
	box.add_child(zoom)

	var background := OptionButton.new()
	background.add_item("Fundo escuro")
	background.add_item("Fundo claro")
	background.item_selected.connect(func(index: int) -> void:
		RenderingServer.set_default_clear_color([Color("333a43"), Color("e9e0cc")][index])
	)
	box.add_child(background)

	var size := OptionButton.new()
	size.add_item("SQM 32 px (candidato)")
	size.add_item("SQM 48 px (candidato)")
	size.select(1)
	size.item_selected.connect(func(index: int) -> void:
		sqm = [32, 48][index]
		queue_redraw()
	)
	box.add_child(size)

	var pause := Button.new()
	pause.text = "Pausar / continuar"
	pause.pressed.connect(_on_pause_pressed)
	box.add_child(pause)

	var step := Button.new()
	step.text = "Próximo frame"
	step.pressed.connect(_on_step_pressed)
	box.add_child(step)
	info.custom_minimum_size.y = 56
	box.add_child(info)

func _on_direction_selected(index: int) -> void:
	direction = DIRECTIONS[index]
	_refresh()

func _on_animation_selected(index: int) -> void:
	animation_name = STATES[index]
	_refresh()

func _on_zoom_changed(value: float) -> void:
	zoom_value = value
	specimen.scale = Vector2.ONE * zoom_value
	_refresh_status()
	queue_redraw()

func _on_pause_pressed() -> void:
	if actor.is_playing():
		actor.pause()
	elif available:
		actor.play(animation_name)

func _on_step_pressed() -> void:
	if available:
		actor.pause()
		actor.frame = (actor.frame + 1) % actor.sprite_frames.get_frame_count(animation_name)

func _refresh() -> void:
	specimen.scale = Vector2.ONE * zoom_value
	actor.stop()
	available = false
	actor.visible = false
	var metadata_path := BASE + "maira_warrior_" + animation_name + "_candidate_v1.json"
	if not FileAccess.file_exists(metadata_path):
		info.text = "Metadados ausentes: " + metadata_path
		push_error(info.text)
		return
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(metadata_path))
	if not parsed is Dictionary:
		info.text = "JSON inválido: " + metadata_path
		push_error(info.text)
		return
	var metadata: Dictionary = parsed
	for key in ["atlas", "cell", "pivot", "directions", "animations"]:
		if not metadata.has(key):
			info.text = "Metadados sem campo '%s': %s" % [key, metadata_path]
			push_error(info.text)
			return
	if not metadata["directions"] is Array or not metadata["animations"] is Dictionary:
		info.text = "Estrutura inválida em: " + metadata_path
		push_error(info.text)
		return
	if not metadata["animations"].has(animation_name) or metadata["cell"].size() != 2 or metadata["pivot"].size() != 2:
		info.text = "Configuração ausente/inválida: " + metadata_path
		push_error(info.text)
		return
	cell_size = Vector2(metadata["cell"][0], metadata["cell"][1])
	pivot = Vector2(metadata["pivot"][0], metadata["pivot"][1])
	var row: int = metadata["directions"].find(direction)
	var atlas_path: String = BASE + metadata["atlas"]
	if row < 0 or not ResourceLoader.exists(atlas_path):
		info.text = "Direção ou atlas ausente: %s / %s" % [direction, atlas_path]
		push_error(info.text)
		return
	var texture := load(atlas_path) as Texture2D
	var config: Dictionary = metadata["animations"][animation_name]
	var expected_size := Vector2i(int(cell_size.x) * int(config["frames"]), int(cell_size.y) * metadata["directions"].size())
	if texture == null or texture.get_size() != expected_size:
		info.text = "Dimensões incompatíveis: " + atlas_path
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
		frame.region = Rect2(Vector2(column * cell_size.x, row * cell_size.y), cell_size)
		frames.add_frame(animation_name, frame)
	actor.position = -pivot
	actor.sprite_frames = frames
	actor.animation = animation_name
	actor.visible = true
	actor.play(animation_name)
	available = true
	_refresh_status()
	queue_redraw()

func _refresh_status() -> void:
	info.text = "CORRIGIR — %s / %s | zoom %.0f%% | célula %d×%d | pivô %.0f,%.0f | Godot/Android pendentes" % [animation_name, direction, zoom_value * 100, int(cell_size.x), int(cell_size.y), pivot.x, pivot.y]

func _draw() -> void:
	var origin := Vector2(940, 430)
	var unit := float(sqm) * zoom_value
	for offset in range(-5, 6):
		draw_line(origin + Vector2(offset * unit, -5 * unit), origin + Vector2(offset * unit, 5 * unit), Color("53614c"))
		draw_line(origin + Vector2(-5 * unit, offset * unit), origin + Vector2(5 * unit, offset * unit), Color("53614c"))
	draw_rect(Rect2(origin - pivot * zoom_value, cell_size * zoom_value), Color("e5be66"), false)
	draw_line(origin - Vector2(8, 0), origin + Vector2(8, 0), Color.RED)
	draw_line(origin - Vector2(0, 8), origin + Vector2(0, 8), Color.RED)
