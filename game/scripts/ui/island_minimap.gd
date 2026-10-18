extends Control
## Circular camera footprint. Terrain and markers share the same ground projection.
var _position := Vector2.ZERO
var _world_size := Vector2(2048, 1408)
var _map: Texture2D
var _enemies := PackedVector2Array()
var _view_origin := Vector2.ZERO
var _view_right := Vector2(2048, 0)
var _view_down := Vector2(0, 1408)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func set_map(texture: Texture2D) -> void:
	_map = texture
	queue_redraw()

func set_camera_view(origin: Vector2, right: Vector2, down: Vector2) -> void:
	if absf(right.cross(down)) < 0.001:
		return
	_view_origin = origin
	_view_right = right
	_view_down = down
	queue_redraw()

func update_position(point: Vector2, dimensions: Vector2) -> void:
	_position = point
	_world_size = dimensions
	queue_redraw()

func update_enemies(points: PackedVector2Array) -> void:
	_enemies = points
	queue_redraw()

func camera_uv(point: Vector2) -> Vector2:
	var relative := point - _view_origin
	var determinant := _view_right.cross(_view_down)
	return Vector2(relative.cross(_view_down), _view_right.cross(relative)) / determinant

func _circle_radius() -> float:
	return maxf(1.0, minf(size.x, size.y) * 0.5 - 8.0)

func _map_point(point: Vector2, _bounds := Rect2()) -> Vector2:
	return size * 0.5 + (camera_uv(point) - Vector2(0.5, 0.5)) * _circle_radius() * 2.0

func marker_visible(point: Vector2, marker_radius := 2.5) -> bool:
	return _map_point(point).distance_to(size * 0.5) <= _circle_radius() - marker_radius

func _draw() -> void:
	var center := size * 0.5
	var radius := _circle_radius()
	draw_circle(center, radius + 7.0, Color("161522"))
	draw_circle(center, radius, Color("28536c"))
	if _map != null:
		var polygon := PackedVector2Array()
		var uvs := PackedVector2Array()
		for index in range(96):
			var direction := Vector2.from_angle(TAU * float(index) / 96.0)
			var view_uv := Vector2(0.5, 0.5) + direction * 0.5
			polygon.append(center + direction * radius)
			uvs.append((_view_origin + _view_right * view_uv.x + _view_down * view_uv.y) / _world_size)
		draw_polygon(polygon, PackedColorArray([Color.WHITE]), uvs, _map)
	for point in _enemies:
		if marker_visible(point):
			var marker := _map_point(point)
			draw_circle(marker, 2.5, Color("411b20"))
			draw_circle(marker, 1.6, Color("ff464d"))
	if marker_visible(_position, 5.0):
		var marker := _map_point(_position)
		draw_circle(marker, 5.0, Color("17232d"))
		draw_circle(marker, 3.0, Color("fff3bb"))
	# The ring covers the polygon edge without a rectangular backing panel.
	draw_arc(center, radius + 3.0, 0.0, TAU, 96, Color("815025"), 7.0, false)
	draw_arc(center, radius + 3.0, 0.0, TAU, 96, Color("ffc44e"), 3.0, false)
	draw_arc(center, radius + 6.0, 0.0, TAU, 96, Color("ffe298"), 1.0, false)
