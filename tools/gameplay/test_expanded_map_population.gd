extends SceneTree
## Expansion regression: 3x linear dimensions, complete terrain and sparse species distribution.

const GAME_SCENE := preload("res://game/scenes/first_island.tscn")
const TILE_SIZE := 32.0
const CHUNK_SIZE := 32
const EXPECTED_GRID := Vector2i(192, 132)
const EXPECTED_SPECIES := {"wolf": 12, "fox": 2, "bear": 4}

var failures := 0


func _initialize() -> void:
	OS.set_environment("GAMEPLAY_TEST_SAVE_DIR", "user://expanded_map_%d" % Time.get_ticks_usec())
	call_deferred("_run")


func _run() -> void:
	var layout := _load_layout()
	if layout.is_empty():
		quit(1)
		return
	_test_layout_dimensions(layout)
	_test_surface_coverage(layout)
	_test_spawn_distribution(layout)
	var game := GAME_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	_test_runtime_world(game)
	game.queue_free()
	await process_frame
	if failures == 0:
		print("PASS expanded map: 64x44 -> 192x132 SQMs (area x9), 12 wolves, 2 foxes, 4 bears; terrain, water barrier, spawn safety, chunk cap and legacy start validated")
	quit(0 if failures == 0 else 1)


func _load_layout() -> Dictionary:
	var file := FileAccess.open("res://game/data/first_island_layout.json", FileAccess.READ)
	if file == null:
		_check(false, "First island layout file could not be opened.")
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		_check(false, "First island layout JSON is invalid.")
		return {}
	return parsed


func _test_layout_dimensions(layout: Dictionary) -> void:
	var size: Array = layout.get("grid_size", [])
	var expansion: Dictionary = layout.get("map_expansion", {})
	var baseline: Array = expansion.get("baseline_grid_size", [])
	_check(size.size() == 2 and int(size[0]) == EXPECTED_GRID.x and int(size[1]) == EXPECTED_GRID.y, "Expanded map must be 192x132 SQMs.")
	_check(baseline.size() == 2 and int(baseline[0]) == 64 and int(baseline[1]) == 44, "Expansion baseline must record the original 64x44 grid.")
	_check(int(expansion.get("linear_multiplier", 0)) == 3, "Expansion must document 3x width and height.")
	_check(int(expansion.get("area_multiplier", 0)) == 9, "Expansion must document a 9x area increase.")
	var spawn: Array = layout.get("spawn_cell", [])
	var beacon: Array = layout.get("beacon_cell", [])
	_check(spawn.size() == 2 and int(spawn[0]) == 16 and int(spawn[1]) == 23, "Legacy player start must remain in its original cell.")
	_check(beacon.size() == 2 and int(beacon[0]) == 21 and int(beacon[1]) == 23, "Legacy refuge must remain in its original cell.")


func _test_surface_coverage(layout: Dictionary) -> void:
	var cells := PackedByteArray()
	cells.resize(EXPECTED_GRID.x * EXPECTED_GRID.y)
	var overlap_count := 0
	var bands: Array = layout.get("surface_bands", [])
	var water_end := 0
	for band in bands:
		var from_x := int(band.get("from_x", -1))
		var to_x := int(band.get("to_x", -1))
		_check(from_x >= 0 and to_x > from_x and to_x <= EXPECTED_GRID.x, "Surface band is out of map bounds.")
		if str(band.get("group", "")).begins_with("water_"):
			water_end = maxi(water_end, to_x)
		for x in range(maxi(0, from_x), mini(EXPECTED_GRID.x, to_x)):
			for y in range(EXPECTED_GRID.y):
				var index := y * EXPECTED_GRID.x + x
				if cells[index] > 0:
					overlap_count += 1
				cells[index] += 1
	_check(overlap_count == 0, "Surface bands must not overlap.")
	_check(cells.count(1) == EXPECTED_GRID.x * EXPECTED_GRID.y, "Terrain bands must cover every map cell.")
	_check(water_end == 8, "The original 8-SQM blocked water strip should be preserved.")
	for area in layout.get("surface_areas", []):
		_check(int(area.get("from_x", -1)) >= 0 and int(area.get("to_x", EXPECTED_GRID.x + 1)) <= EXPECTED_GRID.x, "Biome area is outside map width.")
		_check(int(area.get("from_y", -1)) >= 0 and int(area.get("to_y", EXPECTED_GRID.y + 1)) <= EXPECTED_GRID.y, "Biome area is outside map height.")


func _test_spawn_distribution(layout: Dictionary) -> void:
	var counts := {"wolf": 0, "fox": 0, "bear": 0}
	var ids := {}
	var spawn_cells := {}
	var chunk_counts := {}
	var obstacles := {}
	for obstacle in layout.get("obstacles", []):
		obstacles[Vector2i(int(obstacle.cell[0]), int(obstacle.cell[1]))] = true
	var beacon: Array = layout.get("beacon_cell", [21, 23])
	var beacon_cell := Vector2(float(beacon[0]), float(beacon[1]))
	for spawn in layout.get("creature_spawns", []):
		var slot_id := str(spawn.get("id", ""))
		var species := str(spawn.get("species", ""))
		var cell: Array = spawn.get("cell", [])
		_check(not slot_id.is_empty() and not ids.has(slot_id), "Creature spawn slot IDs must be unique.")
		ids[slot_id] = true
		_check(cell.size() >= 2, "Creature spawn cell must contain x/y.")
		if cell.size() < 2:
			continue
		var position := Vector2i(int(cell[0]), int(cell[1]))
		_check(position.x >= 0 and position.x < EXPECTED_GRID.x and position.y >= 0 and position.y < EXPECTED_GRID.y, "Creature spawn lies outside the map.")
		_check(position.x >= 8, "Creature spawn must be on land beyond the water barrier.")
		_check(not obstacles.has(position), "Creature spawn overlaps a prop collision cell.")
		_check(not spawn_cells.has(position), "Creature spawns must not share a tile.")
		spawn_cells[position] = true
		_check(Vector2(position).distance_to(beacon_cell) > 142.0 / TILE_SIZE, "Monster spawn must stay outside the protected refuge radius.")
		if counts.has(species):
			counts[species] += 1
		else:
			_check(false, "Unexpected species in spawn layout: %s" % species)
		var chunk := Vector2i(position.x / CHUNK_SIZE, position.y / CHUNK_SIZE)
		chunk_counts[chunk] = int(chunk_counts.get(chunk, 0)) + 1
	_check(counts == EXPECTED_SPECIES, "Expected 12 wolves, 2 foxes and 4 bears; found %s." % str(counts))
	_check(counts.wolf > counts.fox + counts.bear, "Wolves should outnumber all other species combined.")
	_check(float(counts.fox) / maxf(1.0, float(ids.size())) <= 0.15, "Fox population must remain below 15 percent.")
	for chunk in chunk_counts:
		_check(int(chunk_counts[chunk]) <= 2, "No 32x32 chunk may hold more than two monsters.")
	_check(chunk_counts.size() >= 12, "Monsters must be distributed across at least 12 map chunks.")


func _test_runtime_world(game: Node) -> void:
	_check(game._creature_actors.size() == 18, "All 18 configured monster slots should spawn in the live world.")
	_check(game._creature_spawn_specs.size() == 18, "Runtime respawn records should cover all configured monsters.")
	var expected_water_width := 8.0 * TILE_SIZE
	var water_body := game.get_node_or_null("BlockedWater")
	var water_collision := water_body.get_child(0) as CollisionShape2D if water_body != null and water_body.get_child_count() > 0 else null
	_check(water_collision != null, "Blocked-water collider should exist in the expanded scene.")
	if water_collision != null and water_collision.shape is RectangleShape2D:
		_check(is_equal_approx((water_collision.shape as RectangleShape2D).size.x, expected_water_width), "Water collision must follow the water band width.")
	var camera_view = game.get_node_or_null("Isometric3DView")
	if camera_view != null:
		_check(camera_view._ground_size == Vector2(EXPECTED_GRID), "Isometric camera and ground bounds must use the expanded dimensions.")
		var expanded_ground := camera_view.get_node_or_null("ExpandedTerrain_BaseTiles") as MeshInstance3D
		_check(expanded_ground != null, "Expanded terrain should be rendered from the tile atlas.")
		if expanded_ground != null and expanded_ground.mesh is ArrayMesh:
			var surface_arrays: Array = (expanded_ground.mesh as ArrayMesh).surface_get_arrays(0)
			var terrain_vertices: PackedVector3Array = surface_arrays[Mesh.ARRAY_VERTEX]
			var expected_tiles := EXPECTED_GRID.x * EXPECTED_GRID.y - 64 * 44
			_check(terrain_vertices.size() == expected_tiles * 4, "Expanded terrain mesh must cover every new tile cell.")
	for actor in game._creature_actors.values():
		_check(actor.global_position.x >= 0.0 and actor.global_position.x < EXPECTED_GRID.x * TILE_SIZE, "Runtime monster x position lies outside world bounds.")
		_check(actor.global_position.y >= 0.0 and actor.global_position.y < EXPECTED_GRID.y * TILE_SIZE, "Runtime monster y position lies outside world bounds.")


func _check(value: bool, message: String) -> void:
	if not value:
		failures += 1
		push_error(message)
