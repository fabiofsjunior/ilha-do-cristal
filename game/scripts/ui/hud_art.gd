class_name HudArt
extends RefCounted
const KIT = preload("res://game/scripts/ui/crystal_kit.gd")
## Pixel HUD sheet chosen by the user; immutable source, region-only extraction.
static var _legacy_atlas: Texture2D
const MANIFEST := "res://assets/ui/pixel_hud_v1/regions.json"
static var _data: Dictionary = {}
static var _textures: Dictionary = {}

static func data() -> Dictionary:
	if _data.is_empty():
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST))
		if not parsed is Dictionary or not parsed.has("regions"):
			push_error("HUD atlas manifest invalid: %s" % MANIFEST)
			return {}
		_data = parsed
		for bar in ["hp", "mp", "xp", "enemy_hp"]:
			_data["bar_interiors"][bar] = [39, 15, 236, 19]
	return _data

static func texture(id: String) -> AtlasTexture:
	if id == "bandage": return KIT.texture("bandage_action")
	if KIT.REGIONS.has(id): return KIT.texture(id)
	if _textures.has(id):
		return _textures[id] as AtlasTexture
	var rect: Array = data().get("regions", {}).get(id, [])
	if rect.size() != 4:
		push_error("HUD atlas region missing: %s" % id)
		return null
	var result := AtlasTexture.new()
	if _legacy_atlas == null:
		_legacy_atlas = load("res://assets/ui/pixel_hud_v1/source_sheet.png") as Texture2D
	result.atlas = _legacy_atlas
	result.region = Rect2(float(rect[0]), float(rect[1]), float(rect[2]), float(rect[3]))
	result.filter_clip = true
	_textures[id] = result
	return result


