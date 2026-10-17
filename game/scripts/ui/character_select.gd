extends Control

signal back_requested
signal confirm_requested(character_id: String)

const UI_STYLE = preload("res://game/scripts/ui/ui_style.gd")
const APPEARANCE_DATA = preload("res://game/scripts/actors/appearance_data.gd")
const FALLBACK_ID := "melissa"
var selected_character_id := FALLBACK_ID
var _description: Label
var _selected_name: Label
var _confirm_button: Button
var _choice_buttons: Array[Button] = []


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_screen()


func _build_screen() -> void:
	var background := ColorRect.new()
	background.color = Color("171421")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 18)
	add_child(margin)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 12)
	margin.add_child(stack)
	var header := HBoxContainer.new()
	stack.add_child(header)
	var back := Button.new()
	back.text = "← Voltar"
	UI_STYLE.style_button(back)
	back.pressed.connect(func() -> void: back_requested.emit())
	header.add_child(back)
	var title := Label.new()
	title.text = "Escolha sua aparência"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UI_STYLE.style_label(title, 28, UI_STYLE.CREAM)
	header.add_child(title)
	var spacer := Control.new()
	spacer.custom_minimum_size.x = 0
	header.add_child(spacer)

	var intro := Label.new()
	intro.text = (
		"Vocação disponível nesta fatia: Guerreiro. As quatro aparências e animações "
		+ "seguem como CANDIDATO/CORRIGIR."
	)
	intro.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UI_STYLE.style_label(intro, 15, UI_STYLE.MUTED)
	stack.add_child(intro)

	var cards := GridContainer.new()
	cards.columns = 2
	cards.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cards.add_theme_constant_override("separation", 14)
	stack.add_child(cards)
	for profile in APPEARANCE_DATA.profiles():
		cards.add_child(_make_card(profile))

	var footer := PanelContainer.new()
	footer.add_theme_stylebox_override(
		"panel", UI_STYLE.panel_style(Color("241d31"), Color("75608c"))
	)
	stack.add_child(footer)
	var footer_row := VBoxContainer.new()
	footer_row.add_theme_constant_override("separation", 14)
	footer.add_child(footer_row)
	_selected_name = Label.new()
	_selected_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UI_STYLE.style_label(_selected_name, 17, UI_STYLE.GOLD)
	footer_row.add_child(_selected_name)
	_confirm_button = Button.new()
	_confirm_button.text = "Continuar para a sessão"
	_confirm_button.custom_minimum_size = Vector2(300, 54)
	UI_STYLE.style_button(_confirm_button, true)
	_confirm_button.pressed.connect(func() -> void: confirm_requested.emit(selected_character_id))
	footer_row.add_child(_confirm_button)
	_update_selection()


func _make_card(profile: Dictionary) -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(290, 340)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var id := str(profile.get("id", ""))
	card.name = "Appearance_%s" % id
	card.add_theme_stylebox_override(
		"panel", UI_STYLE.panel_style(Color("211b2b"), Color("594b69"))
	)
	var body := VBoxContainer.new()
	body.alignment = BoxContainer.ALIGNMENT_CENTER
	body.add_theme_constant_override("separation", 8)
	card.add_child(body)
	var preview := TextureRect.new()
	preview.custom_minimum_size = Vector2(130, 150)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var metadata_path := str(profile.get("idle_metadata", ""))
	var metadata: Dictionary = APPEARANCE_DATA.metadata(metadata_path)
	var atlas_path := APPEARANCE_DATA.atlas_path(metadata_path, metadata)
	if atlas_path.is_empty() or not ResourceLoader.exists(atlas_path):
		push_error("Atlas ausente para %s: %s" % [id, atlas_path])
	else:
		var atlas := load(atlas_path) as Texture2D
		var directions: Array = metadata.get("directions", [])
		var south_row := directions.find("S")
		var cell: Array = metadata.get("cell", [96, 96])
		if atlas != null and south_row >= 0 and cell.size() >= 2:
			var frame := AtlasTexture.new()
			frame.atlas = atlas
			frame.region = Rect2(
				Vector2(0, south_row * int(cell[1])), Vector2(int(cell[0]), int(cell[1]))
			)
			preview.texture = frame
	body.add_child(preview)
	var name := Label.new()
	name.text = str(profile.get("name", id))
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UI_STYLE.style_label(name, 20, UI_STYLE.CREAM)
	body.add_child(name)
	var status := Label.new()
	status.text = "Guerreiro · %s" % str(metadata.get("status", "metadata ausente")).to_upper()
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UI_STYLE.style_label(status, 12, UI_STYLE.GOLD)
	body.add_child(status)
	var description := Label.new()
	description.text = str(profile.get("description", ""))
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.custom_minimum_size.y = 50
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UI_STYLE.style_label(description, 13, UI_STYLE.MUTED)
	body.add_child(description)
	var choose := Button.new()
	choose.text = "Selecionar"
	choose.set_meta("appearance_id", id)
	UI_STYLE.style_button(choose, id == selected_character_id)
	choose.pressed.connect(
		func() -> void:
			selected_character_id = id
			_update_selection()
	)
	body.add_child(choose)
	_choice_buttons.append(choose)
	return card


func _update_selection() -> void:
	var profile: Dictionary = APPEARANCE_DATA.profile_for_id(selected_character_id)
	if profile.is_empty():
		selected_character_id = FALLBACK_ID
		profile = APPEARANCE_DATA.profile_for_id(selected_character_id)
	if _selected_name != null:
		_selected_name.text = "Selecionado: %s · Guerreiro" % str(profile.get("name", ""))
	for button in _choice_buttons:
		var id := str(button.get_meta("appearance_id", ""))
		button.text = "Selecionado" if id == selected_character_id else "Selecionar"
		UI_STYLE.style_button(button, id == selected_character_id)
