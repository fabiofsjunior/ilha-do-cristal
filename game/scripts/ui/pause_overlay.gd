extends Control

signal resume_requested
signal session_requested
signal start_requested

const UI_STYLE = preload("res://game/scripts/ui/ui_style.gd")


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
	panel.custom_minimum_size = Vector2(420, 380)
	panel.add_theme_stylebox_override(
		"panel", UI_STYLE.panel_style(Color("241d31"), Color("a77ce8"))
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
	var session := _button("Voltar à sessão local")
	session.pressed.connect(func() -> void: session_requested.emit())
	stack.add_child(session)
	var start := _button("Voltar ao início")
	start.pressed.connect(func() -> void: start_requested.emit())
	stack.add_child(start)
	var note := Label.new()
	note.text = "O progresso é salvo localmente ao pausar."
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UI_STYLE.style_label(note, 13, UI_STYLE.MUTED)
	stack.add_child(note)


func _button(text: String, primary := false) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(300, 48)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	UI_STYLE.style_button(button, primary)
	return button
