extends CanvasLayer

signal pause_pressed
signal interact_pressed
signal joystick_moved(value: Vector2)
signal zoom_requested(delta: int)
signal inventory_pressed
signal camp_pressed
signal attributes_pressed
signal attributes_committed(state: Object)
signal auto_attack_toggled(enabled: bool)
signal skill_pressed(skill_id: String)
signal bandage_pressed
signal craft_bandage_pressed
signal upgrade_camp_pressed
signal cycle_target_pressed
signal respawn_pressed

const UI_STYLE = preload("res://game/scripts/ui/ui_style.gd")
const ART = preload("res://game/scripts/ui/hud_art.gd")
const RESOURCE_BAR = preload("res://game/scripts/ui/hud_resource_bar.gd")
const JOYSTICK = preload("res://game/scripts/ui/virtual_joystick.gd")
const COMBAT_RULES = preload("res://game/scripts/combat/combat_rules.gd")
const ATTRIBUTES_WINDOW = preload("res://game/scenes/ui/attributes_window.tscn")
const MOBILE_JOYSTICK_SCALE := 2.0
const MOBILE_JOYSTICK_BASE_SIZE := Vector2(144.0, 144.0)
const MOBILE_JOYSTICK_BASE_RADIUS := 64.0
const BAG_ITEM_IDS := [
	"wood", "stone", "fiber", "herb", "bandage", "meat", "hide", "fang", "crystal_shard",
	"sword_basic", "sword_reinforced", "axe_basic", "pickaxe_basic"
]
const ITEM_LABELS := {
	"wood": "Madeira", "stone": "Pedra", "fiber": "Fibra", "herb": "Erva",
	"bandage": "Curativo", "meat": "Carne", "hide": "Couro", "fang": "Presa",
	"crystal_shard": "Fragmento", "sword_basic": "Espada básica", "sword_reinforced": "Espada reforçada",
	"axe_basic": "Machado", "pickaxe_basic": "Picareta"
}

var _minimap: Control
var _joystick: Control
var _art_buttons: Array[Button] = []
var _nav_buttons: Array[Button] = []
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
var _inventory_panel: PanelContainer
var _inventory_scroll: ScrollContainer
var _camp_overlay: Control
var _attributes_window: Control
var _downed_panel: PanelContainer
var _downed_label: Label
var _bag_slots: Array[Button] = []
var _item_detail: Label
var _bag_summary: Label
var _bag_header: Label
var _gold_summary: Label
var _inventory_stats: Label
var _equipment_slots: Dictionary = {}
var _character_preview: TextureRect
var _inventory_preview_for_name := ""
var _use_bandage_button: Button
var _craft_bandage_button: Button
var _camp_summary: Label
var _camp_upgrade_button: Button
var _downed_shade: ColorRect
var _inventory_items: Dictionary = {}
var _safe_rect := Rect2(16.0, 16.0, 688.0, 1248.0)
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
	_build_attributes_window()
	get_viewport().size_changed.connect(_layout_safe_area)
	_layout_safe_area()


func _build_hud() -> void:
	_portrait = _framed_portrait("player_frame", Vector2(12, 12), Vector2(88, 102))
	_name_label = Label.new()
	_name_label.position = Vector2(106, 14)
	_name_label.size = Vector2(238, 24)
	UI_STYLE.style_label(_name_label, 18, UI_STYLE.CREAM)
	_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_name_label)
	_hp_bar = _make_bar("HP", Color("bd393e"))
	_place_bar(_hp_bar, Vector2(100, 38), Vector2(238, 28))
	_hp_text = _bar_caption(_hp_bar)
	_mp_bar = _make_bar("MP", Color("237dba"))
	_place_bar(_mp_bar, Vector2(100, 66), Vector2(238, 28))
	_mp_text = _bar_caption(_mp_bar)
	_xp_bar = _make_bar("EXP", Color("408442"))
	_place_bar(_xp_bar, Vector2(100, 94), Vector2(238, 28))
	_level_label = _bar_caption(_xp_bar)
	_target_portrait = _framed_portrait("enemy_frame", Vector2(-224, 178), Vector2(64, 72), Control.PRESET_TOP_RIGHT)
	_target_label = Label.new()
	_target_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_target_label.position = Vector2(-160, 182)
	_target_label.size = Vector2(148, 44)
	_target_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UI_STYLE.style_label(_target_label, 16, UI_STYLE.CREAM)
	_root.add_child(_target_label)
	_target_bar = _make_bar("Alvo", Color("bd393e"))
	_target_bar.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_place_bar(_target_bar, Vector2(-220, 248), Vector2(208, 28))
	_target_portrait.get_parent().hide()
	_target_label.hide()
	_target_bar.hide()
	_minimap = preload("res://game/scripts/ui/island_minimap.gd").new()
	_minimap.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_minimap.position = Vector2(-168, 12)
	_minimap.size = Vector2(156, 146)
	_root.add_child(_minimap)
	var attributes_button := _hud_button("ATR", Vector2(128, 130), Vector2(52, 52), _toggle_attributes)
	attributes_button.tooltip_text = "Atributos"
	attributes_button.text = ""
	attributes_button.icon = UI_STYLE.icon("INT")
	attributes_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	attributes_button.expand_icon = true
	attributes_button.add_theme_constant_override("icon_max_width", 32)
	for state in ["normal", "hover", "pressed", "disabled"]:
		attributes_button.add_theme_stylebox_override(state, UI_STYLE.classic_style("slot"))
	_nav_buttons = [
		_hud_button("Bolsa", Vector2(12, 130), Vector2(52, 52), _toggle_inventory),
		_hud_button("Base", Vector2(70, 130), Vector2(52, 52), _toggle_camp),
		attributes_button,
		_hud_button("Ⅱ", Vector2(186, 130), Vector2(52, 52), func() -> void: pause_pressed.emit()),
		_hud_button("−", Vector2(244, 130), Vector2(52, 52), func() -> void: zoom_requested.emit(-1)),
		_hud_button("+", Vector2(302, 130), Vector2(52, 52), func() -> void: zoom_requested.emit(1)),
	]
	_status = Label.new()
	_status.position = Vector2(16, 194)
	_status.size = Vector2(330, 64)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UI_STYLE.style_label(_status, 14, UI_STYLE.CREAM)
	_status.add_theme_color_override("font_outline_color", Color("11151b"))
	_status.add_theme_constant_override("outline_size", 4)
	_root.add_child(_status)
	var joystick = JOYSTICK.new()
	_joystick = joystick
	joystick.name = "VirtualJoystick"
	joystick.size = MOBILE_JOYSTICK_BASE_SIZE * MOBILE_JOYSTICK_SCALE
	joystick.radius = MOBILE_JOYSTICK_BASE_RADIUS * MOBILE_JOYSTICK_SCALE
	joystick.vector_changed.connect(func(value: Vector2) -> void: joystick_moved.emit(value))
	_root.add_child(joystick)
	_interact_button = _hud_button("Interagir", Vector2.ZERO, Vector2(224, 48), func() -> void: interact_pressed.emit())
	_bandage_button = _hud_button("Curativo", Vector2.ZERO, Vector2(64, 64), func() -> void: bandage_pressed.emit())
	# Kept as an internal compatibility control, never rendered.
	_auto_attack_button = _hud_button("Espada\nAuto ON", Vector2.ZERO, Vector2(64, 64), _toggle_auto_attack)
	_auto_attack_button.hide()
	var skills := [
		["war_combo", "Combo\n10 MP"],
		["war_circle", "Corte\n15 MP"],
		["war_quake", "Terremoto\n35 MP"]
	]
	for data in skills:
		var id := str(data[0])
		var button := _hud_button(str(data[1]), Vector2.ZERO, Vector2(72, 72), func() -> void: skill_pressed.emit(id))
		_apply_button_art(button, id)
		button.size = Vector2(72, 72)
		_skill_buttons[id] = button


func _bar_caption(bar: ProgressBar) -> Label:
	var label := Label.new()
	label.anchor_right = 1.0
	label.anchor_bottom = 1.0
	label.offset_left = 42
	label.offset_top = 2
	label.offset_right = -22
	label.offset_bottom = -2
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UI_STYLE.style_label(label, 16, UI_STYLE.CREAM)
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
	var mapping := {"Bolsa": "bag", "Base": "refuge", "Ⅱ": "pause", "−": "zoom_out", "+": "zoom_in", "Trocar alvo": "target", "Curativo": "bandage", "Espada\nAuto ON": "attack"}
	if mapping.has(text):
		_apply_button_art(button, str(mapping[text]))
	button.pressed.connect(action)
	_root.add_child(button)
	return button


func _make_bar(label_text: String, _fill_color: Color) -> ProgressBar:
	var bar = RESOURCE_BAR.new()
	bar.skin = {"HP": "hp", "MP": "mp", "EXP": "xp", "Alvo": "enemy_hp"}.get(label_text, "hp")
	bar.custom_minimum_size = Vector2(118, 28)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.max_value = 1
	bar.value = 1
	bar.show_percentage = false
	bar.tooltip_text = label_text
	return bar


func _place_bar(bar: ProgressBar, point: Vector2, dimensions: Vector2) -> void:
	bar.position = point
	bar.size = dimensions
	_root.add_child(bar)


func _framed_portrait(id: String, point: Vector2, dimensions: Vector2, preset := Control.PRESET_TOP_LEFT) -> TextureRect:
	var holder := Control.new()
	holder.set_anchors_preset(preset)
	holder.position = point
	holder.size = dimensions
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(holder)
	var portrait := TextureRect.new()
	portrait.position = dimensions * Vector2(0.16, 0.18)
	portrait.size = dimensions * Vector2(0.68, 0.64)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(portrait)
	var frame := TextureRect.new()
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	frame.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	frame.texture = ART.texture(id)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(frame)
	return portrait


func _apply_button_art(button: Button, id: String) -> void:
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	var icon := TextureRect.new()
	icon.name = "PixelArtwork"
	icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.texture = ART.texture(id)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(icon)
	button.set_meta("art_id", id)
	var caption := Label.new()
	caption.name = "LiveCaption"
	caption.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	caption.offset_top = -23
	caption.offset_bottom = -1
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UI_STYLE.style_label(caption, 17, UI_STYLE.CREAM)
	caption.add_theme_color_override("font_outline_color", Color("12151b"))
	caption.add_theme_constant_override("outline_size", 6)
	button.add_child(caption)
	_set_button_text(button, button.text)
	_art_buttons.append(button)


func _set_button_text(button: Button, value: String) -> void:
	button.tooltip_text = value.replace("\n", " · ")
	var caption := button.get_node_or_null("LiveCaption") as Label
	if caption == null:
		button.text = value
		return
	button.text = ""
	var lines := value.split("\n")
	caption.text = str(lines[-1]) if lines.size() > 1 else value
	if str(button.get_meta("art_id", "")) in ["pause", "zoom_in", "zoom_out"]:
		caption.text = ""


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
	_inventory_panel = PanelContainer.new()
	_inventory_panel.name = "InventoryPanel"
	_inventory_panel.custom_minimum_size = Vector2(680, 920)
	_inventory_panel.add_theme_stylebox_override("panel", UI_STYLE.classic_style())
	center.add_child(_inventory_panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 16)
	_inventory_panel.add_child(margin)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 10)
	margin.add_child(stack)
	var heading := HBoxContainer.new()
	var header_frame := PanelContainer.new()
	header_frame.add_theme_stylebox_override("panel", UI_STYLE.classic_style("button"))
	stack.add_child(header_frame)
	header_frame.add_child(heading)
	var title := Label.new()
	title.text = "INVENTÁRIO"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UI_STYLE.style_label(title, 25, UI_STYLE.CREAM)
	heading.add_child(title)
	var close := _close_button()
	close.pressed.connect(func() -> void: _inventory_overlay.hide())
	heading.add_child(close)
	_inventory_scroll = ScrollContainer.new()
	_inventory_scroll.name = "InventoryContentScroll"
	_inventory_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_inventory_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_inventory_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_inventory_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_inventory_scroll.clip_contents = true
	stack.add_child(_inventory_scroll)
	var columns := VBoxContainer.new()
	columns.name = "InventoryContent"
	columns.add_theme_constant_override("separation", 12)
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_inventory_scroll.add_child(columns)
	var panes := HBoxContainer.new()
	panes.name = "InventoryPanes"
	panes.add_theme_constant_override("separation", 10)
	columns.add_child(panes)
	var equipment_panel := _subpanel("EQUIPAMENTO", Vector2(0, 324))
	equipment_panel.name = "EquipmentPanel"
	panes.add_child(equipment_panel)
	var equipment_box := _subpanel_stack(equipment_panel)
	equipment_box.add_theme_constant_override("separation", 5)
	var equipment_row := VBoxContainer.new()
	equipment_row.name = "EquipmentRow"
	equipment_row.add_theme_constant_override("separation", 8)
	equipment_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	equipment_box.add_child(equipment_row)
	var equipment_board := Control.new()
	equipment_board.name = "EquipmentBoard"
	equipment_board.custom_minimum_size = Vector2(260, 420)
	equipment_board.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	equipment_row.add_child(equipment_board)
	_character_preview = TextureRect.new()
	_character_preview.name = "CharacterPreview"
	_character_preview.position = Vector2(50, 70)
	_character_preview.size = Vector2(160, 248)
	_character_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_character_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_character_preview.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_character_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	equipment_board.add_child(_character_preview)
	var character_caption := Label.new()
	character_caption.text = "PERSONAGEM"
	character_caption.position = Vector2(64, 322)
	character_caption.size = Vector2(124, 20)
	character_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	character_caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UI_STYLE.style_label(character_caption, 10, UI_STYLE.MUTED)
	equipment_board.add_child(character_caption)
	var equipment_layout := [
		{"id": "amulet", "label": "AMULETO", "short": "AM", "position": Vector2(208, 20)},
		{"id": "head", "label": "CABEÇA", "short": "ELM", "position": Vector2(104, 0)},
		{"id": "main_hand", "label": "ARMA · MÃO PRINCIPAL", "short": "ARM", "position": Vector2(0, 112)},
		{"id": "offhand", "label": "ARMA · MÃO SECUNDÁRIA", "short": "OFF", "position": Vector2(208, 112)},
		{"id": "jewel_left", "label": "ACESSÓRIO I", "short": "J1", "position": Vector2(0, 284)},
		{"id": "chest", "label": "PEITORAL", "short": "ARM", "position": Vector2(0, 200)},
		{"id": "jewel_right", "label": "ACESSÓRIO II", "short": "J2", "position": Vector2(208, 284)},
		{"id": "pants", "label": "CALÇAS", "short": "CAL", "position": Vector2(0, 368)},
		{"id": "boots", "label": "BOTAS", "short": "BOT", "position": Vector2(208, 368)}
	]
	for slot_data in equipment_layout:
		var slot := _make_equipment_slot(slot_data)
		equipment_board.add_child(slot)
		_equipment_slots[str(slot_data.id)] = slot
		var slot_name := Label.new()
		var names := {"head":"Cabeça", "amulet":"Amuleto", "main_hand":"Mão dir.", "offhand":"Mão esq.", "chest":"Peitoral", "jewel_left":"Joia I", "jewel_right":"Joia II", "pants":"Calças", "boots":"Botas"}
		slot_name.text = names.get(str(slot_data.id), "")
		slot_name.position = slot_data.position - Vector2(10, 17)
		slot_name.size = Vector2(68, 16)
		slot_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		UI_STYLE.style_label(slot_name, 12, UI_STYLE.MUTED)
		equipment_board.add_child(slot_name)
	var stats_panel := _subpanel("STATUS DO PERSONAGEM", Vector2(196, 0))
	stats_panel.name = "InventoryCharacterStatus"
	stats_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	equipment_row.add_child(stats_panel)
	_inventory_stats = Label.new()
	_inventory_stats.name = "InventoryStatusText"
	_inventory_stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_inventory_stats.size_flags_vertical = Control.SIZE_EXPAND_FILL
	UI_STYLE.style_label(_inventory_stats, 14, UI_STYLE.CREAM)
	_subpanel_stack(stats_panel).add_child(_inventory_stats)

	var bag_panel := _subpanel("MOCHILA · 0 / 24 PILHAS", Vector2(0, 310))
	bag_panel.name = "BagPanel"
	panes.add_child(bag_panel)
	var bag_box := _subpanel_stack(bag_panel)
	bag_box.add_theme_constant_override("separation", 8)
	_bag_header = bag_panel.find_children("*", "Label", true, false)[0] as Label
	_bag_header.name = "BagHeader"
	var bag_content := VBoxContainer.new()
	bag_content.name = "BagContent"
	bag_content.add_theme_constant_override("separation", 10)
	bag_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bag_box.add_child(bag_content)
	var bag_grid := GridContainer.new()
	bag_grid.name = "BagGrid"
	bag_grid.columns = 4
	bag_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bag_grid.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	bag_grid.add_theme_constant_override("h_separation", 5)
	bag_grid.add_theme_constant_override("v_separation", 5)
	bag_content.add_child(bag_grid)
	for index in range(24):
		var slot := Button.new()
		slot.name = "BagSlot%02d" % (index + 1)
		slot.text = ""
		slot.custom_minimum_size = Vector2(58, 58)
		slot.autowrap_mode = TextServer.AUTOWRAP_OFF
		UI_STYLE.style_button(slot)
		slot.add_theme_font_size_override("font_size", 10)
		slot.pressed.connect(func() -> void: _select_bag_slot(index))
		var art := UI_STYLE.picture(null, Vector2.ZERO)
		art.name = "ItemIcon"
		art.position = Vector2(9, 5)
		art.size = Vector2(40, 40)
		slot.add_child(art)
		var quantity := Label.new()
		quantity.name = "Quantity"
		quantity.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
		quantity.position = Vector2(-52, -22)
		quantity.size = Vector2(46, 18)
		quantity.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		quantity.mouse_filter = Control.MOUSE_FILTER_IGNORE
		UI_STYLE.style_label(quantity, 13, UI_STYLE.CREAM)
		quantity.add_theme_color_override("font_shadow_color", Color.BLACK)
		quantity.add_theme_constant_override("shadow_outline_size", 4)
		slot.add_child(quantity)
		bag_grid.add_child(slot)
		_bag_slots.append(slot)
	var detail_panel := _subpanel("ITEM SELECIONADO", Vector2(154, 0))
	detail_panel.name = "SelectedItemPanel"
	detail_panel.custom_minimum_size.x = 154
	detail_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bag_content.add_child(detail_panel)
	var detail_box := _subpanel_stack(detail_panel)
	detail_box.add_theme_constant_override("separation", 7)
	_item_detail = Label.new()
	_item_detail.name = "ItemDetails"
	_item_detail.text = "Selecione um item para ver a quantidade e a ação disponível."
	_item_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_item_detail.size_flags_vertical = Control.SIZE_EXPAND_FILL
	UI_STYLE.style_label(_item_detail, 14, UI_STYLE.CREAM)
	detail_box.add_child(_item_detail)
	_craft_bandage_button = Button.new()
	_craft_bandage_button.name = "CraftBandageButton"
	_craft_bandage_button.text = "Fabricar curativo\n3 ervas + 1 fibra"
	_craft_bandage_button.custom_minimum_size = Vector2(0, 48)
	UI_STYLE.style_button(_craft_bandage_button, true)
	_craft_bandage_button.add_theme_font_size_override("font_size", 12)
	_craft_bandage_button.pressed.connect(func() -> void: craft_bandage_pressed.emit())
	detail_box.add_child(_craft_bandage_button)
	_use_bandage_button = Button.new()
	_use_bandage_button.name = "UseBandageButton"
	_use_bandage_button.text = "Usar curativo"
	_use_bandage_button.custom_minimum_size = Vector2(0, 42)
	UI_STYLE.style_button(_use_bandage_button)
	_use_bandage_button.add_theme_font_size_override("font_size", 12)
	_use_bandage_button.pressed.connect(func() -> void: bandage_pressed.emit())
	detail_box.add_child(_use_bandage_button)
	var footer := HBoxContainer.new()
	footer.name = "InventoryFooter"
	footer.add_theme_constant_override("separation", 8)
	footer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.size_flags_vertical = Control.SIZE_SHRINK_END
	columns.add_child(footer)
	_gold_summary = Label.new()
	_gold_summary.name = "GoldUnavailableLabel"
	_gold_summary.text = "OURO  —  indisponível no MVP"
	_gold_summary.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_gold_summary.size_flags_vertical = Control.SIZE_SHRINK_END
	_gold_summary.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	UI_STYLE.style_label(_gold_summary, 12, UI_STYLE.GOLD)
	footer.add_child(_gold_summary)
	_bag_summary = Label.new()
	_bag_summary.name = "BagSummaryLabel"
	_bag_summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_bag_summary.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	_bag_summary.size_flags_vertical = Control.SIZE_SHRINK_END
	_bag_summary.autowrap_mode = TextServer.AUTOWRAP_OFF
	_bag_summary.custom_minimum_size.x = 180
	UI_STYLE.style_label(_bag_summary, 11, UI_STYLE.MUTED)
	footer.add_child(_bag_summary)
	_refresh_inventory()


func _make_equipment_slot(slot_data: Dictionary) -> PanelContainer:
	var slot := PanelContainer.new()
	slot.name = "EquipmentSlot_%s" % str(slot_data.id)
	slot.position = slot_data.position
	slot.custom_minimum_size = Vector2(48, 48)
	slot.size = Vector2(48, 48)
	slot.tooltip_text = "%s · equipamento não configurável no MVP" % str(slot_data.label)
	slot.mouse_filter = Control.MOUSE_FILTER_STOP
	slot.add_theme_stylebox_override("panel", UI_STYLE.classic_style("slot"))
	var caption := Label.new()
	caption.name = "SlotCaption"
	caption.text = ""
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UI_STYLE.style_label(caption, 9, UI_STYLE.GOLD)
	var icon := UI_STYLE.picture(UI_STYLE.icon(str(slot_data.id)), Vector2(32, 32))
	icon.name = "EquipmentIcon"
	icon.modulate = Color(0.7, 0.72, 0.65, 0.38) if str(slot_data.id) != "main_hand" else Color.WHITE
	slot.add_child(icon)
	slot.add_child(caption)
	return slot


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


func _build_attributes_window() -> void:
	_attributes_window = ATTRIBUTES_WINDOW.instantiate() as Control
	_attributes_window.name = "AttributesWindow"
	# Keep this modal in viewport coordinates; the normal HUD root is scaled to
	# its 720 px design grid for responsive controls.
	add_child(_attributes_window)
	_attributes_window.connect("attributes_committed", func(state: Object) -> void:
		attributes_committed.emit(state)
	)
	_attributes_window.connect("closed", _on_attributes_closed)


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
	panel.add_theme_stylebox_override("panel", UI_STYLE.classic_style("slot"))
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
	UI_STYLE.style_label(title, 14, UI_STYLE.GOLD)
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


func _toggle_attributes() -> void:
	attributes_pressed.emit()


func open_attributes_for_state(state: Object) -> bool:
	_inventory_overlay.hide()
	_camp_overlay.hide()
	_joystick.set_blocked(true)
	var opened := bool(_attributes_window.call("open_for_state", state))
	if not opened:
		_refresh_joystick_blocking()
	return opened


func _on_attributes_closed() -> void:
	_refresh_joystick_blocking()


func _refresh_joystick_blocking() -> void:
	_joystick.set_blocked(_inventory_overlay.visible or _camp_overlay.visible or _downed_shade.visible or _attributes_window.visible)


func _toggle_auto_attack() -> void:
	_auto_attack_enabled = not _auto_attack_enabled
	_set_button_text(_auto_attack_button, "Espada\nAuto %s" % ("ON" if _auto_attack_enabled else "OFF"))
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
	if _bag_header != null:
		_bag_header.text = "MOCHILA · %d / 24 PILHAS" % occupied
	for index in range(_bag_slots.size()):
		var button := _bag_slots[index]
		if index >= BAG_ITEM_IDS.size():
			button.text = ""
			button.disabled = true
			continue
		var item_id: String = str(BAG_ITEM_IDS[index])
		var count := int(_inventory_items.get(item_id, 0))
		button.text = ""
		(button.get_node("ItemIcon") as TextureRect).texture = UI_STYLE.icon(item_id) if count > 0 else null
		(button.get_node("Quantity") as Label).text = "×%d" % count if count > 0 else ""
		button.tooltip_text = str(ITEM_LABELS.get(item_id, item_id))
		button.disabled = count <= 0
	if _bag_summary != null:
		_bag_summary.text = "Bag: %d / 24 pilhas\nPeso: não definido" % occupied
	_refresh_inventory_character_status()
	_update_item_detail()
	if _craft_bandage_button != null:
		_craft_bandage_button.disabled = int(_inventory_items.get("herb", 0)) < 3 or int(_inventory_items.get("fiber", 0)) < 1
	if _use_bandage_button != null:
		_use_bandage_button.disabled = int(_inventory_items.get("bandage", 0)) <= 0
	if _bandage_button != null:
		_set_button_text(_bandage_button, "Curativo\n%d" % int(_inventory_items.get("bandage", 0)))
		_bandage_button.disabled = int(_inventory_items.get("bandage", 0)) <= 0


func _inventory_short_label(item_id: String) -> String:
	var labels := {
		"crystal_shard": "Cristal", "sword_reinforced": "Espada +", "pickaxe_basic": "Picareta"
	}
	return str(labels.get(item_id, ITEM_LABELS.get(item_id, item_id)))


func _refresh_inventory_character_status() -> void:
	if _inventory_stats == null:
		return
	var display_name := "Melissa"
	var character_title := "Melissa · Guerreiro"
	if _name_label != null and not _name_label.text.is_empty():
		character_title = _name_label.text
		display_name = _name_label.text.split("·")[0].strip_edges()
	if _character_preview != null and _inventory_preview_for_name != display_name:
		_inventory_preview_for_name = display_name
		_character_preview.texture = _load_inventory_character_preview(display_name)
	var weapon_data := COMBAT_RULES.weapon("sword_basic")
	var weapon_damage := float(weapon_data.get("damage", 0.0))
	var weapon_name := str(ITEM_LABELS.get("sword_basic", "Arma base"))
	var level_text := _level_label.text if _level_label != null else "Nv. 1"
	var hp_text := _hp_text.text if _hp_text != null else "HP —"
	var mp_text := _mp_text.text if _mp_text != null else "MP —"
	_inventory_stats.text = "%s\n%s\n%s\n%s\n\n%s\nDano da arma: %s" % [
		character_title,
		level_text,
		hp_text,
		mp_text,
		weapon_name,
		"%.0f" % weapon_damage if weapon_data.has("damage") else "—"
	]
	var weapon_slot := _equipment_slots.get("main_hand") as PanelContainer
	if weapon_slot != null:
		var slot_caption := weapon_slot.get_node_or_null("SlotCaption") as Label
		if slot_caption != null:
			var count := int(_inventory_items.get("sword_basic", 0))
			slot_caption.text = ""
		weapon_slot.tooltip_text = "Arma base de combate: %s (%s de dano no catálogo). Equipamentos não podem ser trocados no MVP." % [weapon_name, "%.0f" % weapon_damage]


func _load_inventory_character_preview(display_name: String) -> Texture2D:
	var appearances = preload("res://game/scripts/actors/appearance_data.gd")
	for profile in appearances.profiles():
		if str(profile.get("name", "")).to_lower() != display_name.to_lower():
			continue
		var metadata_path := str(profile.get("idle_metadata", ""))
		var metadata: Dictionary = appearances.metadata(metadata_path)
		var atlas_path := appearances.atlas_path(metadata_path, metadata)
		var atlas := load(atlas_path) as Texture2D
		if atlas == null:
			break
		var cell: Array = metadata.get("cell", [96, 96])
		var directions: Array = metadata.get("directions", ["S"])
		var south_row := directions.find("S")
		if south_row < 0:
			south_row = 0
		var frame := AtlasTexture.new()
		frame.atlas = atlas
		frame.region = Rect2(0, south_row * int(cell[1]), int(cell[0]), int(cell[1]))
		var used := frame.get_image().get_used_rect()
		frame.region = Rect2(frame.region.position + Vector2(used.position), Vector2(used.size))
		return frame
	return null


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
				frame.region = Rect2(int(cell[0]) * 0.28, maxi(0, directions.find("S")) * int(cell[1]) + int(cell[1]) * 0.16, int(cell[0]) * 0.38, int(cell[1]) * 0.40)
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
	_target_portrait.get_parent().visible = not selected_target.is_empty()
	_target_label.visible = not selected_target.is_empty()
	_target_bar.visible = not selected_target.is_empty()
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
		_set_button_text(_bandage_button, "Curando\n%d%%" % roundi(bandage_progress * 25.0))
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
		_set_button_text(_bandage_button, "Curativo\n%d" % int(_inventory_items.get("bandage", 0)))
		_bandage_button.disabled = int(_inventory_items.get("bandage", 0)) <= 0


func _update_skill_button(skill_id: String, label: String, current_mp: float, cooldowns: Dictionary) -> void:
	var button: Button = _skill_buttons.get(skill_id)
	if button == null:
		return
	var mana_cost := int(COMBAT_RULES.skill(skill_id).get("mp", 0))
	var remaining := float(cooldowns.get(skill_id, 0.0))
	var suffix := "%.0f s" % remaining if remaining > 0.0 else "%d MP" % mana_cost
	_set_button_text(button, "%s\n%s" % [label, suffix])
	button.disabled = current_mp < mana_cost or remaining > 0.0


func set_target_feedback(value: String) -> void:
	if _target_label != null:
		_target_label.text = value


func toggle_inventory_from_game() -> void:
	_toggle_inventory()


func _layout_safe_area() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	var factor := minf(viewport_size.x, viewport_size.y) / 720.0
	var safe_area := Rect2i(Vector2i.ZERO, Vector2i.ZERO)
	var screen_size := Vector2i.ZERO
	if OS.get_name() == "Android":
		safe_area = DisplayServer.get_display_safe_area()
		screen_size = DisplayServer.screen_get_size()
	_apply_safe_area_layout(viewport_size, factor, safe_area, screen_size)
	if _inventory_panel != null:
		var inventory_modal_scale := minf(1.0, _root.size.y / 1160.0)
		var inventory_global_scale := maxf(factor * inventory_modal_scale, 0.01)
		var available_panel_height := maxf(320.0, (viewport_size.y - 32.0) / inventory_global_scale)
		_inventory_panel.custom_minimum_size.y = minf(920.0, available_panel_height)
	for overlay in [_inventory_overlay, _camp_overlay, _downed_shade]:
		var modal_scale := minf(1.0, _root.size.y / 1160.0)
		overlay.set_anchors_preset(Control.PRESET_TOP_LEFT)
		overlay.scale = Vector2.ONE * modal_scale
		overlay.size = _root.size / modal_scale


func _apply_safe_area_layout(viewport_size: Vector2, factor: float, safe_area: Rect2i, screen_size: Vector2i) -> void:
	var scale_factor := maxf(factor, 0.01)
	_root.set_anchors_preset(Control.PRESET_TOP_LEFT, false)
	_root.position = Vector2.ZERO
	_root.scale = Vector2.ONE * scale_factor
	_root.size = viewport_size / scale_factor
	var viewport_rect := Rect2(Vector2.ZERO, viewport_size)
	var safe_viewport_rect := viewport_rect
	if screen_size.x > 0 and screen_size.y > 0 and safe_area.size.x > 0 and safe_area.size.y > 0:
		var ratio := viewport_size / Vector2(screen_size)
		var mapped_safe_rect := Rect2(Vector2(safe_area.position) * ratio, Vector2(safe_area.size) * ratio)
		mapped_safe_rect = mapped_safe_rect.intersection(viewport_rect)
		# Android can report the display dimensions in a different orientation
		# from the game's viewport. Reject that malformed mapping so touch controls
		# stay at the visible screen corners instead of an off-screen safe rect.
		var dimensions_are_plausible := mapped_safe_rect.size.x >= viewport_size.x * 0.80 and mapped_safe_rect.size.y >= viewport_size.y * 0.80
		if mapped_safe_rect.has_area() and dimensions_are_plausible:
			safe_viewport_rect = mapped_safe_rect
	_safe_rect = Rect2(safe_viewport_rect.position / scale_factor, safe_viewport_rect.size / scale_factor)
	_layout_edge_controls()


func _layout_edge_controls() -> void:
	# Keep the HUD root mapped to the complete portrait viewport. Safe-area insets
	# only move controls inward; they must never shrink or offset the gameplay canvas.
	const EDGE_GAP := 16.0
	const SKILL_SIZE := Vector2(72.0, 72.0)
	const SKILL_GAP := 12.0
	var joystick_size := MOBILE_JOYSTICK_BASE_SIZE * MOBILE_JOYSTICK_SCALE
	var safe_left := _safe_rect.position.x + EDGE_GAP
	var safe_top := _safe_rect.position.y + EDGE_GAP
	var safe_right := _safe_rect.end.x - EDGE_GAP
	var safe_bottom := _safe_rect.end.y - EDGE_GAP
	var skill_row_width := SKILL_SIZE.x * 3.0 + SKILL_GAP * 2.0
	var skill_row_x := safe_right - skill_row_width
	var skill_row_y := safe_bottom - SKILL_SIZE.y
	var joystick_position := Vector2(safe_left, safe_bottom - joystick_size.y)

	_set_control_rect(_joystick, joystick_position, joystick_size)
	_set_control_rect(_bandage_button, Vector2(minf(joystick_position.x + joystick_size.x + SKILL_GAP, safe_right - 64.0), safe_bottom - 64.0), Vector2(64.0, 64.0))
	_set_control_rect(_interact_button, Vector2(safe_right - 224.0, skill_row_y - 12.0 - 48.0), Vector2(224.0, 48.0))
	var skill_index := 0
	for skill_id in ["war_combo", "war_circle", "war_quake"]:
		var skill_button: Control = _skill_buttons[skill_id]
		_set_control_rect(skill_button, Vector2(skill_row_x + skill_index * (SKILL_SIZE.x + SKILL_GAP), skill_row_y), SKILL_SIZE)
		skill_index += 1

	_set_control_rect(_portrait.get_parent() as Control, Vector2(safe_left - EDGE_GAP + 12.0, safe_top - EDGE_GAP + 12.0), Vector2(88.0, 102.0))
	_set_control_rect(_name_label, Vector2(safe_left - EDGE_GAP + 106.0, safe_top - EDGE_GAP + 14.0), Vector2(238.0, 24.0))
	_set_control_rect(_hp_bar, Vector2(safe_left - EDGE_GAP + 100.0, safe_top - EDGE_GAP + 38.0), Vector2(238.0, 28.0))
	_set_control_rect(_mp_bar, Vector2(safe_left - EDGE_GAP + 100.0, safe_top - EDGE_GAP + 66.0), Vector2(238.0, 28.0))
	_set_control_rect(_xp_bar, Vector2(safe_left - EDGE_GAP + 100.0, safe_top - EDGE_GAP + 94.0), Vector2(238.0, 28.0))
	for index in _nav_buttons.size():
		_set_control_rect(_nav_buttons[index], Vector2(safe_left - EDGE_GAP + 12.0 + index * 58.0, safe_top - EDGE_GAP + 130.0), Vector2(52.0, 52.0))
	_set_control_rect(_status, Vector2(safe_left - EDGE_GAP + 16.0, safe_top - EDGE_GAP + 194.0), Vector2(330.0, 64.0))
	_set_control_rect(_minimap, Vector2(safe_right - 156.0, safe_top), Vector2(156.0, 146.0))
	_set_control_rect(_target_portrait.get_parent() as Control, Vector2(safe_right - 224.0, safe_top + 166.0), Vector2(64.0, 72.0))
	_set_control_rect(_target_label, Vector2(safe_right - 160.0, safe_top + 170.0), Vector2(148.0, 44.0))
	_set_control_rect(_target_bar, Vector2(safe_right - 220.0, safe_top + 236.0), Vector2(208.0, 28.0))


func _set_control_rect(control: Control, point: Vector2, dimensions: Vector2) -> void:
	if control == null:
		return
	control.anchor_left = 0.0
	control.anchor_top = 0.0
	control.anchor_right = 0.0
	control.anchor_bottom = 0.0
	control.offset_left = point.x
	control.offset_top = point.y
	control.offset_right = point.x + dimensions.x
	control.offset_bottom = point.y + dimensions.y


func _process(_delta: float) -> void:
	for button in _art_buttons:
		var icon := button.get_node("PixelArtwork") as TextureRect
		icon.modulate = Color(0.42, 0.42, 0.42, 0.85) if button.disabled else (Color(0.75, 0.75, 0.75) if button.is_pressed() else Color.WHITE)
	_joystick.set_blocked(_inventory_overlay.visible or _camp_overlay.visible or _downed_shade.visible or _attributes_window.visible)


func release_movement() -> void:
	_joystick.set_blocked(true)
