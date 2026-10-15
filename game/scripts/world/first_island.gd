extends Node2D

signal pause_requested
signal interaction_requested

const TILE_MANIFEST_DIR := "res://assets/environments/terrain_mvp_candidate_v1"
const TILE_MANIFEST := TILE_MANIFEST_DIR + "/terrain_mvp_candidate_v1.json"
const LAYOUT_PATH := "res://game/data/first_island_layout.json"
const PLAYER_SCENE := preload("res://game/scenes/player.tscn")
const TILE_SIZE := 32
const ZOOM_LEVELS := [0.5, 0.75, 1.0, 1.25]

var selected_character_id := "melissa"
var character_name := "Melissa"
var _player
var _camera: Camera2D
var _hud
var _beacon_position := Vector2.ZERO
var _current_zoom_index := 1
var _layout: Dictionary
var _tile_lookup: Dictionary = {}


func _ready() -> void:
	_layout = _load_json(LAYOUT_PATH)
	var manifest := _load_json(TILE_MANIFEST)
	if _layout.is_empty() or manifest.is_empty():
		return
	if not _build_tile_set(manifest):
		return
	_paint_map(manifest)
	_build_world_collision()
	_build_props()
	_build_beacon()
	_build_player()
	_connect_hud()


func _process(_delta: float) -> void:
	if _player != null and _beacon_position != Vector2.ZERO and _hud != null:
		_hud.set_interaction_available(
			_player.global_position.distance_to(_beacon_position) <= 104.0
		)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_P:
			pause_requested.emit()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_E:
			interaction_requested.emit()
			get_viewport().set_input_as_handled()


func interact_with_beacon() -> void:
	if _player == null:
		return
	if _player.global_position.distance_to(_beacon_position) <= 104.0:
		var feedback := "O cristal responde com um brilho. Interação demonstrativa: "
		feedback += "sem inventário ou progresso salvo."
		_hud.set_status(feedback)
	else:
		_hud.set_status("Chegue perto do cristal roxo para interagir.")


func _connect_hud() -> void:
	_hud = get_node("HUD") as CanvasLayer
	_hud.layer = 1
	_hud.set_character_name(character_name)
	_hud.set_status("Explore a faixa inicial da ilha e aproxime-se do cristal.")
	_hud.pause_pressed.connect(func() -> void: pause_requested.emit())
	_hud.interact_pressed.connect(func() -> void: interaction_requested.emit())
	_hud.joystick_moved.connect(_player.set_joystick_vector)
	_hud.zoom_requested.connect(_change_zoom)


func _build_tile_set(manifest: Dictionary) -> bool:
	var atlas_data: Dictionary = manifest.get("atlas", {})
	var atlas_path := TILE_MANIFEST.get_base_dir().path_join(str(atlas_data.get("file", "")))
	if not ResourceLoader.exists(atlas_path):
		push_error("Atlas de terreno ausente: %s" % atlas_path)
		return false
	var atlas_texture := load(atlas_path) as Texture2D
	if atlas_texture == null:
		push_error("Falha ao importar terreno candidate: %s" % atlas_path)
		return false
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)
	var source := TileSetAtlasSource.new()
	source.texture = atlas_texture
	source.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	for tile in manifest.get("tiles", []):
		var id := str(tile.get("id", ""))
		var coordinate: Array = tile.get("atlas_xy_tiles", [0, 0])
		if id.is_empty() or coordinate.size() < 2:
			push_error("Tile de terreno com metadata incompleta: %s" % str(tile))
			continue
		var atlas_coordinate := Vector2i(int(coordinate[0]), int(coordinate[1]))
		source.create_tile(atlas_coordinate)
		_tile_lookup[id] = {
			"atlas": atlas_coordinate,
			"group": str(tile.get("group", "")),
			"role": str(tile.get("role", ""))
		}
	tile_set.add_source(source, 0)
	for node_name in ["BaseTiles", "Transitions", "Paths"]:
		var layer := get_node(node_name) as TileMapLayer
		layer.tile_set = tile_set
		layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	return true


func _paint_map(manifest: Dictionary) -> void:
	var size_data: Array = _layout.get("grid_size", [64, 44])
	var width := int(size_data[0])
	var height := int(size_data[1])
	var base_by_group: Dictionary = {}
	for tile in manifest.get("tiles", []):
		if str(tile.get("role", "")) == "base":
			var group := str(tile.get("group", ""))
			if not base_by_group.has(group):
				base_by_group[group] = []
			base_by_group[group].append(str(tile.get("id", "")))
	var base_layer := get_node("BaseTiles") as TileMapLayer
	var seeded := int(_layout.get("seed", 0))
	for band in _layout.get("surface_bands", []):
		var group := str(band.get("group", ""))
		var variants: Array = base_by_group.get(group, [])
		if variants.is_empty():
			push_error("Nenhum tile base no grupo %s" % group)
			continue
		for x in range(int(band.get("from_x", 0)), int(band.get("to_x", 0))):
			for y in range(height):
				var index := (x * 17 + y * 31 + seeded) % variants.size()
				_set_tile(base_layer, Vector2i(x, y), str(variants[index]))
	for area in _layout.get("surface_areas", []):
		var variants: Array = base_by_group.get(str(area.get("group", "")), [])
		if variants.is_empty():
			continue
		for x in range(int(area.get("from_x", 0)), int(area.get("to_x", 0))):
			for y in range(int(area.get("from_y", 0)), int(area.get("to_y", 0))):
				_set_tile(
					base_layer,
					Vector2i(x, y),
					str(variants[(x * 17 + y * 31 + seeded) % variants.size()])
				)
	for band in _layout.get("transition_bands", []):
		var id := "%s_edge_%s" % [str(band.get("prefix", "")), str(band.get("edge", ""))]
		var x := int(band.get("x", 0))
		for y in range(height):
			_set_tile(get_node("Transitions") as TileMapLayer, Vector2i(x, y), id)
	for patch in _layout.get("transition_patches", []):
		_paint_transition_patch(patch)
	for path in _layout.get("path_network", []):
		var cell: Array = path.get("cell", [0, 0])
		_set_tile(
			get_node("Paths") as TileMapLayer,
			Vector2i(int(cell[0]), int(cell[1])),
			str(path.get("id", ""))
		)


func _paint_transition_patch(patch: Dictionary) -> void:
	var prefix := str(patch.get("prefix", ""))
	var center: Array = patch.get("center", [0, 0])
	var cx := int(center[0])
	var cy := int(center[1])
	var center_id := str(patch.get("inner_base", ""))
	var layer := get_node("Transitions") as TileMapLayer
	var cells := [
		[Vector2i(cx - 1, cy - 1), "%s_corner_nw" % prefix],
		[Vector2i(cx, cy - 1), "%s_edge_n" % prefix],
		[Vector2i(cx + 1, cy - 1), "%s_corner_ne" % prefix],
		[Vector2i(cx - 1, cy), "%s_edge_w" % prefix],
		[Vector2i(cx, cy), center_id],
		[Vector2i(cx + 1, cy), "%s_edge_e" % prefix],
		[Vector2i(cx - 1, cy + 1), "%s_corner_sw" % prefix],
		[Vector2i(cx, cy + 1), "%s_edge_s" % prefix],
		[Vector2i(cx + 1, cy + 1), "%s_corner_se" % prefix]
	]
	for item in cells:
		_set_tile(layer, item[0], str(item[1]))


func _set_tile(layer: TileMapLayer, cell: Vector2i, tile_id: String) -> void:
	if not _tile_lookup.has(tile_id):
		push_error("ID de tile do layout não existe no atlas: %s" % tile_id)
		return
	var tile: Dictionary = _tile_lookup[tile_id]
	layer.set_cell(cell, 0, tile.atlas)


func _build_world_collision() -> void:
	var size_data: Array = _layout.get("grid_size", [64, 44])
	var map_width := float(size_data[0]) * TILE_SIZE
	var map_height := float(size_data[1]) * TILE_SIZE
	_add_rect_collider(
		Vector2(TILE_SIZE * 4.0, map_height * 0.5),
		Vector2(TILE_SIZE * 8.0, map_height),
		"BlockedWater"
	)
	_add_rect_collider(Vector2(-20, map_height * 0.5), Vector2(40, map_height + 80), "WestBoundary")
	_add_rect_collider(
		Vector2(map_width + 20, map_height * 0.5), Vector2(40, map_height + 80), "EastBoundary"
	)
	_add_rect_collider(Vector2(map_width * 0.5, -20), Vector2(map_width + 80, 40), "NorthBoundary")
	_add_rect_collider(
		Vector2(map_width * 0.5, map_height + 20), Vector2(map_width + 80, 40), "SouthBoundary"
	)
	var camera := get_node("Camera2D") as Camera2D
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(map_width)
	camera.limit_bottom = int(map_height)
	camera.limit_smoothed = false
	camera.position_smoothing_enabled = false


func _add_rect_collider(position: Vector2, dimensions: Vector2, label: String) -> void:
	var body := StaticBody2D.new()
	body.name = label
	body.position = position
	body.collision_layer = 1
	body.collision_mask = 1
	var shape_node := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = dimensions
	shape_node.shape = shape
	body.add_child(shape_node)
	add_child(body)


func _build_props() -> void:
	var actors := get_node("Actors") as Node2D
	actors.y_sort_enabled = true
	actors.z_index = 3
	for obstacle in _layout.get("obstacles", []):
		var cell: Array = obstacle.get("cell", [0, 0])
		var center := Vector2((int(cell[0]) + 0.5) * TILE_SIZE, (int(cell[1]) + 0.5) * TILE_SIZE)
		var kind := str(obstacle.get("kind", "tree"))
		var prop := Node2D.new()
		prop.name = "%s_%d_%d_proxy" % [kind, int(cell[0]), int(cell[1])]
		prop.position = center
		if kind == "tree":
			_add_polygon(
				prop,
				[Vector2(-7, 14), Vector2(7, 14), Vector2(7, 28), Vector2(-7, 28)],
				Color("79503c")
			)
			_add_polygon(
				prop,
				[
					Vector2(-21, 8),
					Vector2(-17, -10),
					Vector2(-6, -22),
					Vector2(11, -18),
					Vector2(22, -3),
					Vector2(16, 12),
					Vector2(0, 17)
				],
				Color("39694b")
			)
			_add_polygon(
				prop,
				[
					Vector2(-11, -9),
					Vector2(-4, -18),
					Vector2(8, -15),
					Vector2(13, -5),
					Vector2(1, 2)
				],
				Color("57885a")
			)
			_add_rect_collider(center + Vector2(0, 8), Vector2(26, 28), prop.name + "Collision")
		else:
			_add_polygon(
				prop,
				[
					Vector2(-16, 10),
					Vector2(-20, 0),
					Vector2(-10, -13),
					Vector2(8, -16),
					Vector2(19, -4),
					Vector2(14, 10),
					Vector2(0, 15)
				],
				Color("7c8492")
			)
			_add_polygon(
				prop,
				[Vector2(-8, -7), Vector2(4, -12), Vector2(11, -5), Vector2(1, -2)],
				Color("a4adba")
			)
			_add_rect_collider(center + Vector2(0, 2), Vector2(32, 25), prop.name + "Collision")
		actors.add_child(prop)


func _add_polygon(parent: Node2D, points: Array, color: Color) -> void:
	var polygon := Polygon2D.new()
	var packed := PackedVector2Array()
	for point in points:
		packed.append(point)
	polygon.polygon = packed
	polygon.color = color
	parent.add_child(polygon)


func _build_beacon() -> void:
	var cell: Array = _layout.get("beacon_cell", [21, 23])
	_beacon_position = Vector2((int(cell[0]) + 0.5) * TILE_SIZE, (int(cell[1]) + 0.5) * TILE_SIZE)
	var beacon := Node2D.new()
	beacon.name = "CrystalInteractionPlaceholder"
	beacon.position = _beacon_position
	_add_polygon(
		beacon, [Vector2(0, -28), Vector2(14, 0), Vector2(0, 28), Vector2(-14, 0)], Color("a780e7")
	)
	_add_polygon(
		beacon, [Vector2(0, -18), Vector2(7, 0), Vector2(0, 18), Vector2(-7, 0)], Color("bcecf5")
	)
	var ring := Polygon2D.new()
	ring.polygon = PackedVector2Array(
		[Vector2(-22, 31), Vector2(22, 31), Vector2(29, 38), Vector2(-29, 38)]
	)
	ring.color = Color(0.44, 0.77, 0.83, 0.62)
	beacon.add_child(ring)
	get_node("Actors").add_child(beacon)


func _build_player() -> void:
	var spawn: Array = _layout.get("spawn_cell", [16, 23])
	_player = PLAYER_SCENE.instantiate() as CharacterBody2D
	_player.selected_character_id = selected_character_id
	_player.position = Vector2((int(spawn[0]) + 0.5) * TILE_SIZE, (int(spawn[1]) + 0.5) * TILE_SIZE)
	_player.name = "LocalPlayer"
	get_node("Actors").add_child(_player)
	_camera = get_node("Camera2D") as Camera2D
	_camera.reparent(_player)
	_camera.position = Vector2.ZERO
	_camera.make_current()


func _change_zoom(delta: int) -> void:
	_current_zoom_index = clampi(_current_zoom_index + delta, 0, ZOOM_LEVELS.size() - 1)
	_camera.zoom = Vector2.ONE * float(ZOOM_LEVELS[_current_zoom_index])


func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("Dados do mapa ausentes: %s" % path)
		return {}
	var result = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not result is Dictionary:
		push_error("Dados do mapa inválidos: %s" % path)
		return {}
	return result
