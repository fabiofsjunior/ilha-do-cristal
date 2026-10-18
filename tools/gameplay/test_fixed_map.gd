extends SceneTree
## Verifies the authored TileMapLayers survive startup without being repainted.

const GAME_SCENE := preload("res://game/scenes/first_island.tscn")
const EXPECTED_GRID := Vector2i(250, 200)
const EXPECTED_BASE_CELLS := EXPECTED_GRID.x * EXPECTED_GRID.y
const TILE_SET_PATH := "res://assets/environments/terrain_mvp_candidate_v1/terrain_mvp_candidate_v1.tres"

var failures := 0


func _initialize() -> void:
	OS.set_environment("GAMEPLAY_TEST_SAVE_DIR", "user://fixed_map_%d" % Time.get_ticks_usec())
	call_deferred("_run")


func _run() -> void:
	var game := GAME_SCENE.instantiate()
	var base := game.get_node_or_null("BaseTiles") as TileMapLayer
	var transitions := game.get_node_or_null("Transitions") as TileMapLayer
	var paths := game.get_node_or_null("Paths") as TileMapLayer
	_check(base != null, "Persistent BaseTiles layer is missing.")
	_check(transitions != null, "Persistent Transitions layer is missing.")
	_check(paths != null, "Persistent Paths layer is missing.")
	if failures > 0:
		game.free()
		quit(1)
		return

	_check(base.tile_set != null and base.tile_set.resource_path == TILE_SET_PATH, "BaseTiles must use the shared terrain TileSet resource.")
	_check(base.get_used_cells().size() == EXPECTED_BASE_CELLS, "The scene must persist all 50,000 base cells.")
	_check(transitions.get_used_cells().size() == 645, "The scene must persist all 645 transition cells.")
	_check(paths.get_used_cells().size() == 15, "The scene must persist all 15 path overlay cells.")

	var atlas := base.tile_set.get_source(0) as TileSetAtlasSource
	_check(atlas != null and atlas.get_tiles_count() == 56, "The terrain TileSet must expose all 56 atlas tiles.")
	if atlas == null:
		game.free()
		quit(1)
		return
	for layer_name in ["BaseTiles", "Transitions", "Paths"]:
		var layer := game.get_node(layer_name) as TileMapLayer
		for cell in layer.get_used_cells():
			var atlas_coords := layer.get_cell_atlas_coords(cell)
			_check(layer.get_cell_source_id(cell) == 0 and atlas.has_tile(atlas_coords), "A persisted map cell references a missing atlas tile.")
			if failures > 0:
				break
		if failures > 0:
			break

	# Simulate a manual editor change before the gameplay scene enters the tree.
	var edited_cell := Vector2i(EXPECTED_GRID.x - 1, EXPECTED_GRID.y - 1)
	var edited_atlas_coords := Vector2i(0, 2)
	if base.get_cell_atlas_coords(edited_cell) == edited_atlas_coords:
		edited_atlas_coords = Vector2i(1, 2)
	base.set_cell(edited_cell, 0, edited_atlas_coords)
	root.add_child(game)
	await process_frame
	_check(base.get_cell_source_id(edited_cell) == 0 and base.get_cell_atlas_coords(edited_cell) == edited_atlas_coords, "Scene startup overwrote a manual TileMapLayer edit.")
	game.queue_free()
	await process_frame
	if failures == 0:
		print("PASS persistent map: 50,000 base cells, 645 transitions, 15 paths and editor changes survive gameplay startup")
	quit(0 if failures == 0 else 1)


func _check(value: bool, message: String) -> void:
	if not value:
		failures += 1
		push_error(message)
