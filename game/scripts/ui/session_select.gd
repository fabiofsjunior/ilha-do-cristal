extends Control

signal back_requested
signal host_solo_requested
signal host_lan_requested
signal join_lan_requested(address: String)
var lan
var _address: LineEdit
var _rooms: OptionButton
var _room_codes: Array = []

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
	panel.custom_minimum_size = Vector2(656, 790)
	panel.add_theme_stylebox_override(
		"panel", UI_STYLE.classic_style()
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
	var actions := VBoxContainer.new()
	actions.size_flags_vertical = Control.SIZE_EXPAND_FILL
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 24)
	stack.add_child(actions)
	actions.add_child(
		_session_card(
			"Hospedar solo",
			"Abre uma sessão local de demonstração, sem rede, com salvamento local.",
			"Entrar na ilha",
			true
		)
	)
	actions.add_child(
		_session_card(
			"Entrar",
			"Mesmo Wi-Fi: selecione uma sala, digite o código ou o IP local. Combate e saves ainda são locais.",
			"Conectar via Wi-Fi",
			false
		)
	)
	var wifi := Button.new()
	wifi.text = "Hospedar Wi-Fi · 2 jogadores"
	wifi.custom_minimum_size.y = 56
	UI_STYLE.style_button(wifi, true)
	wifi.pressed.connect(func(): host_lan_requested.emit())
	stack.add_child(wifi)
	_status = Label.new()
	_status.text = "LAN: movimento compartilhado; combate, itens e saves locais."
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.custom_minimum_size.y = 44
	UI_STYLE.style_label(_status, 14, UI_STYLE.MUTED)
	stack.add_child(_status)


func _session_card(title_text: String, detail: String, button_text: String, host: bool) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(300, 235)
	panel.add_theme_stylebox_override(
		"panel", UI_STYLE.classic_style()
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
		_rooms = OptionButton.new()
		_rooms.add_item("Procurar salas Wi-Fi…")
		_rooms.item_selected.connect(func(index: int):
			if index > 0: _address.text = _rooms.get_item_text(index)
		)
		box.add_child(_rooms)
		var address := LineEdit.new()
		_address = address
		address.placeholder_text = "Código da sala ou IP local"
		address.editable = true
		address.custom_minimum_size = Vector2(245, 42)
		box.add_child(address)
	var action := Button.new()
	action.text = button_text
	action.custom_minimum_size.y = 50
	UI_STYLE.style_button(action, host)
	if host:
		action.pressed.connect(func() -> void: host_solo_requested.emit())
	else:
		action.pressed.connect(func(): join_lan_requested.emit(_address.text))
	box.add_child(action)
	return panel


func show_status(message: String) -> void:
	_status.text = message

func _process(_delta: float) -> void:
	if lan == null or _rooms == null: return
	var codes: Array = lan.rooms.keys()
	codes.sort()
	if _room_codes == codes: return
	_room_codes = codes.duplicate()
	_rooms.clear()
	_rooms.add_item("Salas Wi-Fi encontradas")
	for code in codes: _rooms.add_item(str(code))
