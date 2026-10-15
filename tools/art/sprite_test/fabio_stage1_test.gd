extends Node2D
## Technical QA for Fábio Warrior stage 1 only; no gameplay implementation.

const BASE := "res://assets/characters/fabio/warrior/"
const DIRECTIONS := ["N", "S"]
const ANIMATIONS := ["idle", "walk"]
const CANDIDATES := ["v1", "v2"]

var actor := AnimatedSprite2D.new()
var specimen := Node2D.new()
var info := Label.new()
var direction := "S"
var animation_name := "idle"
var candidate_index := 1
var sqm := 48
var zoom_value := 0.75
var cell_size := Vector2(96, 96)
var pivot := Vector2(48, 80)
var available := false


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
	box.custom_minimum_size.x = 560
	ui.add_child(box)

	var title := Label.new()
	title.text = "Fábio Warrior — etapa 1 | CANDIDATO, NÃO APROVADO"
	box.add_child(title)

	var candidate := OptionButton.new()
	candidate.name = "Candidate"
	candidate.add_item("V1 — escala original (CORRIGIR)")
	candidate.add_item("V2 — ajuste geométrico N (CORRIGIR)")
	candidate.select(candidate_index)
	candidate.item_selected.connect(func(index: int) -> void:
		candidate_index = index
		_refresh()
	)
	box.add_child(candidate)

	var directions := OptionButton.new()
	directions.name = "Direction"
	for value in DIRECTIONS:
		directions.add_item(value)
	directions.select(1)
	directions.item_selected.connect(func(index: int) -> void:
		direction = DIRECTIONS[index]
		_refresh()
	)
	box.add_child(directions)

	var animations := OptionButton.new()
	animations.name = "Animation"
	for value in ANIMATIONS:
		animations.add_item(value)
	animations.item_selected.connect(func(index: int) -> void:
		animation_name = ANIMATIONS[index]
		_refresh()
	)
	box.add_child(animations)

	var zoom := HSlider.new()
	zoom.name = "Zoom"
	zoom.min_value = 0.5
	zoom.max_value = 1.25
	zoom.step = 0.01
	zoom.value = zoom_value
	zoom.custom_minimum_size.x = 420
	zoom.value_changed.connect(func(value: float) -> void:
		zoom_value = value
		specimen.scale = Vector2.ONE * zoom_value
		_refresh_status()
		queue_redraw()
	)
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

	var playback := HBoxContainer.new()
	var pause := Button.new()
	pause.text = "Pausar / continuar"
	pause.pressed.connect(func() -> void:
		if actor.is_playing():
			actor.pause()
		elif available:
			actor.play(animation_name)
	)
	playback.add_child(pause)

	var step := Button.new()
	step.text = "Próximo frame"
	step.pressed.connect(func() -> void:
		if available:
			actor.pause()
			actor.frame = (actor.frame + 1) % actor.sprite_frames.get_frame_count(animation_name)
	)
	playback.add_child(step)
	box.add_child(playback)

	info.custom_minimum_size.y = 58
	box.add_child(info)


func _refresh() -> void:
	specimen.scale = Vector2.ONE * zoom_value
	actor.stop()
	actor.visible = false
	available = false

	var version: String = CANDIDATES[candidate_index]
	var metadata_path := BASE + "fabio_warrior_" + animation_name + "_candidate_" + version + ".json"
	if not FileAccess.file_exists(metadata_path):
		_set_error("Metadados ausentes: " + metadata_path)
		return

	var parsed = JSON.parse_string(FileAccess.get_file_as_string(metadata_path))
	if not parsed is Dictionary:
		_set_error("JSON inválido: " + metadata_path)
		return
	var metadata: Dictionary = parsed
	for key in ["atlas", "cell", "pivot", "directions", "animations"]:
		if not metadata.has(key):
			_set_error("Metadados sem campo '%s': %s" % [key, metadata_path])
			return
	if not metadata["animations"] is Dictionary or not metadata["animations"].has(animation_name):
		_set_error("Animação ausente nos metadados: " + metadata_path)
		return

	var row: int = metadata["directions"].find(direction)
	if row < 0:
		_set_error("Direção pendente: " + direction)
		return
	cell_size = Vector2(metadata["cell"][0], metadata["cell"][1])
	pivot = Vector2(metadata["pivot"][0], metadata["pivot"][1])
	var atlas_path: String = BASE + metadata["atlas"]
	if not ResourceLoader.exists(atlas_path):
		_set_error("Atlas ausente: " + atlas_path)
		return

	var texture := load(atlas_path) as Texture2D
	var config: Dictionary = metadata["animations"][animation_name]
	var expected_size := Vector2i(
		int(cell_size.x) * int(config["frames"]),
		int(cell_size.y) * metadata["directions"].size()
	)
	if texture == null or texture.get_size() != expected_size:
		_set_error("Dimensões incompatíveis: " + atlas_path)
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


func _set_error(message: String) -> void:
	info.text = message
	push_error(message)
	queue_redraw()


func _refresh_status() -> void:
	info.text = "CORRIGIR — %s / %s / %s | zoom %.0f%% | célula %d×%d | pivô %.0f,%.0f | Godot/Android pendentes" % [
		CANDIDATES[candidate_index], animation_name, direction, zoom_value * 100,
		int(cell_size.x), int(cell_size.y), pivot.x, pivot.y
	]


func _draw() -> void:
	var origin := Vector2(940, 430)
	var unit := float(sqm) * zoom_value
	for offset in range(-5, 6):
		draw_line(origin + Vector2(offset * unit, -5 * unit), origin + Vector2(offset * unit, 5 * unit), Color("53614c"))
		draw_line(origin + Vector2(-5 * unit, offset * unit), origin + Vector2(5 * unit, offset * unit), Color("53614c"))
	draw_rect(Rect2(origin - pivot * zoom_value, cell_size * zoom_value), Color("e5be66"), false)
	draw_line(origin - Vector2(8, 0), origin + Vector2(8, 0), Color.RED)
	draw_line(origin - Vector2(0, 8), origin + Vector2(0, 8), Color.RED)
