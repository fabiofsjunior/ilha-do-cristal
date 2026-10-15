extends CanvasLayer

signal pause_pressed
signal interact_pressed
signal joystick_moved(value: Vector2)
signal zoom_requested(delta: int)

const UI_STYLE = preload("res://game/scripts/ui/ui_style.gd")
const JOYSTICK = preload("res://game/scripts/ui/virtual_joystick.gd")

var _root: Control
var _status: Label
var _name_label: Label
var _interact_button: Button


func _ready() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_root)
	_build()


func _build() -> void:
	var header := PanelContainer.new()
	header.position = Vector2(18, 16)
	header.custom_minimum_size = Vector2(420, 82)
	header.add_theme_stylebox_override(
		"panel", UI_STYLE.panel_style(Color(0.10, 0.08, 0.15, 0.88), Color("75608c"))
	)
	_root.add_child(header)
	var header_box := VBoxContainer.new()
	header_box.add_theme_constant_override("separation", 2)
	header.add_child(header_box)
	_name_label = Label.new()
	_name_label.text = "A Ilha do Cristal · sessão local"
	UI_STYLE.style_label(_name_label, 17, UI_STYLE.GOLD)
	header_box.add_child(_name_label)
	var note := Label.new()
	note.text = "Sem combate/LAN/contas/save · personagens CORRIGIR\nterreno CANDIDATO"
	UI_STYLE.style_label(note, 12, UI_STYLE.MUTED)
	header_box.add_child(note)

	var pause := Button.new()
	pause.text = "Ⅱ Pausa"
	pause.position = Vector2(-150, 18)
	pause.anchor_left = 1.0
	pause.anchor_right = 1.0
	pause.custom_minimum_size = Vector2(132, 50)
	UI_STYLE.style_button(pause, true)
	pause.pressed.connect(func() -> void: pause_pressed.emit())
	_root.add_child(pause)

	var status_panel := PanelContainer.new()
	status_panel.position = Vector2(18, 112)
	status_panel.custom_minimum_size = Vector2(560, 44)
	status_panel.add_theme_stylebox_override(
		"panel", UI_STYLE.panel_style(Color(0.08, 0.07, 0.12, 0.82), Color("594b69"))
	)
	_root.add_child(status_panel)
	_status = Label.new()
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UI_STYLE.style_label(_status, 14, UI_STYLE.CREAM)
	status_panel.add_child(_status)

	var joystick = JOYSTICK.new()
	joystick.name = "VirtualJoystick"
	joystick.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	joystick.position = Vector2(18, -190)
	joystick.size = Vector2(160, 160)
	joystick.radius = 68.0
	joystick.vector_changed.connect(func(value: Vector2) -> void: joystick_moved.emit(value))
	_root.add_child(joystick)
	var hint := Label.new()
	hint.text = "WASD / setas"
	hint.position = Vector2(28, -30)
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", UI_STYLE.CREAM)
	joystick.add_child(hint)

	_interact_button = Button.new()
	_interact_button.text = "◇ Interagir"
	_interact_button.anchor_left = 1.0
	_interact_button.anchor_top = 1.0
	_interact_button.anchor_right = 1.0
	_interact_button.anchor_bottom = 1.0
	_interact_button.position = Vector2(-210, -120)
	_interact_button.custom_minimum_size = Vector2(186, 58)
	UI_STYLE.style_button(_interact_button, true)
	_interact_button.pressed.connect(func() -> void: interact_pressed.emit())
	_root.add_child(_interact_button)

	var zoom_out := Button.new()
	zoom_out.text = "−"
	zoom_out.anchor_left = 1.0
	zoom_out.anchor_right = 1.0
	zoom_out.position = Vector2(-128, 82)
	zoom_out.custom_minimum_size = Vector2(48, 46)
	UI_STYLE.style_button(zoom_out)
	zoom_out.pressed.connect(func() -> void: zoom_requested.emit(-1))
	_root.add_child(zoom_out)
	var zoom_in := Button.new()
	zoom_in.text = "+"
	zoom_in.anchor_left = 1.0
	zoom_in.anchor_right = 1.0
	zoom_in.position = Vector2(-72, 82)
	zoom_in.custom_minimum_size = Vector2(48, 46)
	UI_STYLE.style_button(zoom_in)
	zoom_in.pressed.connect(func() -> void: zoom_requested.emit(1))
	_root.add_child(zoom_in)


func set_character_name(value: String) -> void:
	if _name_label != null:
		_name_label.text = "A Ilha do Cristal · %s (Guerreiro)" % value


func set_status(value: String) -> void:
	if _status != null:
		_status.text = value


func set_interaction_available(available: bool) -> void:
	if _interact_button != null:
		_interact_button.disabled = not available
		_interact_button.modulate = Color.WHITE if available else Color(0.78, 0.76, 0.82, 0.72)
