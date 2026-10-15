extends Control

signal back_requested
signal host_solo_requested

const UI_STYLE = preload("res://game/scripts/ui/ui_style.gd")
var character_name := "Aventureiro"
var _status: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_screen()


func _build_screen() -> void:
	var bg := ColorRect.new()
	bg.color = Color("171421")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(760, 520)
	panel.add_theme_stylebox_override(
		"panel", UI_STYLE.panel_style(Color("241d31"), Color("a77ce8"))
	)
	center.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 32)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_right", 32)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 14)
	margin.add_child(stack)
	var header := HBoxContainer.new()
	stack.add_child(header)
	var back := Button.new()
	back.text = "← Personagem"
	UI_STYLE.style_button(back)
	back.pressed.connect(func() -> void: back_requested.emit())
	header.add_child(back)
	var title := Label.new()
	title.text = "Criar / entrar na ilha"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UI_STYLE.style_label(title, 28, UI_STYLE.CREAM)
	header.add_child(title)
	var selected := Label.new()
	selected.text = "Aparência: %s" % character_name
	selected.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UI_STYLE.style_label(selected, 16, UI_STYLE.GOLD)
	stack.add_child(selected)
	var actions := HBoxContainer.new()
	actions.size_flags_vertical = Control.SIZE_EXPAND_FILL
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 24)
	stack.add_child(actions)
	actions.add_child(
		_session_card(
			"Hospedar solo",
			"Abre uma sessão local de demonstração, sem rede e sem salvamento.",
			"Entrar na ilha",
			true
		)
	)
	actions.add_child(
		_session_card(
			"Entrar",
			"O endereço e a descoberta LAN ainda não conectam nesta fatia.",
			"Testar entrada",
			false
		)
	)
	_status = Label.new()
	_status.text = "LAN, contas e save ainda não existem. Hospedar solo inicia apenas o mapa local."
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.custom_minimum_size.y = 44
	UI_STYLE.style_label(_status, 14, UI_STYLE.MUTED)
	stack.add_child(_status)


func _session_card(title_text: String, detail: String, button_text: String, host: bool) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(300, 235)
	panel.add_theme_stylebox_override(
		"panel", UI_STYLE.panel_style(Color("211b2b"), Color("594b69"))
	)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)
	var title := Label.new()
	title.text = title_text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UI_STYLE.style_label(title, 22, UI_STYLE.GOLD)
	box.add_child(title)
	var detail_label := Label.new()
	detail_label.text = detail
	detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_label.custom_minimum_size = Vector2(245, 80)
	detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UI_STYLE.style_label(detail_label, 14, UI_STYLE.MUTED)
	box.add_child(detail_label)
	if not host:
		var address := LineEdit.new()
		address.placeholder_text = "Endereço local (mock)"
		address.editable = false
		address.custom_minimum_size = Vector2(245, 42)
		box.add_child(address)
	var action := Button.new()
	action.text = button_text
	action.custom_minimum_size.y = 50
	UI_STYLE.style_button(action, host)
	if host:
		action.pressed.connect(func() -> void: host_solo_requested.emit())
	else:
		action.pressed.connect(_show_mock_connection_error)
	box.add_child(action)
	return panel


func _show_mock_connection_error() -> void:
	_status.text = (
		"Conexão indisponível: entrar via LAN é um mock e nenhum endereço foi usado. "
		+ "Você pode voltar ou hospedar solo."
	)
	UI_STYLE.style_label(_status, 14, UI_STYLE.GOLD)
