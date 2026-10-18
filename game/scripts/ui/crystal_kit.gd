class_name CrystalKit
extends RefCounted
## Regions in the user's unmodified 1536 x 1024 kit. No baked numbers are used.
## Text encoding permits delivery through the GitHub connector's text API.
const SOURCE := "res://assets/ui/crystal_v2/sheet.b64"
const REGIONS := {
	"panel": Rect2(14, 22, 486, 206),
	"parchment": Rect2(756, 32, 242, 188),
	"button": Rect2(839, 247, 106, 49),
	"confirm": Rect2(18, 246, 143, 55),
	"hover": Rect2(167, 245, 140, 57),
	"pressed": Rect2(311, 247, 123, 53),
	"disabled": Rect2(947, 247, 100, 49),
	"danger": Rect2(571, 247, 142, 54),
	"slot": Rect2(553, 404, 76, 78),
	"slot_selected": Rect2(699, 403, 79, 81),
	"slot_disabled": Rect2(932, 404, 77, 80),
	"hp_frame": Rect2(18, 323, 300, 49),
	"mp_frame": Rect2(18, 375, 300, 47),
	"xp_frame": Rect2(18, 426, 300, 47),
	"hp_fill": Rect2(340, 342, 168, 10),
	"mp_fill": Rect2(340, 391, 160, 12),
	"xp_fill": Rect2(340, 441, 98, 11),
	"enemy_hp_frame": Rect2(18, 323, 300, 49),
	"enemy_hp_fill": Rect2(340, 342, 168, 10),
	"player_frame": Rect2(1191, 385, 155, 151),
	"enemy_frame": Rect2(1191, 385, 155, 151),
	"joystick_ring": Rect2(14, 489, 232, 224),
	"joystick_knob": Rect2(85, 557, 94, 96),
	"attack": Rect2(398, 540, 132, 132),
	"war_combo": Rect2(530, 544, 97, 100),
	"war_circle": Rect2(628, 544, 97, 100),
	"war_quake": Rect2(884, 682, 76, 78),
	"arc_precise": Rect2(721, 765, 78, 77),
	"arc_bounce": Rect2(803, 765, 77, 77),
	"arc_pierce": Rect2(884, 765, 77, 77),
	"mag_bolt": Rect2(721, 845, 78, 79),
	"mag_fire": Rect2(803, 845, 77, 79),
	"mag_ice": Rect2(884, 845, 77, 79),
	"bandage_action": Rect2(847, 549, 60, 65),
	"interact": Rect2(912, 550, 61, 64),
	"bag": Rect2(999, 850, 57, 66),
	"refuge": Rect2(1189, 850, 59, 66),
	"pause": Rect2(1407, 246, 61, 62),
	"target": Rect2(1119, 688, 58, 64),
	"zoom_in": Rect2(1099, 554, 48, 51),
	"zoom_out": Rect2(1154, 554, 48, 51),
	"close": Rect2(1061, 246, 56, 62),
	"back": Rect2(1121, 246, 56, 62),
	"settings": Rect2(1354, 246, 55, 62),
	"save": Rect2(1251, 850, 58, 66),
	"warrior": Rect2(999, 773, 57, 62),
	"archer": Rect2(1062, 773, 57, 62),
	"mage": Rect2(1124, 773, 57, 62),
	"FOR": Rect2(1189, 773, 58, 62),
	"AGI": Rect2(1253, 773, 57, 62),
	"INT": Rect2(1314, 773, 57, 62),
	"wood": Rect2(18, 729, 87, 77),
	"stone": Rect2(108, 729, 76, 77),
	"fiber": Rect2(189, 725, 78, 84),
	"herb": Rect2(270, 725, 82, 84),
	"meat": Rect2(357, 731, 87, 78),
	"hide": Rect2(448, 728, 83, 81),
	"fang": Rect2(536, 726, 70, 83),
	"crystal_shard": Rect2(619, 722, 80, 87),
	"sword_basic": Rect2(14, 815, 78, 83),
	"sword_reinforced": Rect2(96, 815, 71, 83),
	"bow_basic": Rect2(170, 814, 75, 85),
	"bow_reinforced": Rect2(250, 814, 77, 85),
	"staff_basic": Rect2(328, 814, 64, 85),
	"staff_crystal": Rect2(396, 814, 60, 85),
	"axe_basic": Rect2(457, 815, 78, 84),
	"pickaxe_basic": Rect2(538, 815, 78, 84),
	"bandage": Rect2(617, 815, 79, 85),
	"head": Rect2(16, 913, 77, 84),
	"amulet": Rect2(109, 911, 69, 86),
	"chest": Rect2(181, 912, 89, 85),
	"offhand": Rect2(275, 911, 90, 86),
	"jewel_left": Rect2(376, 911, 55, 86),
	"jewel_right": Rect2(376, 911, 55, 86),
	"pants": Rect2(442, 911, 72, 86),
	"boots": Rect2(518, 911, 78, 86),
	"tent": Rect2(1209, 555, 94, 119),
	"workbench": Rect2(1311, 555, 94, 119),
	"palisade": Rect2(1410, 555, 111, 119),
	"lock": Rect2(1010, 406, 76, 77)
	,"toggle_on": Rect2(1178, 326, 68, 44)
	,"toggle_off": Rect2(1251, 326, 68, 44)
	,"slider_track": Rect2(1333, 334, 149, 30)
	,"slider_fill": Rect2(1344, 345, 66, 9)
	,"slider_knob": Rect2(1446, 331, 28, 39)
}
static var _sheet: Image
static var _cache: Dictionary = {}

static func texture(id: String) -> AtlasTexture:
	if id == "main_hand": id = "sword_basic"
	if _cache.has(id): return _cache[id] as AtlasTexture
	if not REGIONS.has(id):
		push_error("Região do kit ausente: %s" % id)
		return null
	if _sheet == null:
		if not FileAccess.file_exists(SOURCE):
			push_error("Kit UI ausente no pacote: %s" % SOURCE)
			return null
		var image := Image.new()
		var error := image.load_png_from_buffer(Marshalls.base64_to_raw(FileAccess.get_file_as_string(SOURCE)))
		if error != OK or image.get_size() != Vector2i(1536, 1024):
			push_error("Kit UI inválido: erro %d, dimensões %s" % [error, image.get_size()])
			return null
		_sheet = image
	var result := AtlasTexture.new()
	# The supplied sheet has an opaque brown backdrop. Remove only exterior
	# pixels reachable from its crop edges and close to its corner backdrop.
	# This is cached once per region; the source stays byte-for-byte intact.
	var cut := _sheet.get_region(Rect2i(REGIONS[id]))
	if not id.ends_with("_fill"):
		_clear_exterior(cut)
	result.atlas = ImageTexture.create_from_image(cut)
	result.region = Rect2(Vector2.ZERO, Vector2(cut.get_size()))
	result.filter_clip = true
	_cache[id] = result
	return result

static func _clear_exterior(image: Image) -> void:
	image.convert(Image.FORMAT_RGBA8)
	var width := image.get_width()
	var height := image.get_height()
	var visited := PackedByteArray()
	visited.resize(width * height)
	var backdrop := image.get_pixel(0, 0)
	var pending := PackedInt32Array()
	for x in width:
		pending.append(x)
		pending.append((height - 1) * width + x)
	for y in height:
		pending.append(y * width)
		pending.append(y * width + width - 1)
	var cursor := 0
	while cursor < pending.size():
		var index := pending[cursor]
		cursor += 1
		if visited[index] != 0: continue
		visited[index] = 1
		var x := index % width
		var y := index / width
		var pixel := image.get_pixel(x, y)
		if Vector3(pixel.r - backdrop.r, pixel.g - backdrop.g, pixel.b - backdrop.b).length() > 0.14: continue
		if pixel.r < pixel.b * 1.25 or pixel.g < pixel.b * 1.1 or pixel.r < pixel.g * 0.95: continue
		image.set_pixel(x, y, Color.TRANSPARENT)
		if x > 0: pending.append(index - 1)
		if x + 1 < width: pending.append(index + 1)
		if y > 0: pending.append(index - width)
		if y + 1 < height: pending.append(index + width)

static func style(id: String, inset := 12.0) -> StyleBoxTexture:
	var box := StyleBoxTexture.new()
	box.texture = texture(id)
	var edge := 28.0 if id in ["panel", "parchment"] else 12.0
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		box.set_texture_margin(side, edge)
		box.set_content_margin(side, inset)
	return box

