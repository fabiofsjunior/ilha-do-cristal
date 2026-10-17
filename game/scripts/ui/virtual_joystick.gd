extends Control

const ART = preload("res://game/scripts/ui/hud_art.gd")

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
	var mask := Control.new()
	mask.size = size
	mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mask.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
	mask.draw.connect(func() -> void: mask.draw_circle(size * 0.5, size.x * 0.49, Color.WHITE))
	add_child(mask)
	var ring := TextureRect.new()
	ring.size = size
	ring.texture = ART.texture("joystick_ring")
	ring.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ring.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mask.add_child(ring)
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
	# Input positions are in viewport coordinates. Convert through the full canvas
	# transform so HUD scaling and safe-area offsets do not skew joystick direction.
	var local := get_global_transform_with_canvas().affine_inverse() * screen_position
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
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var center := size * 0.5
	var knob := center + value * radius * 0.52
	var dimensions := Vector2.ONE * radius * 0.92
	draw_texture_rect(ART.texture("joystick_knob"), Rect2(knob - dimensions * 0.5, dimensions), false)


func set_blocked(next_value: bool) -> void:
	if blocked == next_value:
		return
	blocked = next_value
	if blocked:
		_touch_index = -1
		_mouse_active = false
		_set_value(Vector2.ZERO)
