extends Control

signal vector_changed(value: Vector2)

@export var radius := 72.0
@export var dead_zone := 0.12
var value := Vector2.ZERO
var _touch_index := -1
var _mouse_active := false
var blocked := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(radius * 2.0 + 16.0, radius * 2.0 + 16.0)
	queue_redraw()


func _input(event: InputEvent) -> void:
	if blocked:
		return
	if event is InputEventScreenTouch:
		if event.pressed and _touch_index == -1 and get_global_rect().has_point(event.position):
			_touch_index = event.index
			_update_from_screen(event.position)
			get_viewport().set_input_as_handled()
		elif not event.pressed and event.index == _touch_index:
			_touch_index = -1
			_set_value(Vector2.ZERO)
			get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and event.index == _touch_index:
		_update_from_screen(event.position)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and get_global_rect().has_point(event.position):
			_mouse_active = true
			_update_from_screen(event.position)
		elif not event.pressed and _mouse_active:
			_mouse_active = false
			_set_value(Vector2.ZERO)
	elif event is InputEventMouseMotion and _mouse_active:
		_update_from_screen(event.position)


func _update_from_screen(screen_position: Vector2) -> void:
	var local := screen_position - global_position
	var center := size * 0.5
	var delta := local - center
	var vector := delta / radius
	if vector.length() < dead_zone:
		vector = Vector2.ZERO
	_set_value(vector.limit_length(1.0))


func _set_value(next_value: Vector2) -> void:
	if value.is_equal_approx(next_value):
		return
	value = next_value
	vector_changed.emit(value)
	queue_redraw()


func _draw() -> void:
	var center := size * 0.5
	draw_circle(center, radius, Color(0.08, 0.12, 0.15, 0.68))
	draw_arc(center, radius, 0.0, TAU, 48, Color(0.74, 0.69, 0.56, 0.9), 3.0, true)
	var knob := center + value * radius * 0.62
	draw_circle(knob, radius * 0.42, Color(0.33, 0.31, 0.26, 0.92))
	draw_arc(knob, radius * 0.42, 0.0, TAU, 32, Color(0.97, 0.80, 0.49, 0.9), 2.0, true)


func set_blocked(next_value: bool) -> void:
	if blocked == next_value:
		return
	blocked = next_value
	if blocked:
		_touch_index = -1
		_mouse_active = false
		_set_value(Vector2.ZERO)
