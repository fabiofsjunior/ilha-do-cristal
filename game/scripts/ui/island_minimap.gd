extends Control
## Circular camera footprint. Terrain and markers share the same ground projection.
var _position := Vector2.ZERO
var _world_size := Vector2(2048, 1408)
var _map: Texture2D
var _enemies := PackedVector2Array()
var _allocations := PackedVector2Array()
var _allocation_colors := PackedColorArray()
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


func set_allocations(points: PackedVector2Array, colors: PackedColorArray) -> void:
	_allocations = points
	_allocation_colors = colors
	queue_redraw()

func camera_uv(point: Vector2) -> Vector2:
	var relative := point - _view_origin
	var determinant := _view_right.cross(_view_down)
	return Vector2(relative.cross(_view_down), _view_right.cross(relative)) / determinant

func _circle_radius() -> float:
	return maxf(1.0, size.x * 0.5 - 8.0)


func _map_center() -> Vector2:
	return Vector2(size.x * 0.5, size.x * 0.5)

func _map_point(point: Vector2, _bounds := Rect2()) -> Vector2:
	return _map_center() + (camera_uv(point) - Vector2(0.5, 0.5)) * _circle_radius() * 2.0

func marker_visible(point: Vector2, marker_radius := 2.5) -> bool:
	return _map_point(point).distance_to(_map_center()) <= _circle_radius() - marker_radius

func _draw() -> void:
	var center := _map_center()
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
	for index in range(mini(_allocations.size(), _allocation_colors.size())):
		var point := _allocations[index]
		if marker_visible(point, 4.0):
			var marker := _map_point(point)
			draw_circle(marker, 4.0, Color("122733"))
			draw_circle(marker, 2.6, _allocation_colors[index])
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
	_draw_allocation_legend()


func _draw_allocation_legend() -> void:
	var panel := Rect2(3.0, size.x + 3.0, size.x - 6.0, size.y - size.x - 6.0)
	draw_rect(panel, Color("d9162630"), true)
	draw_rect(panel, Color("b8784c"), false, 1.0)
	_draw_legend_item(Vector2(10.0, size.x + 20.0), Color("35ddf3"), "Litoral 4")
	_draw_legend_item(Vector2(size.x * 0.51, size.x + 20.0), Color("98df58"), "Floresta 12")
	_draw_legend_item(Vector2(10.0, size.x + 40.0), Color("ffc75e"), "Platô 8")
	_draw_legend_item(Vector2(size.x * 0.51, size.x + 40.0), Color("c986ff"), "Corrupção 6")


func _draw_legend_item(position: Vector2, color: Color, label: String) -> void:
	draw_circle(position + Vector2(3.0, -3.0), 3.5, Color("10202a"))
	draw_circle(position + Vector2(3.0, -3.0), 2.2, color)
	draw_string(ThemeDB.fallback_font, position + Vector2(10.0, 0.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 10, Color("f6e9cc"))
