extends Node2D
## Isolated visual review scene using the game's production 2.5D terrain renderer.
## It does not load saves, create runtime creatures, or alter first_island.tscn.

const TERRAIN_SOURCE_PATH := "res://assets/environments/ilha_cristal_isometric_candidate_v1/ilha_cristal_tileset_isometrico_v1.png"
const PROPS_SOURCE_PATH := "res://assets/environments/ilha_cristal_isometric_candidate_v1/ilha_cristal_elementos_isometricos_v1.png"
const VIEW_SCRIPT_PATH := "res://game/scripts/world/isometric_3d_view.gd"

const TILE_PIXELS := 128
const TERRAIN_X := [0, 157, 314, 470, 627, 784, 940, 1097, 1254]
const TERRAIN_Y := [0, 156, 306, 462, 619, 785, 936, 1080, 1254]
const SAMPLE_PROP_RECTS := [
	[15, 57, 137, 184], # tree_01
	[308, 19, 494, 195], # tree_03
	[623, 33, 808, 201], # tree_05
	[159, 399, 299, 513], # bush_02
	[955, 410, 1086, 515], # fern_01
	[166, 211, 296, 374], # palm_02
	[493, 236, 617, 373], # palm_04
	[10, 204, 148, 377], # palm_01
	[929, 935, 1090, 1062], # wrecked_boat
	[31, 826, 122, 912], # crystal_blue_01
	[1097, 936, 1254, 1080], # waterfall_02, terrain sheet
	[314, 619, 470, 785], # cliff_grass_03, terrain sheet
	[11, 1064, 146, 1237], # corrupt_tree_01
	[947, 1065, 1090, 1244], # corrupt_ruin_01
	[1102, 1065, 1244, 1244] # corrupt_ruin_arch
]
const SAMPLE_PROP_IS_TERRAIN := [false, false, false, false, false, false, false, false, false, false, true, true, false, false, false]
const SAMPLE_PROP_ATLAS_COORDS := [
	Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0),
	Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1),
	Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2),
	Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3)
]

const MAP_ORIGIN := Vector2i(12, 8)
const MAP_WIDTH := 16
const MAP_HEIGHT := 10
const SQM_PER_TILE := 4
const WINDOW_SIZE := Vector2i(1280, 720)

var _layout := {
	"grid_size": [160, 120],
	# Keep the production renderer's legacy beacon outside this review crop;
	# the candidate blue crystal in ManualProps is the sample focal point.
	"beacon_cell": [150, 110],
	"obstacles": []
}
var _player: Node2D
var _state = null
var _creature_actors: Dictionary = {}
var _resource_nodes: Array[Dictionary] = []
var _iso_view: Node3D
var _monster_slots: Array[Dictionary] = []
var _marker_textures: Dictionary = {}


func _ready() -> void:
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_size(WINDOW_SIZE)
		DisplayServer.window_set_title("Ilha do Cristal · amostra de tileset v0.2")
	var terrain_texture := load(TERRAIN_SOURCE_PATH) as Texture2D
	var props_texture := load(PROPS_SOURCE_PATH) as Texture2D
	if terrain_texture == null or props_texture == null:
		push_error("Amostra da Ilha do Cristal: uma das pranchas-fonte de terreno/props não carregou.")
		return
	var source_tilesets := _build_candidate_tilesets(terrain_texture.get_image(), props_texture.get_image())
	var terrain_tileset := source_tilesets.get("terrain") as TileSet
	var props_tileset := source_tilesets.get("props") as TileSet
	if terrain_tileset == null or props_tileset == null:
		push_error("Amostra da Ilha do Cristal: não foi possível compor os TileSets em memória.")
		return
	_create_map_layers(terrain_tileset, props_tileset)
	_populate_surface()
	_populate_props()
	_populate_monster_slots()
	_create_preview_world(terrain_tileset)
	_create_legend()
	var capture_path := OS.get_environment("ILHA_CRISTAL_REVIEW_CAPTURE")
	if not capture_path.is_empty():
		call_deferred("_capture_review_frame", capture_path)


func _build_candidate_tilesets(terrain_sheet: Image, props_sheet: Image) -> Dictionary:
	if terrain_sheet.is_empty() or props_sheet.is_empty():
		push_error("Amostra da Ilha do Cristal: uma prancha-fonte está vazia.")
		return {}
	var terrain_atlas := Image.create(8 * TILE_PIXELS, 8 * TILE_PIXELS, false, Image.FORMAT_RGBA8)
	var props_atlas := Image.create(4 * TILE_PIXELS, 4 * TILE_PIXELS, false, Image.FORMAT_RGBA8)
	for row in range(8):
		for column in range(8):
			var source_rect := Rect2i(
				TERRAIN_X[column], TERRAIN_Y[row],
				TERRAIN_X[column + 1] - TERRAIN_X[column],
				TERRAIN_Y[row + 1] - TERRAIN_Y[row]
			)
			var crop := terrain_sheet.get_region(source_rect)
			var tile := _resize_ground_face(crop) if row < 4 or (row == 7 and column < 4) else _resize_contained(crop, 128, false)
			terrain_atlas.blit_rect(tile, Rect2i(0, 0, TILE_PIXELS, TILE_PIXELS), Vector2i(column, row) * TILE_PIXELS)
	for index in range(SAMPLE_PROP_RECTS.size()):
		var bounds: Array = SAMPLE_PROP_RECTS[index]
		var use_terrain_sheet: bool = SAMPLE_PROP_IS_TERRAIN[index]
		var sheet := terrain_sheet if use_terrain_sheet else props_sheet
		var crop := sheet.get_region(Rect2i(int(bounds[0]), int(bounds[1]), int(bounds[2]) - int(bounds[0]), int(bounds[3]) - int(bounds[1])))
		var tile := _resize_contained(crop, 120, true)
		var atlas_cell: Vector2i = SAMPLE_PROP_ATLAS_COORDS[index]
		props_atlas.blit_rect(tile, Rect2i(0, 0, TILE_PIXELS, TILE_PIXELS), atlas_cell * TILE_PIXELS)
	return {
		"terrain": _make_candidate_tileset(ImageTexture.create_from_image(terrain_atlas), 8, 8),
		"props": _make_candidate_tileset(ImageTexture.create_from_image(props_atlas), 4, 4)
	}


func _make_candidate_tileset(texture: Texture2D, columns: int, rows: int) -> TileSet:
	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(128, 64)
	tileset.tile_shape = TileSet.TILE_SHAPE_ISOMETRIC
	tileset.tile_layout = 5
	var source := TileSetAtlasSource.new()
	source.texture = texture
	source.texture_region_size = Vector2i(TILE_PIXELS, TILE_PIXELS)
	for y in range(rows):
		for x in range(columns):
			source.create_tile(Vector2i(x, y))
	tileset.add_source(source, 0)
	return tileset


func _resize_ground_face(image: Image) -> Image:
	_clear_alpha_residue(image)
	var min_x := image.get_width()
	var min_y := image.get_height()
	var max_x := -1
	var max_y := -1
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a > 12.0 / 255.0:
				min_x = mini(min_x, x)
				min_y = mini(min_y, y)
				max_x = maxi(max_x, x)
				max_y = maxi(max_y, y)
	var cell := Image.create(TILE_PIXELS, TILE_PIXELS, false, Image.FORMAT_RGBA8)
	if max_x < min_x or max_y < min_y:
		return cell
	var art := image.get_region(Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1))
	art.resize(TILE_PIXELS + 2, 66, Image.INTERPOLATE_LANCZOS)
	for y in range(66):
		for x in range(TILE_PIXELS + 2):
			var dest_x := x - 1
			var dest_y := y + 31
			if dest_x >= 0 and dest_x < TILE_PIXELS and dest_y >= 0 and dest_y < TILE_PIXELS:
				cell.set_pixel(dest_x, dest_y, art.get_pixel(x, y))
	return cell


func _resize_contained(image: Image, max_size: int, bottom_align: bool) -> Image:
	_clear_alpha_residue(image)
	var source_size := image.get_size()
	var max_dimension := maxi(source_size.x, source_size.y)
	if max_dimension > max_size:
		var ratio := float(max_size) / float(max_dimension)
		image.resize(maxi(1, roundi(source_size.x * ratio)), maxi(1, roundi(source_size.y * ratio)), Image.INTERPOLATE_LANCZOS)
	var cell := Image.create(TILE_PIXELS, TILE_PIXELS, false, Image.FORMAT_RGBA8)
	var x := (TILE_PIXELS - image.get_width()) / 2
	var y := TILE_PIXELS - image.get_height() - 3 if bottom_align else (TILE_PIXELS - image.get_height()) / 2
	cell.blit_rect(image, Rect2i(0, 0, image.get_width(), image.get_height()), Vector2i(x, y))
	return cell


func _clear_alpha_residue(image: Image) -> void:
	image.convert(Image.FORMAT_RGBA8)
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var color := image.get_pixel(x, y)
			if color.a * 255.0 < 12.0:
				image.set_pixel(x, y, Color(0, 0, 0, 0))


func _create_map_layers(terrain_tileset: TileSet, props_tileset: TileSet) -> void:
	for layer_name in ["BaseTiles", "Transitions", "Paths"]:
		var layer := TileMapLayer.new()
		layer.name = layer_name
		layer.tile_set = terrain_tileset
		add_child(layer)
	var manual_terrain := TileMapLayer.new()
	manual_terrain.name = "ManualTerrain"
	manual_terrain.tile_set = terrain_tileset
	manual_terrain.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(manual_terrain)
	var manual_props := TileMapLayer.new()
	manual_props.name = "ManualProps"
	manual_props.tile_set = props_tileset
	manual_props.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(manual_props)
	var actors := Node2D.new()
	actors.name = "Actors"
	add_child(actors)
	_player = Node2D.new()
	_player.name = "ReviewFocus"
	var focus_tile := MAP_ORIGIN + Vector2i(MAP_WIDTH / 2, MAP_HEIGHT / 2)
	_player.position = Vector2(
		(float(focus_tile.x) + 0.5) * SQM_PER_TILE * 32.0,
		(float(focus_tile.y) + 0.5) * SQM_PER_TILE * 32.0
	)
	actors.add_child(_player)


func _populate_surface() -> void:
	var layer := get_node("ManualTerrain") as TileMapLayer
	var left_by_row := [7, 5, 3, 2, 1, 1, 2, 4, 6, 8]
	var right_by_row := [12, 14, 15, 15, 14, 13, 11, 10, 9, 8]
	for y in range(MAP_HEIGHT):
		for x in range(MAP_WIDTH):
			var cell := MAP_ORIGIN + Vector2i(x, y)
			var terrain := Vector2i(6, 0) # ocean, deep water
			if _distance_to_land_edge(x, y, left_by_row, right_by_row) <= 1:
				terrain = Vector2i(7, 0) # shallow water
			if x >= left_by_row[y] and x <= right_by_row[y]:
				terrain = _land_tile(x, y)
				if _is_outer_shore(x, y, left_by_row, right_by_row):
					terrain = _shore_tile(x, y, left_by_row, right_by_row)
			layer.set_cell(cell, 0, terrain)
	
	# A short footpath leads from the beach through the green interior.
	for path_cell in [Vector2i(4, 7), Vector2i(5, 7), Vector2i(6, 6), Vector2i(7, 6), Vector2i(8, 5)]:
		layer.set_cell(MAP_ORIGIN + path_cell, 0, Vector2i(0, 2))

	# A small, quiet lake gives the existing crystal prop a readable focal point.
	for lake_cell in [Vector2i(8, 5), Vector2i(9, 5), Vector2i(8, 6)]:
		layer.set_cell(MAP_ORIGIN + lake_cell, 0, Vector2i(6, 0))


func _land_tile(x: int, y: int) -> Vector2i:
	if x <= 4:
		return Vector2i(3, 0) # sand
	if x <= 8:
		if x >= 7 and y >= 2 and y <= 7:
			return Vector2i(2, 0) # dense forest floor
		return Vector2i((x + y) % 2, 0)
	if x <= 12:
		if x >= 10 and y >= 3 and y <= 6:
			return Vector2i(5, 0) # exposed stone on the high plateau
		return Vector2i(0, 0) if y % 2 == 0 else Vector2i(1, 0)
	return Vector2i((x + y) % 2, 7) # corrupted ground


func _distance_to_land_edge(x: int, y: int, left: Array, right: Array) -> int:
	var best := 999
	for row in range(maxi(0, y - 1), mini(MAP_HEIGHT, y + 2)):
		best = mini(best, absi(x - int(left[row])))
		best = mini(best, absi(x - int(right[row])))
	return best


func _is_outer_shore(x: int, y: int, left: Array, right: Array) -> bool:
	if x == int(left[y]) or x == int(right[y]):
		return true
	if y > 0 and (x < int(left[y - 1]) or x > int(right[y - 1])):
		return true
	if y + 1 < MAP_HEIGHT and (x < int(left[y + 1]) or x > int(right[y + 1])):
		return true
	return false


func _shore_tile(x: int, y: int, left: Array, right: Array) -> Vector2i:
	if x == int(left[y]):
		return Vector2i(0, 3)
	if x == int(right[y]):
		return Vector2i(1, 3)
	if y > 0 and (x < int(left[y - 1]) or x > int(right[y - 1])):
		return Vector2i(2, 3)
	return Vector2i(3, 3)


func _populate_props() -> void:
	var layer := get_node("ManualProps") as TileMapLayer
	var placements: Array[Dictionary] = [
		{"cell": Vector2i(5, 3), "atlas": Vector2i(0, 0)},
		{"cell": Vector2i(7, 2), "atlas": Vector2i(1, 0)},
		{"cell": Vector2i(6, 5), "atlas": Vector2i(0, 0)},
		{"cell": Vector2i(8, 3), "atlas": Vector2i(2, 0)},
		{"cell": Vector2i(7, 5), "atlas": Vector2i(3, 0)},
		{"cell": Vector2i(8, 6), "atlas": Vector2i(0, 1)},
		{"cell": Vector2i(4, 4), "atlas": Vector2i(1, 1)},
		{"cell": Vector2i(3, 6), "atlas": Vector2i(2, 1)},
		{"cell": Vector2i(3, 8), "atlas": Vector2i(3, 1)},
		{"cell": Vector2i(2, 7), "atlas": Vector2i(0, 2)},
		{"cell": Vector2i(9, 5), "atlas": Vector2i(1, 2)},
		{"cell": Vector2i(11, 4), "atlas": Vector2i(2, 2)},
		{"cell": Vector2i(10, 7), "atlas": Vector2i(3, 2)},
		{"cell": Vector2i(12, 4), "atlas": Vector2i(3, 2)},
		{"cell": Vector2i(12, 6), "atlas": Vector2i(3, 2)},
		{"cell": Vector2i(14, 3), "atlas": Vector2i(0, 3)},
		{"cell": Vector2i(14, 5), "atlas": Vector2i(1, 3)},
		{"cell": Vector2i(15, 4), "atlas": Vector2i(2, 3)}
	]
	for item in placements:
		layer.set_cell(MAP_ORIGIN + item.cell, 0, item.atlas)


func _populate_monster_slots() -> void:
	var habitats := [
		{"color": Color("#35ddf3"), "cells": [Vector2i(2, 5), Vector2i(3, 7), Vector2i(4, 8), Vector2i(5, 8)]},
		{"color": Color("#98df58"), "cells": [Vector2i(5, 2), Vector2i(6, 2), Vector2i(7, 3), Vector2i(8, 3), Vector2i(5, 4), Vector2i(6, 5), Vector2i(7, 6), Vector2i(8, 6), Vector2i(5, 7), Vector2i(6, 7), Vector2i(7, 2), Vector2i(8, 5)]},
		{"color": Color("#ffc75e"), "cells": [Vector2i(9, 2), Vector2i(10, 3), Vector2i(11, 3), Vector2i(12, 4), Vector2i(9, 6), Vector2i(10, 6), Vector2i(11, 6), Vector2i(12, 5)]},
		{"color": Color("#c986ff"), "cells": [Vector2i(13, 2), Vector2i(14, 1), Vector2i(15, 3), Vector2i(14, 4), Vector2i(15, 5), Vector2i(13, 4)]}
	]
	for habitat_index in range(habitats.size()):
		var habitat: Dictionary = habitats[habitat_index]
		for local_cell in habitat.cells:
			_monster_slots.append({"cell": MAP_ORIGIN + local_cell, "color": habitat.color, "habitat": habitat_index})


func _create_preview_world(terrain_tileset: TileSet) -> void:
	var view := Node3D.new()
	view.name = "Isometric3DView"
	view.set_script(load(VIEW_SCRIPT_PATH))
	# The retuned face artwork now reaches adjacent cell edges, so this candidate
	# uses no geometric overscan. Other game scenes retain the renderer default.
	view.set("isometric_tile_cover_scale", 1.0)
	var camera := Camera3D.new()
	camera.name = "Camera3D"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 40.0
	view.add_child(camera)
	add_child(view)
	_iso_view = view
	# isometric_3d_view.gd sets its gameplay default during _ready(); this review
	# overview needs enough framing to show every candidate habitat together.
	camera.size = 40.0
	var focus_position := Vector2(
		(float(MAP_ORIGIN.x) + MAP_WIDTH * 0.5) * SQM_PER_TILE * 32.0,
		(float(MAP_ORIGIN.y) + MAP_HEIGHT * 0.5) * SQM_PER_TILE * 32.0
	)
	_player.position = focus_position
	view.call("configure", self)
	for marker in _monster_slots:
		_add_marker(view, marker)
	for layer_name in ["BaseTiles", "Transitions", "Paths", "ManualTerrain", "ManualProps", "Actors"]:
		var node := get_node(layer_name) as CanvasItem
		if node != null:
			node.visible = false


func _add_marker(view: Node3D, marker: Dictionary) -> void:
	var cell: Vector2i = marker.cell
	var dot := Sprite3D.new()
	dot.name = "CandidateMonsterSlot_%02d" % _monster_slots.find(marker)
	dot.texture = _marker_texture(marker.color)
	dot.pixel_size = 1.0 / 32.0
	dot.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	dot.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	dot.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	dot.alpha_scissor_threshold = 0.12
	dot.position = Vector3((float(cell.x) + 0.5) * SQM_PER_TILE, 0.32, (float(cell.y) + 0.5) * SQM_PER_TILE)
	view.add_child(dot)


func _marker_texture(color: Color) -> Texture2D:
	var key := color.to_html()
	if _marker_textures.has(key):
		return _marker_textures[key]
	var image := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	for y in range(16):
		for x in range(16):
			var distance := Vector2(float(x) + 0.5 - 8.0, float(y) + 0.5 - 8.0).length()
			if distance <= 7.5:
				image.set_pixel(x, y, Color("#102433"))
			if distance <= 5.5:
				image.set_pixel(x, y, color)
	var texture := ImageTexture.create_from_image(image)
	_marker_textures[key] = texture
	return texture


func _create_legend() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "ReviewLegend"
	add_child(canvas)
	var panel := PanelContainer.new()
	panel.position = Vector2(20, 18)
	panel.custom_minimum_size = Vector2(450, 114)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#081927e8")
	style.border_color = Color("#6fb1c7")
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	panel.add_theme_stylebox_override("panel", style)
	canvas.add_child(panel)
	var label := Label.new()
	label.text = "AMOSTRA DE TILES · CÂMERA 2.5D DO JOGO\n30 alocações candidatas · sem espécie atribuída\nLitoral 4  ·  Floresta 12  ·  Planalto 8  ·  Corrupção 6"
	label.add_theme_color_override("font_color", Color("#eaf7ff"))
	label.add_theme_font_size_override("font_size", 17)
	panel.add_child(label)


func _capture_review_frame(path: String) -> void:
	for _frame in range(3):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var error := image.save_png(path)
	if error != OK:
		push_error("Não foi possível salvar a captura da amostra: %s" % error_string(error))
	get_tree().quit()

