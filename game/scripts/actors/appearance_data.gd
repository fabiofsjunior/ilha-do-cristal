class_name AppearanceData
extends RefCounted

const APPEARANCES_PATH := "res://game/data/player_appearances.json"


static func profiles() -> Array:
	var payload = _read_json(APPEARANCES_PATH)
	if payload is Dictionary and payload.get("characters") is Array:
		return payload.characters
	return []


static func profile_for_id(character_id: String) -> Dictionary:
	for profile in profiles():
		if str(profile.get("id", "")) == character_id:
			return profile
	return {}


static func metadata(metadata_path: String) -> Dictionary:
	var payload = _read_json(metadata_path)
	return payload if payload is Dictionary else {}


static func atlas_path(metadata_path: String, data: Dictionary) -> String:
	var atlas_name := str(data.get("atlas", ""))
	if atlas_name.is_empty():
		push_error("Metadata de aparência sem campo atlas: %s" % metadata_path)
		return ""
	return metadata_path.get_base_dir().path_join(atlas_name)


static func _read_json(path: String):
	if not FileAccess.file_exists(path):
		push_error("Recurso JSON ausente: %s" % path)
		return null
	var text := FileAccess.get_file_as_string(path)
	var result = JSON.parse_string(text)
	if result == null:
		push_error("JSON inválido em %s" % path)
	return result
