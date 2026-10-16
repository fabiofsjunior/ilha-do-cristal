extends ProgressBar
## Keep ProgressBar's live value contract; compose artwork without baked HP.
const ART = preload("res://game/scripts/ui/hud_art.gd")
var skin := "hp"

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_theme_stylebox_override("background", StyleBoxEmpty.new())
	add_theme_stylebox_override("fill", StyleBoxEmpty.new())
	value_changed.connect(func(_value: float) -> void: queue_redraw())
	resized.connect(queue_redraw)

func interior() -> Rect2:
	var frame := ART.texture(skin + "_frame")
	var values: Array = ART.data().get("bar_interiors", {}).get(skin, [])
	if values.size() != 4:
		push_error("HUD bar interior missing: %s" % skin)
		return Rect2()
	var factor := size / frame.get_size()
	return Rect2(Vector2(float(values[0]), float(values[1])) * factor, Vector2(float(values[2]), float(values[3])) * factor)

func _draw() -> void:
	var frame := ART.texture(skin + "_frame")
	if frame == null:
		return
	draw_texture_rect(frame, Rect2(Vector2.ZERO, size), false)
	var inner := interior()
	draw_rect(inner, Color("1b2228"))
	var fraction := clampf((value - min_value) / maxf(0.001, max_value - min_value), 0, 1)
	if fraction > 0:
		var fill := ART.texture(skin + "_fill")
		draw_texture_rect_region(fill, Rect2(inner.position, Vector2(inner.size.x * fraction, inner.size.y)), Rect2(Vector2.ZERO, Vector2(fill.get_width() * fraction, fill.get_height())))
