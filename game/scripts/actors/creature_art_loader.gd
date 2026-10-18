class_name CreatureArtLoader
extends RefCounted
## Loads one unapproved static concept pose; directions and animation stay absent.

const SPECIES := [
	"fox", "wolf", "bear", "tidal_fox", "crystal_crab", "lumen_heron", "salt_wolf", "root_boar",
	"moss_deer", "prismatic_bear", "violet_vine", "obsidian_sentinel", "corrupted_wanderer",
	"lagoon_crocodile", "coral_turtle", "reef_lizard", "canopy_monkey", "fruit_bat", "root_snake",
	"prismatic_spider", "lumen_frog", "crystal_slime", "obsidian_beetle", "lumen_eel", "turquoise_otter",
	"basalt_gargoyle", "spectral_wolf", "corrupted_treant", "crystal_golem", "violet_serpent"
]
static var _missing_reported: Dictionary = {}


static func metadata_path_for(species_id: String) -> String:
	if not SPECIES.has(species_id):
		push_error("Espécie sem contrato de arte SE: %s" % species_id)
		return ""
	return "res://assets/creatures/%s/%s_static_concept_v0_1.json" % [species_id, species_id]


static func apply_static_pose(sprite: Sprite2D, species_id: String, custom_metadata_path := "") -> bool:
	var path := custom_metadata_path if not custom_metadata_path.is_empty() else metadata_path_for(species_id)
	if path.is_empty() or not FileAccess.file_exists(path):
		if not _missing_reported.has(species_id):
			push_warning("Pose SE candidata ausente para %s (%s); criatura fica sem textura." % [species_id, path])
			_missing_reported[species_id] = true
		return false
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not parsed is Dictionary:
		push_error("Metadata de pose SE inválida: %s" % path)
		return false
	var payload: Dictionary = parsed
	var atlas_data: Dictionary = payload.get("atlas", {})
	var cell: Array = payload.get("cell", [])
	var pivot: Array = payload.get("pivot", [])
	var footprint: Array = payload.get("footprint_extents_px", [])
	var directions: Array = payload.get("directions", [])
	var animations: Dictionary = payload.get("animations", {})
	var idle: Dictionary = animations.get("idle", {})
	if (
		cell.size() < 2
		or pivot.size() < 2
		or footprint.size() < 4
		or directions != ["SE"]
		or int(idle.get("frames", 0)) != 1
		or float(idle.get("fps", 0.0)) != 1.0
		or not bool(idle.get("loop", false))
	):
		push_error("Contrato esperado: pose estática idle de 1 frame, direção SE (%s)." % path)
		return false
	var atlas_file := str(atlas_data.get("file", ""))
	var columns := int(atlas_data.get("columns", 0))
	var rows := int(atlas_data.get("rows", 0))
	if atlas_file.is_empty() or columns < 1 or rows < 1:
		push_error("Metadata de atlas incompleta: %s" % path)
		return false
	var atlas_path := path.get_base_dir().path_join(atlas_file)
	if not ResourceLoader.exists(atlas_path):
		if not _missing_reported.has(species_id):
			push_warning("Atlas de pose SE candidata ausente para %s: %s" % [species_id, atlas_path])
			_missing_reported[species_id] = true
		return false
	var atlas := load(atlas_path) as Texture2D
	if atlas == null:
		push_error("Falha ao importar atlas candidato de %s: %s" % [species_id, atlas_path])
		return false
	var cell_size := Vector2i(int(cell[0]), int(cell[1]))
	var render_scale := float(payload.get("render_scale", 0.0))
	if render_scale <= 0.0:
		push_error("Metadata de pose sem escala de exibição válida: %s" % path)
		return false
	if atlas.get_width() < cell_size.x * columns or atlas.get_height() < cell_size.y * rows:
		push_error("Dimensões do atlas não correspondem à metadata: %s" % path)
		return false
	var texture := AtlasTexture.new()
	texture.atlas = atlas
	texture.region = Rect2(Vector2.ZERO, Vector2(cell_size))
	sprite.texture = texture
	sprite.centered = true
	sprite.offset = Vector2(cell_size.x * 0.5 - float(pivot[0]), cell_size.y * 0.5 - float(pivot[1]))
	sprite.scale = Vector2.ONE * render_scale
	sprite.set_meta(
		"melee_visual_alpha_extents_px",
		Vector4(float(footprint[0]), float(footprint[1]), float(footprint[2]), float(footprint[3]))
	)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	return true

