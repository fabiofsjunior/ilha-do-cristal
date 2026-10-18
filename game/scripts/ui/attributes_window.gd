extends Control
## Modal state-backed allocation window with catalog-derived character details.

signal attributes_committed(state: Object)
signal closed

const COMBAT_RULES = preload("res://game/scripts/combat/combat_rules.gd")
const UI_STYLE = preload("res://game/scripts/ui/ui_style.gd")
const ATTRIBUTE_IDS := ["FOR", "AGI", "INT"]
const ATTRIBUTE_COPY := {
	"FOR": {"title": "FORÇA", "base_key": "str", "description": "Força física, vida máxima, dano corpo a corpo e regeneração de HP."},
	"AGI": {"title": "AGILIDADE", "base_key": "agi", "description": "Dano à distância, chance crítica e esquiva."},
	"INT": {"title": "INTELIGÊNCIA", "base_key": "int", "description": "Dano mágico, mana máxima e regeneração de MP."}
}
const VOCATION_LABELS := {"warrior": "Guerreiro", "archer": "Arqueiro", "mage": "Mago"}
const CHARACTER_LABELS := {
	"melissa": "Melissa", "helena": "Helena", "maira": "Maíra", "fabio": "Fábio"
}
const ATTRIBUTE_EFFECTS_PATH := ["ui_and_audio", "inventory_prototype_v0_7", "attribute_derived_effects"]

var _profile_preview: TextureRect
var _state: Object
var _pending := {"FOR": 0, "AGI": 0, "INT": 0}
var _tree_was_paused := false
var _modal_open := false
var _main_frame: PanelContainer
var _points_label: Label
var _identity_label: Label
var _xp_label: Label
var _resource_label: Label
var _regen_label: Label
var _status_label: Label
var _value_labels: Dictionary = {}
var _effective_labels: Dictionary = {}
var _benefit_labels: Dictionary = {}
var _add_buttons: Dictionary = {}
var _derived_labels: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	_build_interface()
	visible = false
	resized.connect(_update_frame_size)
	call_deferred("_update_frame_size")


## Call after adding this scene to the tree. The modal pauses gameplay while open.
func open_for_state(state: Object) -> bool:
	if state == null or not state.has_method("is_ready") or not bool(state.call("is_ready")):
		push_error("Janela de atributos requer um ExpeditionState carregado.")
		return false
	if not state.has_method("max_hp_mp"):
		push_error("O estado fornecido não expõe os dados de combate esperados.")
		return false
	if not _read_state_dictionary(state, "raw_attributes").has_all(ATTRIBUTE_IDS):
		push_error("O estado fornecido não contém FOR, AGI e INT.")
		return false
	if not VOCATION_LABELS.has(str(state.get("vocation_id"))):
		push_error("Vocação ausente no catálogo: %s" % str(state.get("vocation_id")))
		return false

	_state = state
	_pending = {"FOR": 0, "AGI": 0, "INT": 0}
	_tree_was_paused = get_tree().paused
	_modal_open = true
	visible = true
	if not multiplayer.multiplayer_peer is ENetMultiplayerPeer:
		get_tree().paused = true
	_refresh()
	return true


## Stage one point without modifying the live state until Confirmar is pressed.
func allocate_point(attribute_id: String) -> bool:
	if not _modal_open or not ATTRIBUTE_IDS.has(attribute_id):
		return false
	var available := int(_state.get("available_attribute_points"))
	if _spent_points() >= available:
		return false
	_pending[attribute_id] = int(_pending.get(attribute_id, 0)) + 1
	_refresh()
	return true


## Apply temporary allocation and notify the world/HUD so it can save and refresh.
func confirm_changes() -> bool:
	if not _modal_open or _state == null:
		return false
	var spent := _spent_points()
	if spent <= 0:
		_status_label.text = "Distribua ao menos 1 ponto antes de confirmar."
		return false
	var raw := _read_state_dictionary(_state, "raw_attributes")
	var available := int(_state.get("available_attribute_points"))
	if spent > available:
		_status_label.text = "Pontos disponíveis alterados; revise a distribuição."
		_refresh()
		return false
	for attribute_id in ATTRIBUTE_IDS:
		raw[attribute_id] = int(raw.get(attribute_id, 0)) + int(_pending.get(attribute_id, 0))
	_state.set("raw_attributes", raw)
	_state.set("available_attribute_points", available - spent)
	_pending = {"FOR": 0, "AGI": 0, "INT": 0}
	_refresh()
	_status_label.text = "Atributos aplicados. O jogo pode salvar o estado."
	attributes_committed.emit(_state)
	return true


## Discard only the unconfirmed allocation; already confirmed values remain intact.
func reset_allocation() -> void:
	_pending = {"FOR": 0, "AGI": 0, "INT": 0}
	_refresh()
	_status_label.text = "Distribuição temporária descartada."


func close_window() -> void:
	if not _modal_open:
		visible = false
		return
	reset_allocation()
	visible = false
	_modal_open = false
	_state = null
	if get_tree() != null:
		get_tree().paused = _tree_was_paused
	closed.emit()


func _build_interface() -> void:
	var dimmer := ColorRect.new()
	dimmer.name = "BackgroundDimmer"
	dimmer.color = Color(0.035, 0.045, 0.065, 0.84)
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dimmer)

	var center := CenterContainer.new()
	center.name = "ModalCenter"
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(center)

	_main_frame = PanelContainer.new()
	_main_frame.name = "MainFrame"
	_main_frame.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_main_frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_main_frame.add_theme_stylebox_override("panel", UI_STYLE.classic_style())
	center.add_child(_main_frame)

	var body := VBoxContainer.new()
	body.name = "WindowBody"
	body.add_theme_constant_override("separation", 8)
	_main_frame.add_child(body)

	var header := HBoxContainer.new()
	header.name = "Header"
	header.alignment = BoxContainer.ALIGNMENT_CENTER
	var header_frame := PanelContainer.new()
	header_frame.add_theme_stylebox_override("panel", UI_STYLE.classic_style("button"))
	body.add_child(header_frame)
	header_frame.add_child(header)
	var title := _label("ATRIBUTOS", 23, UI_STYLE.GOLD)
	title.name = "Title"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	var close_button := Button.new()
	close_button.name = "CloseButton"
	close_button.text = "X"
	close_button.custom_minimum_size = Vector2(44, 44)
	UI_STYLE.style_button(close_button)
	close_button.pressed.connect(close_window)
	header.add_child(close_button)

	var columns := HBoxContainer.new()
	columns.name = "AttributesColumns"
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation", 10)
	body.add_child(columns)
	var identity_panel := PanelContainer.new()
	identity_panel.name = "CharacterSummary"
	identity_panel.add_theme_stylebox_override("panel", UI_STYLE.classic_style("slot"))
	identity_panel.custom_minimum_size.x = 218
	columns.add_child(identity_panel)
	var identity_box := VBoxContainer.new()
	identity_box.add_theme_constant_override("separation", 2)
	identity_panel.add_child(identity_box)
	_identity_label = _label("", 16, UI_STYLE.CREAM)
	_identity_label.name = "CharacterIdentity"
	_identity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_identity_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	identity_box.add_child(_identity_label)
	_profile_preview = UI_STYLE.picture(null, Vector2(190, 330))
	_profile_preview.name = "AttributeCharacterPreview"
	identity_box.add_child(_profile_preview)
	_xp_label = _label("", 13, UI_STYLE.MUTED)
	_xp_label.name = "ExperienceProgress"
	_xp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	identity_box.add_child(_xp_label)
	_points_label = _label("", 16, UI_STYLE.GOLD)
	_points_label.name = "AvailablePoints"
	_points_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_child(_points_label)

	var scroll := ScrollContainer.new()
	scroll.name = "AttributesScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.mouse_filter = Control.MOUSE_FILTER_PASS
	scroll.custom_minimum_size.x = 360
	columns.add_child(scroll)
	var content := VBoxContainer.new()
	content.name = "AttributesContent"
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 8)
	scroll.add_child(content)

	content.add_child(_section_heading("ATRIBUTOS BÁSICOS", "Valores brutos e efetivos pela vocação."))
	for attribute_id in ATTRIBUTE_IDS:
		content.add_child(_make_attribute_row(attribute_id))

	var resources_panel := _make_section_panel("RECURSOS DO PERSONAGEM", Color("18242b"), Color("547782"))
	identity_box.add_child(resources_panel)
	_resource_label = _label("", 12, UI_STYLE.CREAM)
	_resource_label.name = "ResourceSummary"
	_resource_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	resources_panel.get_node("SectionContent").add_child(_resource_label)

	var derived_panel := _make_section_panel("COMBATE E DEFESA", Color("252331"), Color("76634b"))
	content.add_child(derived_panel)
	var derived_box: VBoxContainer = derived_panel.get_node("SectionContent")
	_add_derived_row(derived_box, "Ataque melee · espada básica", "melee")
	_add_derived_row(derived_box, "Ataque à distância · arco básico", "ranged")
	_add_derived_row(derived_box, "Ataque mágico · atributo INT", "magic")
	_add_derived_row(derived_box, "Chance crítica · catálogo", "crit")
	_add_derived_row(derived_box, "Esquiva · catálogo", "dodge")

	var regen_panel := _make_section_panel("REGENERAÇÃO", Color("20282a"), Color("547782"))
	content.add_child(regen_panel)
	_regen_label = _label("", 13, UI_STYLE.CREAM)
	_regen_label.name = "RegenerationDetails"
	_regen_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	regen_panel.get_node("SectionContent").add_child(_regen_label)

	var note := _label("Os valores de dano e conversão são provisórios de playtest. As projeções usam o catálogo atual.", 11, UI_STYLE.MUTED)
	note.name = "CatalogNote"
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(note)

	_status_label = _label("", 12, UI_STYLE.MUTED)
	_status_label.name = "Status"
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(_status_label)

	var actions := HBoxContainer.new()
	actions.name = "Actions"
	actions.add_theme_constant_override("separation", 8)
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	body.add_child(actions)
	var reset_button := Button.new()
	reset_button.name = "ResetButton"
	reset_button.text = "Resetar"
	reset_button.custom_minimum_size = Vector2(124, 46)
	UI_STYLE.style_button(reset_button)
	reset_button.pressed.connect(reset_allocation)
	actions.add_child(reset_button)
	var confirm_button := Button.new()
	confirm_button.name = "ConfirmButton"
	confirm_button.text = "Confirmar"
	confirm_button.custom_minimum_size = Vector2(148, 46)
	UI_STYLE.style_button(confirm_button, true)
	confirm_button.pressed.connect(confirm_changes)
	actions.add_child(confirm_button)


func _make_attribute_row(attribute_id: String) -> Control:
	var card := PanelContainer.new()
	card.name = "%sRow" % attribute_id.capitalize()
	card.add_theme_stylebox_override("panel", UI_STYLE.classic_style("parchment"))
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 3)
	card.add_child(stack)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	stack.add_child(row)
	var text_stack := VBoxContainer.new()
	text_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_stack.add_theme_constant_override("separation", 1)
	row.add_child(UI_STYLE.picture(UI_STYLE.icon(attribute_id), Vector2(40, 40)))
	row.add_child(text_stack)
	var title := _label(str(ATTRIBUTE_COPY[attribute_id].title), 15, Color("493e2b"))
	title.name = "%sTitle" % attribute_id.capitalize()
	text_stack.add_child(title)
	var value := _label("Bruto 0", 13, Color("29332e"))
	value.name = "%sValue" % attribute_id.capitalize()
	_value_labels[attribute_id] = value
	text_stack.add_child(value)
	var effective := _label("Efetivo 0", 12, Color("315d65"))
	effective.name = "%sEffective" % attribute_id.capitalize()
	_effective_labels[attribute_id] = effective
	text_stack.add_child(effective)
	var add_button := Button.new()
	add_button.name = "AddPoint"
	add_button.text = "+"
	add_button.custom_minimum_size = Vector2(50, 48)
	add_button.focus_mode = Control.FOCUS_ALL
	UI_STYLE.style_button(add_button, true)
	add_button.pressed.connect(func() -> void: allocate_point(attribute_id))
	_add_buttons[attribute_id] = add_button
	row.add_child(add_button)
	var description := _label(str(ATTRIBUTE_COPY[attribute_id].description), 11, Color("574b36"))
	description.name = "%sDescription" % attribute_id.capitalize()
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stack.add_child(description)
	var benefit := _label("", 12, Color("29332e"))
	benefit.name = "%sNextPointBenefit" % attribute_id.capitalize()
	benefit.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_benefit_labels[attribute_id] = benefit
	stack.add_child(benefit)
	return card


func _make_section_panel(title: String, background: Color, border: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UI_STYLE.classic_style("slot"))
	var section := VBoxContainer.new()
	section.name = "SectionContent"
	section.add_theme_constant_override("separation", 3)
	panel.add_child(section)
	section.add_child(_label(title, 13, UI_STYLE.GOLD))
	return panel


func _section_heading(title: String, subtitle: String) -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 0)
	box.add_child(_label(title, 14, UI_STYLE.GOLD))
	var sub := _label(subtitle, 11, UI_STYLE.MUTED)
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(sub)
	return box


func _add_derived_row(parent: VBoxContainer, title: String, key: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	parent.add_child(row)
	var label := _label(title, 12, UI_STYLE.MUTED)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row.add_child(label)
	var value := _label("—", 13, UI_STYLE.CREAM)
	value.name = "%sValue" % key.capitalize()
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value.custom_minimum_size.x = 88
	_derived_labels[key] = value
	row.add_child(value)


func _refresh() -> void:
	if _state == null:
		return
	var character_id := str(_state.get("character_id"))
	var vocation_id := str(_state.get("vocation_id"))
	var character_name := str(CHARACTER_LABELS.get(character_id, character_id.capitalize()))
	var level := int(_state.get("level"))
	_identity_label.text = "%s\n%s · Nv. %d" % [character_name, VOCATION_LABELS.get(vocation_id, vocation_id), level]
	_profile_preview.texture = _portrait_texture(character_id)
	_xp_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_xp_label.text = _experience_summary(level, int(_state.get("total_xp")))
	var available := int(_state.get("available_attribute_points"))
	var spent := _spent_points()
	_points_label.text = "Pontos disponíveis: %d    ·    Pendentes: %d" % [maxi(0, available - spent), spent]

	var raw := _read_state_dictionary(_state, "raw_attributes")
	var preview_raw := raw.duplicate(true)
	for attribute_id in ATTRIBUTE_IDS:
		preview_raw[attribute_id] = int(raw.get(attribute_id, 0)) + int(_pending.get(attribute_id, 0))
	for attribute_id in ATTRIBUTE_IDS:
		var current := int(raw.get(attribute_id, 0))
		var pending := int(_pending.get(attribute_id, 0))
		var effective := COMBAT_RULES.effective_attributes(raw, vocation_id)
		var preview_effective := COMBAT_RULES.effective_attributes(preview_raw, vocation_id)
		_value_labels[attribute_id].text = "Bruto %d%s" % [current, "  (+%d)" % pending if pending > 0 else ""]
		_effective_labels[attribute_id].text = "Efetivo %s%s" % [
			_format_number(float(effective.get(attribute_id, 0.0))),
			"  →  %s" % _format_number(float(preview_effective.get(attribute_id, 0.0))) if pending > 0 else ""
		]
		_benefit_labels[attribute_id].text = _next_point_benefit(attribute_id, vocation_id, preview_raw)
		_add_buttons[attribute_id].disabled = spent >= available
		_add_buttons[attribute_id].tooltip_text = _next_point_benefit(attribute_id, vocation_id, preview_raw)

	var current_max := COMBAT_RULES.max_hp_mp(raw, vocation_id)
	var preview_max := COMBAT_RULES.max_hp_mp(preview_raw, vocation_id)
	var hp_current := float(_state.get("hp"))
	var mp_current := float(_state.get("mp"))
	_resource_label.text = "HP atual: %s / %s  ·  Máx. projetado: %s\nMP atual: %s / %s  ·  Máx. projetado: %s" % [
		_format_number(hp_current), _format_number(current_max.x), _format_number(preview_max.x),
		_format_number(mp_current), _format_number(current_max.y), _format_number(preview_max.y)
	]
	_refresh_derived(raw, preview_raw, vocation_id)
	_regen_label.text = _regeneration_summary(raw, preview_raw, vocation_id)
	if available <= 0:
		_status_label.text = "Você não tem pontos de atributo disponíveis."
	elif spent >= available:
		_status_label.text = "Todos os pontos disponíveis foram distribuídos."
	else:
		_status_label.text = "As mudanças só entram em vigor após Confirmar."


func _refresh_derived(raw: Dictionary, preview_raw: Dictionary, vocation_id: String) -> void:
	var current_melee := COMBAT_RULES.physical_attack(raw, vocation_id, "sword_basic")
	var preview_melee := COMBAT_RULES.physical_attack(preview_raw, vocation_id, "sword_basic")
	var effects := _attribute_effects()
	var agi_per_point := float(effects.get("AGI", {}).get("ranged_damage_per_effective_point", 0.6))
	var current_effective := COMBAT_RULES.effective_attributes(raw, vocation_id)
	var preview_effective := COMBAT_RULES.effective_attributes(preview_raw, vocation_id)
	var bow_base := float(COMBAT_RULES.weapon("bow_basic").get("damage", 0.0))
	var current_ranged := bow_base + float(current_effective.get("AGI", 0.0)) * agi_per_point
	var preview_ranged := bow_base + float(preview_effective.get("AGI", 0.0)) * agi_per_point
	var current_magic := COMBAT_RULES.magic_attack(raw, vocation_id)
	var preview_magic := COMBAT_RULES.magic_attack(preview_raw, vocation_id)
	var progression: Dictionary = COMBAT_RULES.catalog().get("attributes_and_levels", {})
	var crit_cap := float(progression.get("crit_cap_percent", 20.0))
	var dodge_cap := float(progression.get("dodge_cap_percent", 20.0))
	var crit_per_point := float(effects.get("AGI", {}).get("critical_chance_percentage_points_per_effective_point", 0.05))
	var dodge_per_point := float(effects.get("AGI", {}).get("dodge_percentage_points_per_effective_point", 0.05))
	var crit := minf(crit_cap, 5.0 + float(current_effective.get("AGI", 0.0)) * crit_per_point)
	var preview_crit := minf(crit_cap, 5.0 + float(preview_effective.get("AGI", 0.0)) * crit_per_point)
	var dodge := minf(dodge_cap, 3.0 + float(current_effective.get("AGI", 0.0)) * dodge_per_point)
	var preview_dodge := minf(dodge_cap, 3.0 + float(preview_effective.get("AGI", 0.0)) * dodge_per_point)
	_derived_labels["melee"].text = _number_transition(current_melee, preview_melee)
	_derived_labels["ranged"].text = _number_transition(current_ranged, preview_ranged)
	_derived_labels["magic"].text = _number_transition(current_magic, preview_magic)
	_derived_labels["crit"].text = _percent_transition(crit, preview_crit)
	_derived_labels["dodge"].text = _percent_transition(dodge, preview_dodge)


func _next_point_benefit(attribute_id: String, vocation_id: String, raw: Dictionary) -> String:
	var multiplier := _vocation_multiplier(attribute_id, vocation_id)
	var effects := _attribute_effects()
	var after_point := raw.duplicate(true)
	after_point[attribute_id] = int(after_point.get(attribute_id, 0)) + 1
	match attribute_id:
		"FOR":
			var hp_gain := multiplier * float(effects.get("FOR", {}).get("max_hp_per_effective_point", 3.0))
			var attack_gain := multiplier * float(effects.get("FOR", {}).get("melee_damage_per_effective_point", 0.6))
			var before_rates := COMBAT_RULES.regeneration_rates_percent_per_sec(raw, vocation_id, 0.0)
			var after_combat_rates := COMBAT_RULES.regeneration_rates_percent_per_sec(after_point, vocation_id, 0.0)
			var after_rest_rates := COMBAT_RULES.regeneration_rates_percent_per_sec(after_point, vocation_id, COMBAT_RULES.regeneration_out_of_combat_delay_sec())
			var before_rest_rates := COMBAT_RULES.regeneration_rates_percent_per_sec(raw, vocation_id, COMBAT_RULES.regeneration_out_of_combat_delay_sec())
			return "Próximo ponto: +%s HP máximo, +%s de dano melee; regen HP +%s p.p./s em combate e +%s p.p./s fora." % [
				_format_number(hp_gain), _format_number(attack_gain),
				_format_rate(float(after_combat_rates.hp) - float(before_rates.hp)),
				_format_rate(float(after_rest_rates.hp) - float(before_rest_rates.hp))
			]
		"AGI":
			var range_gain := multiplier * float(effects.get("AGI", {}).get("ranged_damage_per_effective_point", 0.6))
			var crit_gain := multiplier * float(effects.get("AGI", {}).get("critical_chance_percentage_points_per_effective_point", 0.05))
			var dodge_gain := multiplier * float(effects.get("AGI", {}).get("dodge_percentage_points_per_effective_point", 0.05))
			return "Próximo ponto: +%s dano à distância, +%s p.p. crítico e +%s p.p. esquiva (antes dos tetos)." % [_format_number(range_gain), _format_number(crit_gain), _format_number(dodge_gain)]
		"INT":
			var mp_gain := multiplier * float(effects.get("INT", {}).get("max_mp_per_effective_point", 3.0))
			var attack_gain := multiplier * float(effects.get("INT", {}).get("magic_damage_per_effective_point", 0.6))
			var before_rates := COMBAT_RULES.regeneration_rates_percent_per_sec(raw, vocation_id, 0.0)
			var after_combat_rates := COMBAT_RULES.regeneration_rates_percent_per_sec(after_point, vocation_id, 0.0)
			var before_rest_rates := COMBAT_RULES.regeneration_rates_percent_per_sec(raw, vocation_id, COMBAT_RULES.regeneration_out_of_combat_delay_sec())
			var after_rest_rates := COMBAT_RULES.regeneration_rates_percent_per_sec(after_point, vocation_id, COMBAT_RULES.regeneration_out_of_combat_delay_sec())
			return "Próximo ponto: +%s MP máximo, +%s de ataque mágico; regen MP +%s p.p./s em combate e +%s p.p./s fora." % [
				_format_number(mp_gain), _format_number(attack_gain),
				_format_rate(float(after_combat_rates.mp) - float(before_rates.mp)),
				_format_rate(float(after_rest_rates.mp) - float(before_rest_rates.mp))
			]
	return "Benefício indisponível no catálogo."


func _regeneration_summary(raw: Dictionary, preview_raw: Dictionary, vocation_id: String) -> String:
	var delay := COMBAT_RULES.regeneration_out_of_combat_delay_sec()
	var progression: Dictionary = COMBAT_RULES.catalog().get("attributes_and_levels", {})
	var current_combat := COMBAT_RULES.regeneration_rates_percent_per_sec(raw, vocation_id, 0.0)
	var preview_combat := COMBAT_RULES.regeneration_rates_percent_per_sec(preview_raw, vocation_id, 0.0)
	var current_rest := COMBAT_RULES.regeneration_rates_percent_per_sec(raw, vocation_id, delay)
	var preview_rest := COMBAT_RULES.regeneration_rates_percent_per_sec(preview_raw, vocation_id, delay)
	var hp_line := "HP máximo/s · combate: %s%% → %s%%; fora: %s%% → %s%% após %ss sem atacar/receber dano." % [
		_format_rate(float(current_combat.hp)), _format_rate(float(preview_combat.hp)),
		_format_rate(float(current_rest.hp)), _format_rate(float(preview_rest.hp)), _format_number(delay)
	]
	var mp_line := "MP máximo/s · combate: %s%% → %s%%; fora: %s%% → %s%%." % [
		_format_rate(float(current_combat.mp)), _format_rate(float(preview_combat.mp)),
		_format_rate(float(current_rest.mp)), _format_rate(float(preview_rest.mp))
	]
	var caps_line := "Tetos HP: %s%%/s em combate, %s%%/s fora · MP: %s%%/s em combate, %s%%/s fora." % [
		_format_rate(float(progression.get("hp_regen_cap_inside_combat_percent_per_sec", 0.5))),
		_format_rate(float(progression.get("hp_regen_cap_outside_combat_percent_per_sec", 2.0))),
		_format_rate(float(progression.get("mp_regen_cap_inside_combat_percent_per_sec", 0.25))),
		_format_rate(float(progression.get("mp_regen_cap_outside_combat_percent_per_sec", 1.0)))
	]
	return "%s\n%s\n%s" % [hp_line, mp_line, caps_line]


func _experience_summary(level: int, total_xp: int) -> String:
	var current_level_start := 0
	for previous_level in range(1, level):
		current_level_start += COMBAT_RULES.xp_to_next_level(previous_level)
	var needed := COMBAT_RULES.xp_to_next_level(level)
	if needed <= 0:
		return "XP total: %s  ·  Nível máximo do MVP" % _format_number(float(total_xp))
	var progress := clampi(total_xp - current_level_start, 0, needed)
	return "XP: %s / %s neste nível  ·  Total %s" % [_format_number(float(progress)), _format_number(float(needed)), _format_number(float(total_xp))]


func _vocation_multiplier(attribute_id: String, vocation_id: String) -> float:
	var vocation_data := COMBAT_RULES.vocation(vocation_id)
	var multipliers: Dictionary = vocation_data.get("stat_multiplier", {})
	var key := str(ATTRIBUTE_COPY[attribute_id].base_key)
	return float(multipliers.get(key, 1.0))


func _attribute_effects() -> Dictionary:
	var cursor: Dictionary = COMBAT_RULES.catalog()
	for key in ATTRIBUTE_EFFECTS_PATH:
		var next = cursor.get(str(key), {})
		if not next is Dictionary:
			return {}
		cursor = next
	return cursor


func _spent_points() -> int:
	var total := 0
	for attribute_id in ATTRIBUTE_IDS:
		total += int(_pending.get(attribute_id, 0))
	return total


func _read_state_dictionary(state: Object, property: String) -> Dictionary:
	var value = state.get(property)
	return value.duplicate(true) if value is Dictionary else {}


func _number_transition(current: float, preview: float) -> String:
	var result := _format_number(current)
	if not is_equal_approx(current, preview):
		result += " → %s" % _format_number(preview)
	return result


func _percent_transition(current: float, preview: float) -> String:
	var result := "%s%%" % _format_number(current)
	if not is_equal_approx(current, preview):
		result += " → %s%%" % _format_number(preview)
	return result


func _format_number(value: float) -> String:
	if is_equal_approx(value, round(value)):
		return str(int(round(value)))
	var formatted := "%.2f" % value
	if formatted.ends_with("0"):
		formatted = formatted.trim_suffix("0")
	if formatted.ends_with("."):
		formatted = formatted.trim_suffix(".")
	return formatted


func _format_rate(value: float) -> String:
	var formatted := "%.3f" % value
	while formatted.ends_with("0"):
		formatted = formatted.trim_suffix("0")
	if formatted.ends_with("."):
		formatted = formatted.trim_suffix(".")
	return formatted.replace(".", ",")


func _label(text: String, font_size: int, color: Color) -> Label:
	var result := Label.new()
	result.text = text
	result.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	UI_STYLE.style_label(result, font_size, color)
	return result


func _update_frame_size() -> void:
	if _main_frame == null:
		return
	var viewport_size := get_viewport_rect().size
	var width := minf(660.0, maxf(280.0, viewport_size.x - 24.0))
	var height := minf(1000.0, maxf(380.0, viewport_size.y - 28.0))
	_main_frame.custom_minimum_size = Vector2(width, height)


func _portrait_texture(character_id: String) -> Texture2D:
	var appearances = preload("res://game/scripts/actors/appearance_data.gd")
	for profile in appearances.profiles():
		if str(profile.get("id", "")) != character_id:
			continue
		var path := str(profile.get("idle_metadata", ""))
		var metadata: Dictionary = appearances.metadata(path)
		var atlas := load(appearances.atlas_path(path, metadata)) as Texture2D
		var cell: Array = metadata.get("cell", [96, 96])
		var directions: Array = metadata.get("directions", ["S"])
		var frame := AtlasTexture.new()
		frame.atlas = atlas
		frame.region = Rect2(0, maxi(0, directions.find("S")) * int(cell[1]), int(cell[0]), int(cell[1]))
		var used := frame.get_image().get_used_rect()
		frame.region = Rect2(frame.region.position + Vector2(used.position), Vector2(used.size))
		return frame
	return null
