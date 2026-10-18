extends SceneTree

func _initialize() -> void:
	var file := FileAccess.open("res://game/data/first_island_tiles.json", FileAccess.READ)
	if file == null:
		_fail("Fixed map file missing")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		_fail("Invalid fixed map JSON")
		return
	var fixed: Dictionary = parsed
	var grid: Array = fixed.get("grid_size", [])
	if grid.size() != 2 or Vector2i(int(grid[0]), int(grid[1])) != Vector2i(250, 200):
		_fail("Expected 250x200 fixed grid")
		return
	if int(fixed.get("base_tile_count", 0)) != 50000 or fixed.layers.BaseTiles.size() != 50000:
		_fail("Expected 50000 base tiles")
		return
	for index in fixed.layers.BaseTiles:
		if int(index) < 0 or int(index) >= fixed.palette.size():
			_fail("Tile palette index out of bounds")
			return
	print("PASS fixed map: 50000 authored base tiles, grid and palette valid")
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
