extends Control
## Live position over a map snapshot, with no input interception.
var _position := Vector2.ZERO
var _world_size := Vector2(2048, 1408)
var _map: Texture2D
var _enemies := PackedVector2Array()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func set_map(texture: Texture2D) -> void:
	_map = texture
	queue_redraw()

func update_position(point: Vector2, dimensions: Vector2) -> void:
	_position = point
	_world_size = dimensions
	queue_redraw()

func update_enemies(points: PackedVector2Array) -> void:
	_enemies = points
	queue_redraw()

func _map_point(point: Vector2, bounds: Rect2) -> Vector2:
	return bounds.position + (point / _world_size).clamp(Vector2.ZERO, Vector2.ONE) * bounds.size

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("171f24"))
	draw_rect(Rect2(Vector2(2, 2), size - Vector2(4, 4)), Color("c2aa73"), false, 2)
	var bounds := Rect2(Vector2(7, 7), size - Vector2(14, 14))
	if _map != null:
		draw_texture_rect(_map, bounds, false)
	for point in _enemies:
		var enemy_marker := _map_point(point, bounds)
		draw_circle(enemy_marker, 2.5, Color("411b20"))
		draw_circle(enemy_marker, 1.6, Color("ff464d"))
	var marker := _map_point(_position, bounds)
	draw_circle(marker, 5, Color("17232d"))
	draw_circle(marker, 3, Color("fff3bb"))
	draw_line(marker, marker + Vector2(0, -7), Color.WHITE, 2)
