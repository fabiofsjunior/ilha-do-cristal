extends Control

signal begin_requested

const UI_STYLE = preload("res://game/scripts/ui/ui_style.gd")


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
	margin.add_theme_constant_override("margin_left", 32)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 32)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)

	var center := CenterContainer.new()
	margin.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(620, 500)
	panel.add_theme_stylebox_override(
		"panel", UI_STYLE.panel_style(Color("241d31"), Color("a77ce8"))
	)
	center.add_child(panel)

	var inside_margin := MarginContainer.new()
	inside_margin.add_theme_constant_override("margin_left", 42)
	inside_margin.add_theme_constant_override("margin_top", 34)
	inside_margin.add_theme_constant_override("margin_right", 42)
	inside_margin.add_theme_constant_override("margin_bottom", 34)
	panel.add_child(inside_margin)

	var stack := VBoxContainer.new()
	stack.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.add_theme_constant_override("separation", 16)
	inside_margin.add_child(stack)

	var gem := Label.new()
	gem.text = "✧"
	gem.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UI_STYLE.style_label(gem, 42, UI_STYLE.BLUE)
	stack.add_child(gem)

	var kicker := Label.new()
	kicker.text = "AVENTURA COOPERATIVA · ANDROID"
	kicker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UI_STYLE.style_label(kicker, 14, UI_STYLE.GOLD)
	stack.add_child(kicker)

	var title := Label.new()
	title.text = "A ILHA DO CRISTAL"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UI_STYLE.style_label(title, 40, UI_STYLE.CREAM)
	stack.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Quatro aventureiros, uma ilha desconhecida e um refúgio para construir juntos."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UI_STYLE.style_label(subtitle, 18, UI_STYLE.MUTED)
	stack.add_child(subtitle)

	var begin_button := Button.new()
	begin_button.text = "Continuar como visitante"
	begin_button.custom_minimum_size = Vector2(360, 62)
	begin_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	UI_STYLE.style_button(begin_button, true)
	begin_button.pressed.connect(func() -> void: begin_requested.emit())
	stack.add_child(begin_button)

	var flow_note := Label.new()
	flow_note.text = "Sem conta nesta fatia · escolha uma aparência e hospede uma ilha solo."
	flow_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	flow_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UI_STYLE.style_label(flow_note, 14, UI_STYLE.MUTED)
	stack.add_child(flow_note)

	var art_note := Label.new()
	art_note.text = "Demonstração jogável · personagens e terreno ainda são candidatos."
	art_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UI_STYLE.style_label(art_note, 13, UI_STYLE.BLUE)
	stack.add_child(art_note)
