extends Control

signal resume_requested
signal session_requested
signal start_requested
signal save_requested
signal zoom_requested(delta: int)
signal simplified_changed(enabled: bool)

const UI_STYLE = preload("res://game/scripts/ui/ui_style.gd")
var _save_status: Label
var simplified := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var overlay_layer := CanvasLayer.new()
	overlay_layer.name = "PauseCanvasLayer"
	overlay_layer.layer = 10
	overlay_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(overlay_layer)
	var overlay_root := Control.new()
	overlay_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay_layer.add_child(overlay_root)
	var shade := ColorRect.new()
	shade.color = Color(0.05, 0.04, 0.09, 0.78)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay_root.add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay_root.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(480, 580)
	panel.add_theme_stylebox_override(
		"panel", UI_STYLE.KIT.style("panel", 28.0)
	)
	center.add_child(panel)
	var stack := VBoxContainer.new()
	stack.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.add_theme_constant_override("separation", 14)
	panel.add_child(stack)
	var title := Label.new()
	title.text = "Jogo pausado"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UI_STYLE.style_label(title, 28, UI_STYLE.CREAM)
	stack.add_child(title)
	var resume := _button("Retomar", true)
	resume.pressed.connect(func() -> void: resume_requested.emit())
	stack.add_child(resume)
	var save := _button("Salvar")
	save.name = "SaveButton"
	save.icon = UI_STYLE.icon("save")
	save.expand_icon = true
	save.add_theme_constant_override("icon_max_width", 26)
	save.pressed.connect(func() -> void: save_requested.emit())
	stack.add_child(save)
	for category in [["Música", "Music"], ["Efeitos", "SFX"], ["Ambiente", "Ambience"]]:
		var row := HBoxContainer.new()
		stack.add_child(row)
		var label := Label.new()
		label.text = category[0]
		label.custom_minimum_size.x = 100
		UI_STYLE.style_label(label, 16, UI_STYLE.CREAM)
		row.add_child(label)
		var slider := HSlider.new()
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slider.custom_minimum_size.y = 44
		slider.max_value = 1.0
		slider.step = 0.05
		slider.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		slider.add_theme_stylebox_override("slider", UI_STYLE.panel_style(Color("232031"), UI_STYLE.GOLD))
		slider.add_theme_stylebox_override("grabber_area", UI_STYLE.panel_style(Color("1698ba"), UI_STYLE.BLUE))
		for state in ["grabber", "grabber_highlight", "grabber_disabled"]:
			slider.add_theme_icon_override(state, UI_STYLE.icon("slider_knob"))
		var bus := AudioServer.get_bus_index(category[1])
		slider.editable = bus >= 0
		slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus)) if bus >= 0 else 0.0
		slider.tooltip_text = "Áudio ainda não disponível" if bus < 0 else category[0]
		if bus >= 0:
			slider.value_changed.connect(func(value: float) -> void: AudioServer.set_bus_volume_db(bus, linear_to_db(maxf(value, 0.0001))))
		row.add_child(slider)
	if AudioServer.get_bus_index("Music") < 0:
		var audio_note := Label.new()
		audio_note.text = "Áudio ainda indisponível nesta versão."
		UI_STYLE.style_label(audio_note, 13, UI_STYLE.MUTED)
		stack.add_child(audio_note)
	var simple := CheckButton.new()
	simple.text = "Interface simplificada"
	simple.button_pressed = simplified
	simple.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	simple.add_theme_icon_override("checked", UI_STYLE.icon("toggle_on"))
	simple.add_theme_icon_override("unchecked", UI_STYLE.icon("toggle_off"))
	simple.custom_minimum_size.y = 48
	simple.toggled.connect(func(enabled: bool) -> void: simplified_changed.emit(enabled))
	stack.add_child(simple)
	var zoom := HBoxContainer.new()
	zoom.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.add_child(zoom)
	for step in [-1, 1]:
		var button := _button("Zoom −" if step < 0 else "Zoom +")
		button.custom_minimum_size.x = 150
		button.pressed.connect(func() -> void: zoom_requested.emit(step))
		zoom.add_child(button)
	var session := _button("Voltar à sessão local")
	session.pressed.connect(func() -> void: session_requested.emit())
	stack.add_child(session)
	var start := _button("Voltar ao início")
	start.pressed.connect(func() -> void: start_requested.emit())
	stack.add_child(start)
	_save_status = Label.new()
	_save_status.name = "SaveStatus"
	_save_status.text = "Salvar mantém seu progresso neste dispositivo."
	_save_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_save_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UI_STYLE.style_label(_save_status, 13, UI_STYLE.MUTED)
	stack.add_child(_save_status)
	resume.grab_focus()

func show_save_result(success: bool) -> void:
	_save_status.text = "✓ Jogo salvo" if success else "Falha ao salvar. Verifique o espaço livre e tente novamente."
	_save_status.modulate = Color("a6f0a2") if success else Color("ff9292")


func _button(text: String, primary := false) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(300, 48)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	UI_STYLE.style_button(button, primary)
	return button


