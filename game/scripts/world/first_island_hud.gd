extends CanvasLayer

signal pause_pressed
signal interact_pressed
signal joystick_moved(value: Vector2)
signal zoom_requested(delta: int)
signal inventory_pressed
signal camp_pressed
signal auto_attack_toggled(enabled: bool)
signal skill_pressed(skill_id: String)
signal bandage_pressed
signal craft_bandage_pressed
signal upgrade_camp_pressed
signal cycle_target_pressed
signal respawn_pressed

const UI_STYLE = preload("res://game/scripts/ui/ui_style.gd")
const JOYSTICK = preload("res://game/scripts/ui/virtual_joystick.gd")
const COMBAT_RULES = preload("res://game/scripts/combat/combat_rules.gd")
const BAG_ITEM_IDS := [
	"wood", "stone", "fiber", "herb", "bandage", "meat", "hide", "fang", "crystal_shard",
	"sword_basic", "sword_reinforced", "axe_basic", "pickaxe_basic"
]
const ITEM_LABELS := {
	"wood": "Madeira", "stone": "Pedra", "fiber": "Fibra", "herb": "Erva",
	"bandage": "Curativo", "meat": "Carne", "hide": "Couro", "fang": "Presa",
	"crystal_shard": "Fragmento", "sword_basic": "Espada", "sword_reinforced": "Espada reforçada",
	"axe_basic": "Machado", "pickaxe_basic": "Picareta"
}

var _joystick: Control
var _root: Control
var _hp_text: Label
var _mp_text: Label
var _xp_bar: ProgressBar
var _target_bar: ProgressBar
var _target_portrait: TextureRect
var _portrait: TextureRect
var _status: Label
var _name_label: Label
var _hp_bar: ProgressBar
var _mp_bar: ProgressBar
var _level_label: Label
var _target_label: Label
var _interact_button: Button
var _auto_attack_button: Button
var _bandage_button: Button
var _skill_buttons: Dictionary = {}
var _inventory_overlay: Control
var _camp_overlay: Control
var _downed_panel: PanelContainer
var _downed_label: Label
var _bag_slots: Array[Button] = []
var _item_detail: Label
var _use_bandage_button: Button
var _craft_bandage_button: Button
var _camp_summary: Label
var _camp_upgrade_button: Button
var _downed_shade: ColorRect
var _inventory_items: Dictionary = {}
var _camp_level := 1
var _selected_item := ""
var _auto_attack_enabled := true


func _ready() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)
	_build_hud()
	_build_inventory_overlay()
	_build_camp_overlay()
	_build_downed_panel()
	get_viewport().size_changed.connect(_layout_safe_area)
	_layout_safe_area()


func _build_hud() -> void:
	# All HUD positions use a 720-wide logical portrait canvas; the world expands.
	var header := PanelContainer.new()
	header.position = Vector2(12, 16)
	header.custom_minimum_size = Vector2(410, 164)
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_theme_stylebox_override("panel", UI_STYLE.panel_style(Color(0.08, 0.10, 0.12, 0.94), Color("b19a70")))
	_root.add_child(header)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(row)
	_portrait = TextureRect.new()
	_portrait.custom_minimum_size = Vector2(82, 116)
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(_portrait)
	var bars := VBoxContainer.new()
	bars.custom_minimum_size.x = 292
	bars.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(bars)
	_name_label = Label.new()
	UI_STYLE.style_label(_name_label, 20, UI_STYLE.GOLD)
	_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bars.add_child(_name_label)
	_hp_bar = _make_bar("HP", Color("bd393e"))
	bars.add_child(_hp_bar)
	_hp_text = _bar_caption(_hp_bar)
	_mp_bar = _make_bar("MP", Color("237dba"))
	bars.add_child(_mp_bar)
	_mp_text = _bar_caption(_mp_bar)
	_xp_bar = _make_bar("EXP", Color("408442"))
	bars.add_child(_xp_bar)
	_level_label = _bar_caption(_xp_bar)

	var target_panel := PanelContainer.new()
	target_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	target_panel.position = Vector2(-286, 16)
	target_panel.custom_minimum_size = Vector2(274, 116)
	target_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	target_panel.add_theme_stylebox_override("panel", UI_STYLE.panel_style(Color(0.12, 0.06, 0.06, 0.93), Color("bd5350")))
	_root.add_child(target_panel)
	var target_box := VBoxContainer.new()
	target_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	target_panel.add_child(target_box)
	_target_label = Label.new()
	_target_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_target_label.custom_minimum_size = Vector2(244, 56)
	_target_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UI_STYLE.style_label(_target_label, 20, UI_STYLE.CREAM)
	var target_row := HBoxContainer.new()
	target_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	target_box.add_child(target_row)
	_target_portrait = TextureRect.new()
	_target_portrait.custom_minimum_size = Vector2(64, 64)
	_target_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_target_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_target_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	target_row.add_child(_target_portrait)
	_target_label.custom_minimum_size.x = 174
	target_row.add_child(_target_label)
	_target_bar = _make_bar("Alvo", Color("bd393e"))
	target_box.add_child(_target_bar)
	_hud_button("Trocar alvo", Vector2(-206, 140), Vector2(194, 56), func() -> void: cycle_target_pressed.emit(), Control.PRESET_TOP_RIGHT)
	_hud_button("Mochila", Vector2(12, 192), Vector2(122, 62), _toggle_inventory)
	_hud_button("Refúgio", Vector2(142, 192), Vector2(122, 62), _toggle_camp)
	_hud_button("Ⅱ", Vector2(272, 192), Vector2(62, 62), func() -> void: pause_pressed.emit())
	_hud_button("−", Vector2(342, 192), Vector2(62, 62), func() -> void: zoom_requested.emit(-1))
	_hud_button("+", Vector2(412, 192), Vector2(62, 62), func() -> void: zoom_requested.emit(1))
	_status = Label.new()
	_status.position = Vector2(18, 266)
	_status.size = Vector2(684, 70)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UI_STYLE.style_label(_status, 19, UI_STYLE.CREAM)
	_status.add_theme_color_override("font_outline_color", Color("11151b"))
	_status.add_theme_constant_override("outline_size", 6)
	_root.add_child(_status)

	var joystick = JOYSTICK.new()
	_joystick = joystick
	joystick.name = "VirtualJoystick"
	joystick.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	joystick.position = Vector2(20, -252)
	joystick.size = Vector2(216, 216)
	joystick.radius = 96.0
	joystick.vector_changed.connect(func(value: Vector2) -> void: joystick_moved.emit(value))
	_root.add_child(joystick)
	_interact_button = _hud_button("Interagir", Vector2(20, -326), Vector2(216, 62), func() -> void: interact_pressed.emit(), Control.PRESET_BOTTOM_LEFT)
	_bandage_button = _hud_button("Curativo", Vector2(-132, -406), Vector2(112, 100), func() -> void: bandage_pressed.emit(), Control.PRESET_BOTTOM_RIGHT, Color("318e52"), true)
	_auto_attack_button = _hud_button("Espada\nAuto ON", Vector2(-164, -162), Vector2(144, 136), _toggle_auto_attack, Control.PRESET_BOTTOM_RIGHT, Color("bd7729"), true)
	var skills := [
		["war_combo", "Combo\n10 MP", Vector2(-286, -150), Color("ba5928")],
		["war_circle", "Corte\n15 MP", Vector2(-298, -280), Color("9250bf")],
		["war_quake", "Terremoto\n35 MP", Vector2(-156, -286), Color("3a8a9c")]
	]
	for data in skills:
		var id := str(data[0])
		var button := _hud_button(str(data[1]), data[2], Vector2(112, 100), func() -> void: skill_pressed.emit(id), Control.PRESET_BOTTOM_RIGHT, data[3], true)
		_skill_buttons[id] = button


func _bar_caption(bar: ProgressBar) -> Label:
	var label := Label.new()
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UI_STYLE.style_label(label, 19, UI_STYLE.CREAM)
	label.add_theme_color_override("font_outline_color", Color("15151b"))
	label.add_theme_constant_override("outline_size", 4)
	bar.add_child(label)
	return label


func _hud_button(text: String, point: Vector2, dimensions: Vector2, action: Callable, preset := Control.PRESET_TOP_LEFT, tint := Color("786d58"), round_button := false) -> Button:
	var button := Button.new()
	button.text = text
	button.set_anchors_preset(preset)
	button.position = point
	button.custom_minimum_size = dimensions
	button.size = dimensions
	UI_STYLE.style_button(button)
	button.add_theme_font_size_override("font_size", 20)
	for state in ["normal", "hover", "pressed", "disabled"]:
		var style := UI_STYLE.panel_style(Color("182027").lerp(tint, 0.25), tint)
		if round_button:
			style.set_corner_radius_all(48)
			style.set_border_width_all(3)
		if state == "pressed":
			style.bg_color = tint.darkened(0.25)
		if state == "disabled":
			style.bg_color = Color("202125")
			style.border_color = Color("55545b")
		button.add_theme_stylebox_override(state, style)
	button.pressed.connect(action)
	_root.add_child(button)
	return button


func _make_bar(label_text: String, fill_color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(118, 30)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.min_value = 0
	bar.max_value = 1
	bar.value = 1
	bar.show_percentage = false
	bar.tooltip_text = label_text
	var background := StyleBoxFlat.new()
	background.bg_color = Color("211821")
	background.border_color = Color("e4d7bd")
	background.set_border_width_all(1)
	bar.add_theme_stylebox_override("background", background)
	var fill := StyleBoxFlat.new()
	fill.bg_color = fill_color
	bar.add_theme_stylebox_override("fill", fill)
	return bar


func _make_hotbar_button(label_text: String, primary: bool) -> Button:
	var button := Button.new()
	button.text = label_text
	button.custom_minimum_size = Vector2(112, 74)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UI_STYLE.style_button(button, primary)
	return button


func _build_inventory_overlay() -> void:
	_inventory_overlay = _make_overlay()
	_root.add_child(_inventory_overlay)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_inventory_overlay.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(668, 1080)
	panel.add_theme_stylebox_override("panel", UI_STYLE.panel_style(Color("241d31"), Color("a77ce8")))
	center.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 10)
	margin.add_child(stack)
	var heading := HBoxContainer.new()
	stack.add_child(heading)
	var title := Label.new()
	title.text = "Mochila"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UI_STYLE.style_label(title, 25, UI_STYLE.CREAM)
	heading.add_child(title)
	var close := _close_button()
	close.pressed.connect(func() -> void: _inventory_overlay.hide())
	heading.add_child(close)
	var columns := VBoxContainer.new()
	columns.add_theme_constant_override("separation", 12)
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stack.add_child(columns)
	var equipment_panel := _subpanel("ITENS EQUIPADOS", Vector2(210, 0))
	columns.add_child(equipment_panel)
	var equipment_box := _subpanel_stack(equipment_panel)
	equipment_box.add_theme_constant_override("separation", 7)
	var equipment_grid := GridContainer.new()
	equipment_grid.columns = 6
	equipment_grid.add_theme_constant_override("h_separation", 4)
	equipment_grid.add_theme_constant_override("v_separation", 4)
	equipment_box.add_child(equipment_grid)
	var equipment_items := ["—", "Capacete", "Amuleto", "Espada", "Armadura", "Mão livre", "Joia", "Calça", "Joia", "—", "Botas", "—"]
	for item_name in equipment_items:
		var slot := Label.new()
		slot.text = str(item_name)
		slot.custom_minimum_size = Vector2(58, 58)
		slot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		slot.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		slot.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		slot.add_theme_stylebox_override("normal", UI_STYLE.panel_style(Color("171421"), Color("75608c")))
		UI_STYLE.style_label(slot, 10, UI_STYLE.MUTED if str(item_name) == "—" else UI_STYLE.GOLD)
		equipment_grid.add_child(slot)
	var equipment_note := Label.new()
	equipment_note.text = "Espada improvisada equipada"
	equipment_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UI_STYLE.style_label(equipment_note, 12, UI_STYLE.MUTED)
	equipment_box.add_child(equipment_note)

	var bag_panel := _subpanel("BAG SLOT · 0 / 24", Vector2(490, 0))
	columns.add_child(bag_panel)
	var bag_box := _subpanel_stack(bag_panel)
	bag_box.add_theme_constant_override("separation", 8)
	var bag_grid := GridContainer.new()
	bag_grid.columns = 6
	bag_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bag_grid.add_theme_constant_override("h_separation", 5)
	bag_grid.add_theme_constant_override("v_separation", 5)
	bag_box.add_child(bag_grid)
	for index in range(24):
		var slot := Button.new()
		slot.text = ""
		slot.custom_minimum_size = Vector2(68, 66)
		slot.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		UI_STYLE.style_button(slot)
		slot.pressed.connect(func() -> void: _select_bag_slot(index))
		bag_grid.add_child(slot)
		_bag_slots.append(slot)
	var bag_hint := Label.new()
	bag_hint.text = "Recursos e consumíveis desta expedição."
	UI_STYLE.style_label(bag_hint, 12, UI_STYLE.MUTED)
	bag_box.add_child(bag_hint)
	var detail_panel := _subpanel("DETALHES", Vector2(250, 0))
	columns.add_child(detail_panel)
	var detail_box := _subpanel_stack(detail_panel)
	detail_box.add_theme_constant_override("separation", 9)
	_item_detail = Label.new()
	_item_detail.text = "Selecione um item para ver a quantidade e a ação disponível."
	_item_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_item_detail.size_flags_vertical = Control.SIZE_EXPAND_FILL
	UI_STYLE.style_label(_item_detail, 13, UI_STYLE.CREAM)
	detail_box.add_child(_item_detail)
	_craft_bandage_button = Button.new()
	_craft_bandage_button.text = "Fabricar curativo\n3 ervas + 1 fibra"
	_craft_bandage_button.custom_minimum_size.y = 62
	UI_STYLE.style_button(_craft_bandage_button, true)
	_craft_bandage_button.pressed.connect(func() -> void: craft_bandage_pressed.emit())
	detail_box.add_child(_craft_bandage_button)
	_use_bandage_button = Button.new()
	_use_bandage_button.text = "Usar curativo"
	_use_bandage_button.custom_minimum_size.y = 48
	UI_STYLE.style_button(_use_bandage_button)
	_use_bandage_button.pressed.connect(func() -> void: bandage_pressed.emit())
	detail_box.add_child(_use_bandage_button)
	_refresh_inventory()


func _build_camp_overlay() -> void:
	_camp_overlay = _make_overlay()
	_root.add_child(_camp_overlay)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_camp_overlay.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(668, 580)
	panel.add_theme_stylebox_override("panel", UI_STYLE.panel_style(Color("241d31"), Color("a77ce8")))
	center.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 26)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_right", 26)
	margin.add_theme_constant_override("margin_bottom", 22)
	panel.add_child(margin)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 13)
	margin.add_child(stack)
	var heading := HBoxContainer.new()
	stack.add_child(heading)
	var title := Label.new()
	title.text = "Refúgio"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UI_STYLE.style_label(title, 27, UI_STYLE.CREAM)
	heading.add_child(title)
	var close := _close_button()
	close.pressed.connect(func() -> void: _camp_overlay.hide())
	heading.add_child(close)
	_camp_summary = Label.new()
	_camp_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_camp_summary.size_flags_vertical = Control.SIZE_EXPAND_FILL
	UI_STYLE.style_label(_camp_summary, 15, UI_STYLE.CREAM)
	stack.add_child(_camp_summary)
	_camp_upgrade_button = Button.new()
	_camp_upgrade_button.custom_minimum_size.y = 60
	UI_STYLE.style_button(_camp_upgrade_button, true)
	_camp_upgrade_button.pressed.connect(func() -> void: upgrade_camp_pressed.emit())
	stack.add_child(_camp_upgrade_button)
	var note := Label.new()
	note.text = "O cristal protege a área próxima e permite recuperar HP e MP."
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UI_STYLE.style_label(note, 12, UI_STYLE.MUTED)
	stack.add_child(note)
	_refresh_camp()


func _build_downed_panel() -> void:
	_downed_shade = ColorRect.new()
	_downed_shade.name = "DownedShade"
	_downed_shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_downed_shade.color = Color(0.05, 0.04, 0.09, 0.74)
	_downed_shade.mouse_filter = Control.MOUSE_FILTER_STOP
	_downed_shade.hide()
	_root.add_child(_downed_shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_downed_shade.add_child(center)
	_downed_panel = PanelContainer.new()
	_downed_panel.custom_minimum_size = Vector2(410, 270)
	_downed_panel.add_theme_stylebox_override("panel", UI_STYLE.panel_style(Color("241d31"), Color("a77ce8")))
	center.add_child(_downed_panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	_downed_panel.add_child(box)
	var title := Label.new()
	title.text = "Você está caído"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UI_STYLE.style_label(title, 25, UI_STYLE.CREAM)
	box.add_child(title)
	_downed_label = Label.new()
	_downed_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UI_STYLE.style_label(_downed_label, 18, UI_STYLE.GOLD)
	box.add_child(_downed_label)
	var return_button := Button.new()
	return_button.text = "Voltar à barraca agora"
	return_button.custom_minimum_size.y = 52
	UI_STYLE.style_button(return_button, true)
	return_button.pressed.connect(func() -> void: respawn_pressed.emit())
	box.add_child(return_button)
	var note := Label.new()
	note.text = "No solo, o retorno não espera por outro jogador. Metade dos materiais desta expedição fica numa mochila persistente."
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UI_STYLE.style_label(note, 12, UI_STYLE.MUTED)
	box.add_child(note)
	_downed_panel.get_parent().hide()


func _make_overlay() -> Control:
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.05, 0.04, 0.09, 0.78)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	shade.hide()
	return shade


func _subpanel(title_text: String, min_size: Vector2) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = min_size
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", UI_STYLE.panel_style(Color("201b29"), Color("75608c")))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 8)
	margin.add_child(stack)
	var title := Label.new()
	title.text = title_text
	UI_STYLE.style_label(title, 12, UI_STYLE.GOLD)
	stack.add_child(title)
	return panel


func _subpanel_stack(panel: PanelContainer) -> VBoxContainer:
	var matches := panel.find_children("*", "VBoxContainer", true, false)
	return matches[0] as VBoxContainer if not matches.is_empty() else VBoxContainer.new()


func _close_button() -> Button:
	var close := Button.new()
	close.text = "✕"
	close.custom_minimum_size = Vector2(46, 42)
	UI_STYLE.style_button(close)
	return close


func _toggle_inventory() -> void:
	_inventory_overlay.visible = not _inventory_overlay.visible
	if _inventory_overlay.visible:
		_camp_overlay.hide()
		inventory_pressed.emit()
		_refresh_inventory()


func _toggle_camp() -> void:
	_camp_overlay.visible = not _camp_overlay.visible
	if _camp_overlay.visible:
		_inventory_overlay.hide()
		camp_pressed.emit()
		_refresh_camp()


func _toggle_auto_attack() -> void:
	_auto_attack_enabled = not _auto_attack_enabled
	_auto_attack_button.text = "Espada\nAuto %s" % ("ON" if _auto_attack_enabled else "OFF")
	_auto_attack_button.modulate = Color.WHITE if _auto_attack_enabled else Color(0.65, 0.65, 0.65)
	auto_attack_toggled.emit(_auto_attack_enabled)


func _select_bag_slot(index: int) -> void:
	if index < 0 or index >= BAG_ITEM_IDS.size():
		_selected_item = ""
	else:
		_selected_item = BAG_ITEM_IDS[index]
	_update_item_detail()


func _refresh_inventory() -> void:
	if _bag_slots.is_empty():
		return
	var occupied := 0
	for item_id in BAG_ITEM_IDS:
		if int(_inventory_items.get(item_id, 0)) > 0:
			occupied += 1
	var title := _find_label(_inventory_overlay, "BAG SLOT ·")
	if title != null:
		title.text = "BAG SLOT · %d / 24" % occupied
	for index in range(_bag_slots.size()):
		var button := _bag_slots[index]
		if index >= BAG_ITEM_IDS.size():
			button.text = ""
			button.disabled = true
			continue
		var item_id: String = str(BAG_ITEM_IDS[index])
		var count := int(_inventory_items.get(item_id, 0))
		button.text = "%s\n×%d" % [str(ITEM_LABELS.get(item_id, item_id)), count] if count > 0 else ""
		button.tooltip_text = str(ITEM_LABELS.get(item_id, item_id))
		button.disabled = count <= 0
	_update_item_detail()
	if _craft_bandage_button != null:
		_craft_bandage_button.disabled = int(_inventory_items.get("herb", 0)) < 3 or int(_inventory_items.get("fiber", 0)) < 1
	if _use_bandage_button != null:
		_use_bandage_button.disabled = int(_inventory_items.get("bandage", 0)) <= 0
	if _bandage_button != null:
		_bandage_button.text = "Curativo\n%d" % int(_inventory_items.get("bandage", 0))
		_bandage_button.disabled = int(_inventory_items.get("bandage", 0)) <= 0


func _update_item_detail() -> void:
	if _item_detail == null:
		return
	var count := int(_inventory_items.get(_selected_item, 0))
	if _selected_item.is_empty() or count <= 0:
		_item_detail.text = "Selecione um item para ver a quantidade e a ação disponível."
	else:
		_item_detail.text = "%s\n\nQuantidade: %d" % [str(ITEM_LABELS.get(_selected_item, _selected_item)), count]
		if _selected_item == "bandage":
			_item_detail.text += "\nRestaura 40 HP em 4 s; atacar interrompe o uso."
		elif _selected_item == "crystal_shard":
			_item_detail.text += "\nComponente do acampamento nível III."
		elif _selected_item in ["wood", "stone", "fiber", "herb"]:
			_item_detail.text += "\nMaterial de coleta e construção."


func _refresh_camp() -> void:
	if _camp_summary == null:
		return
	var next_level := _camp_level + 1
	if _camp_level >= 3:
		_camp_summary.text = "Acampamento nível III\n\nCerca e duas torres liberadas. A fatia solo não inclui defesa automática das torres."
		_camp_upgrade_button.text = "Nível máximo"
		_camp_upgrade_button.disabled = true
		return
	var cost := _camp_upgrade_cost(next_level)
	var lines := ["Acampamento nível %d" % _camp_level, "", "Melhoria para nível %d:" % next_level]
	var can_afford := true
	for item_id in cost:
		var amount := int(_inventory_items.get(item_id, 0))
		var label := str(ITEM_LABELS.get(item_id, item_id))
		lines.append("• %s  %d / %d" % [label, amount, int(cost[item_id])])
		if amount < int(cost[item_id]):
			can_afford = false
	if next_level == 2:
		lines.append("Libera bancada, baú compartilhado e poço.")
	else:
		lines.append("Libera cerca e até duas torres.")
	_camp_summary.text = "\n".join(lines)
	_camp_upgrade_button.text = "Melhorar acampamento"
	_camp_upgrade_button.disabled = not can_afford


func _camp_upgrade_cost(to_level: int) -> Dictionary:
	for upgrade in COMBAT_RULES.catalog().get("camp_upgrades", []):
		if int(upgrade.get("to_level", 0)) == to_level:
			return upgrade.get("requires", {}).duplicate(true)
	return {}


func _find_label(parent: Node, prefix: String) -> Label:
	for child in parent.find_children("*", "Label", true, false):
		var label := child as Label
		if label.text.begins_with(prefix):
			return label
	return null


func set_character_name(value: String) -> void:
	if _name_label != null:
		_name_label.text = "%s · Guerreiro" % value
		var profiles = preload("res://game/scripts/actors/appearance_data.gd")
		for profile in profiles.profiles():
			if str(profile.get("name", "")) == value:
				var metadata_path := str(profile.get("idle_metadata", ""))
				var metadata: Dictionary = profiles.metadata(metadata_path)
				var frame := AtlasTexture.new()
				frame.atlas = load(profiles.atlas_path(metadata_path, metadata))
				var cell: Array = metadata.get("cell", [96, 96])
				var directions: Array = metadata.get("directions", [])
				frame.region = Rect2(0, maxi(0, directions.find("S")) * int(cell[1]), int(cell[0]), int(cell[1]))
				_portrait.texture = frame


func set_status(value: String) -> void:
	if _status != null:
		_status.text = value


func set_interaction_available(available: bool) -> void:
	set_interaction_prompt("E · Interagir", available)


func set_interaction_prompt(value: String, available: bool) -> void:
	if _interact_button != null:
		_interact_button.text = value
		_interact_button.disabled = not available
		_interact_button.modulate = Color.WHITE if available else Color(0.78, 0.76, 0.82, 0.72)


func set_combat_state(
	hp: float,
	max_hp: float,
	mp: float,
	max_mp: float,
	level: int,
	xp_into_level: int,
	xp_for_level: int,
	items: Dictionary,
	camp_level: int,
	bandage_active: bool,
	bandage_progress: float,
	selected_target: String,
	target_hp: float,
	target_max_hp: float,
	down_remaining: float,
	cooldowns: Dictionary
) -> void:
	if _hp_bar != null:
		_hp_bar.max_value = maxf(1.0, max_hp)
		_hp_bar.value = hp
		_hp_text.text = "HP %d / %d" % [ceili(hp), roundi(max_hp)]
		_hp_bar.tooltip_text = "HP %d / %d" % [roundi(hp), roundi(max_hp)]
		_hp_bar.modulate = Color.WHITE
	if _mp_bar != null:
		_mp_bar.max_value = maxf(1.0, max_mp)
		_mp_bar.value = mp
		_mp_text.text = "MP %d / %d" % [floori(mp), roundi(max_mp)]
		_mp_bar.tooltip_text = "MP %d / %d" % [roundi(mp), roundi(max_mp)]
	if _level_label != null:
		_level_label.text = "Nv. %d · EXP %d / %d" % [level, xp_into_level, xp_for_level]
		_xp_bar.max_value = maxi(1, xp_for_level)
		_xp_bar.value = xp_into_level
	_inventory_items = items.duplicate(true)
	_camp_level = camp_level
	_refresh_inventory()
	_refresh_camp()
	if selected_target.is_empty():
		_target_label.text = "Toque num monstro\nou troque o alvo"
		_target_bar.value = 0
		_target_portrait.texture = null
	else:
		var species := str({"Raposa": "fox", "Lobo": "wolf", "Urso": "bear"}.get(selected_target, ""))
		if not species.is_empty():
			_target_portrait.texture = load("res://assets/creatures/%s/%s_se_candidate_v1.png" % [species, species])
		_target_bar.max_value = maxf(1.0, target_max_hp)
		_target_bar.value = target_hp
		_target_label.text = "%s\nHP %d / %d" % [selected_target, roundi(target_hp), roundi(target_max_hp)]
	if bandage_active:
		_bandage_button.text = "Curando\n%d%%" % roundi(bandage_progress * 25.0)
		_bandage_button.disabled = true
	if down_remaining >= 0.0:
		_downed_shade.show()
		_downed_label.text = "Retorno solo em %02d s" % ceili(down_remaining)
	else:
		_downed_shade.hide()
	if _skill_buttons.has("war_combo"):
		_update_skill_button("war_combo", "Combo", mp, cooldowns)
		_update_skill_button("war_circle", "Corte", mp, cooldowns)
		_update_skill_button("war_quake", "Terremoto", mp, cooldowns)
	if not bandage_active:
		_bandage_button.text = "Curativo\n%d" % int(_inventory_items.get("bandage", 0))
		_bandage_button.disabled = int(_inventory_items.get("bandage", 0)) <= 0


func _update_skill_button(skill_id: String, label: String, current_mp: float, cooldowns: Dictionary) -> void:
	var button: Button = _skill_buttons.get(skill_id)
	if button == null:
		return
	var mana_cost := int(COMBAT_RULES.skill(skill_id).get("mp", 0))
	var remaining := float(cooldowns.get(skill_id, 0.0))
	var suffix := "%.0f s" % remaining if remaining > 0.0 else "%d MP" % mana_cost
	button.text = "%s\n%s" % [label, suffix]
	button.disabled = current_mp < mana_cost or remaining > 0.0


func set_target_feedback(value: String) -> void:
	if _target_label != null:
		_target_label.text = value


func toggle_inventory_from_game() -> void:
	_toggle_inventory()


func _layout_safe_area() -> void:
	# The world stays edge-to-edge; only controls respect camera cutouts.
	if OS.get_name() != "Android":
		return
	var safe := DisplayServer.get_display_safe_area()
	var screen := DisplayServer.screen_get_size()
	if screen.x <= 0 or screen.y <= 0 or safe.size == Vector2i.ZERO:
		return
	var ratio := get_viewport().get_visible_rect().size / Vector2(screen)
	_root.offset_left = safe.position.x * ratio.x
	_root.offset_top = safe.position.y * ratio.y
	_root.offset_right = -(screen.x - safe.end.x) * ratio.x
	_root.offset_bottom = -(screen.y - safe.end.y) * ratio.y


func _process(_delta: float) -> void:
	_joystick.set_blocked(_inventory_overlay.visible or _camp_overlay.visible or _downed_shade.visible)


func release_movement() -> void:
	_joystick.set_blocked(true)
