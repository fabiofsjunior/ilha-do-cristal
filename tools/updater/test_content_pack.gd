extends SceneTree
## Mounts an exported content PCK and reads its data and texture resources.

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var arguments := OS.get_cmdline_user_args()
	if arguments.is_empty():
		push_error("Pass the exported .pck path after --.")
		quit(2)
		return
	var pack_path := ProjectSettings.globalize_path(str(arguments[0]))
	_check(FileAccess.file_exists(pack_path), "The exported PCK must exist.")
	if failures > 0:
		quit(failures)
		return
	_check(ProjectSettings.load_resource_pack(pack_path, true), "Godot must mount the exported PCK.")
	var catalog_text := FileAccess.get_file_as_string("res://data/catalogs/mvp.json")
	var catalog: Variant = JSON.parse_string(catalog_text)
	_check(typeof(catalog) == TYPE_DICTIONARY, "The PCK must expose the gameplay catalog.")
	var layout_text := FileAccess.get_file_as_string("res://game/data/first_island_layout.json")
	var layout: Variant = JSON.parse_string(layout_text)
	_check(typeof(layout) == TYPE_DICTIONARY, "The PCK must expose the island layout.")
	var tiles_text := FileAccess.get_file_as_string("res://game/data/first_island_tiles.json")
	var tiles: Variant = JSON.parse_string(tiles_text)
	_check(typeof(tiles) == TYPE_DICTIONARY, "The PCK must expose the baked island tiles.")
	var creature_texture := load("res://assets/creatures/fox/fox_se_candidate_v1.png")
	_check(creature_texture is Texture2D, "The PCK must expose an updated creature texture.")
	var crystal_sheet := FileAccess.get_file_as_string("res://assets/ui/crystal_v2/sheet.b64")
	_check(not crystal_sheet.is_empty(), "The PCK must expose the current HUD image sheet.")
	if failures == 0:
		print("Content pack test passed: mount, JSON data, textures and current HUD sheet.")
	quit(failures)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)
