extends RefCounted
## Builds the approved isometric sample tilesets from the repository source sheets.

const TERRAIN_SOURCE_PATH := "res://assets/environments/ilha_cristal_isometric_candidate_v1/ilha_cristal_tileset_isometrico_v1.png"
const PROPS_SOURCE_PATH := "res://assets/environments/ilha_cristal_isometric_candidate_v1/ilha_cristal_elementos_isometricos_v1.png"
const TILE_PIXELS := 128
const TERRAIN_X := [0, 157, 314, 470, 627, 784, 940, 1097, 1254]
const TERRAIN_Y := [0, 156, 306, 462, 619, 785, 936, 1080, 1254]
const PROP_RECTS := [
	[15, 57, 137, 184], [308, 19, 494, 195], [623, 33, 808, 201],
	[159, 399, 299, 513], [955, 410, 1086, 515], [166, 211, 296, 374],
	[493, 236, 617, 373], [10, 204, 148, 377], [929, 935, 1090, 1062],
	[31, 826, 122, 912], [1097, 936, 1254, 1080], [314, 619, 470, 785],
	[11, 1064, 146, 1237], [947, 1065, 1090, 1244], [1102, 1065, 1244, 1244]
]
const PROP_IS_TERRAIN := [false, false, false, false, false, false, false, false, false, false, true, true, false, false, false]
static var _cached_tilesets: Dictionary = {}


static func build() -> Dictionary:
	if not _cached_tilesets.is_empty():
		return _cached_tilesets
	var terrain_texture := load(TERRAIN_SOURCE_PATH) as Texture2D
	var props_texture := load(PROPS_SOURCE_PATH) as Texture2D
	if terrain_texture == null or props_texture == null:
		push_error("Tileset da Ilha do Cristal: não foi possível carregar as pranchas-fonte versionadas.")
		return {}
	var terrain_sheet := terrain_texture.get_image()
	var props_sheet := props_texture.get_image()
	if terrain_sheet.is_empty() or props_sheet.is_empty():
		push_error("Tileset da Ilha do Cristal: uma prancha-fonte está vazia.")
		return {}
	var terrain_atlas := Image.create(8 * TILE_PIXELS, 8 * TILE_PIXELS, false, Image.FORMAT_RGBA8)
	var props_atlas := Image.create(4 * TILE_PIXELS, 4 * TILE_PIXELS, false, Image.FORMAT_RGBA8)
	for row in range(8):
		for column in range(8):
			var crop := terrain_sheet.get_region(Rect2i(
				TERRAIN_X[column], TERRAIN_Y[row],
				TERRAIN_X[column + 1] - TERRAIN_X[column],
				TERRAIN_Y[row + 1] - TERRAIN_Y[row]
			))
			var tile := _resize_ground_face(crop) if row < 4 or (row == 7 and column < 4) else _resize_contained(crop, TILE_PIXELS, false)
			terrain_atlas.blit_rect(tile, Rect2i(0, 0, TILE_PIXELS, TILE_PIXELS), Vector2i(column, row) * TILE_PIXELS)
	for index in range(PROP_RECTS.size()):
		var bounds: Array = PROP_RECTS[index]
		var sheet := terrain_sheet if PROP_IS_TERRAIN[index] else props_sheet
		var crop := sheet.get_region(Rect2i(int(bounds[0]), int(bounds[1]), int(bounds[2]) - int(bounds[0]), int(bounds[3]) - int(bounds[1])))
		var tile := _resize_contained(crop, 120, true)
		props_atlas.blit_rect(tile, Rect2i(0, 0, TILE_PIXELS, TILE_PIXELS), Vector2i(index % 4, index / 4) * TILE_PIXELS)
	_cached_tilesets = {
		"terrain": _make_tileset(ImageTexture.create_from_image(terrain_atlas), 8, 8),
		"props": _make_tileset(ImageTexture.create_from_image(props_atlas), 4, 4)
	}
	return _cached_tilesets


static func _make_tileset(texture: Texture2D, columns: int, rows: int) -> TileSet:
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


static func _resize_ground_face(image: Image) -> Image:
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


static func _resize_contained(image: Image, max_size: int, bottom_align: bool) -> Image:
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


static func _clear_alpha_residue(image: Image) -> void:
	image.convert(Image.FORMAT_RGBA8)
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var color := image.get_pixel(x, y)
			if color.a * 255.0 < 12.0:
				image.set_pixel(x, y, Color(0, 0, 0, 0))
