extends PanelContainer
## Catalog browser. Passive purchases remain locked until a real talent state exists.
signal closed
const STYLE = preload("res://game/scripts/ui/ui_style.gd")
const RULES = preload("res://game/scripts/combat/combat_rules.gd")
const NAMES := {"war_combo": "Combo", "war_circle": "Corte circular", "war_quake": "Terremoto", "arc_precise": "Disparo preciso", "arc_bounce": "Ricochete", "arc_pierce": "Flecha perfurante", "mag_bolt": "Projétil arcano", "mag_fire": "Bola de fogo", "mag_ice": "Explosão de gelo"}
var _skills: VBoxContainer
var _note: Label
var _tabs: Array[Button] = []

func _ready() -> void:
	custom_minimum_size = Vector2(620, 650)
	add_theme_stylebox_override("panel", STYLE.KIT.style("panel", 28.0))
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 18)
	add_child(column)
	var heading := HBoxContainer.new()
	column.add_child(heading)
	var title := Label.new()
	title.text = "TALENTOS · VOCAÇÕES"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	STYLE.style_label(title, 24, STYLE.GOLD)
	heading.add_child(title)
	var close := Button.new()
	close.text = "×"
	close.custom_minimum_size = Vector2(48, 48)
	STYLE.style_button(close)
	close.pressed.connect(func() -> void: closed.emit())
	heading.add_child(close)
	var tabs := HBoxContainer.new()
	column.add_child(tabs)
	for entry in [["warrior", "Guerreiro"], ["archer", "Arqueiro"], ["mage", "Mago"]]:
		var id := str(entry[0])
		var button := Button.new()
		button.text = entry[1]
		button.icon = STYLE.icon(id)
		button.expand_icon = true
		button.add_theme_constant_override("icon_max_width", 28)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size.y = 50
		button.set_meta("vocation", id)
		button.pressed.connect(func() -> void: select_vocation(id))
		tabs.add_child(button)
		_tabs.append(button)
	_note = Label.new()
	_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	STYLE.style_label(_note, 16, STYLE.MUTED)
	column.add_child(_note)
	_skills = VBoxContainer.new()
	_skills.add_theme_constant_override("separation", 12)
	column.add_child(_skills)
	var locked := HBoxContainer.new()
	locked.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(locked)
	for index in 5:
		locked.add_child(STYLE.picture(STYLE.icon("lock"), Vector2(64, 64)))
	var note := Label.new()
	note.text = "Talentos passivos indisponíveis nesta versão.\nNenhum ponto é gasto nesta tela de consulta."
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	STYLE.style_label(note, 15, STYLE.MUTED)
	column.add_child(note)
	select_vocation("warrior")

func select_vocation(id: String) -> void:
	for button in _tabs:
		STYLE.style_button(button, button.get_meta("vocation") == id)
	for child in _skills.get_children():
		_skills.remove_child(child)
		child.queue_free()
	_note.text = "Três vocações jogáveis. Esta tela consulta habilidades; a vocação é escolhida antes de entrar na ilha."
	for skill in RULES.catalog().get("skills", []):
		if str(skill.get("vocation", "")) != id: continue
		var panel := PanelContainer.new()
		panel.add_theme_stylebox_override("panel", STYLE.classic_style("button"))
		_skills.add_child(panel)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 14)
		panel.add_child(row)
		row.add_child(STYLE.picture(STYLE.icon(str(skill.id)), Vector2(72, 72)))
		var label := Label.new()
		label.text = "%s\n%d MP · %d s de recarga" % [NAMES.get(str(skill.id), "Habilidade"), int(skill.get("mp", 0)), int(skill.get("cooldown_sec", 0))]
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		STYLE.style_label(label, 18, STYLE.CREAM)
		row.add_child(label)

