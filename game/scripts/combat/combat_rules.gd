class_name CombatRules
extends RefCounted
## Small catalog-backed combat helpers shared by the world and headless tests.

const CATALOG_PATH := "res://data/catalogs/mvp.json"

static var _catalog_cache: Dictionary = {}


static func catalog() -> Dictionary:
	if not _catalog_cache.is_empty():
		return _catalog_cache
	if not FileAccess.file_exists(CATALOG_PATH):
		push_error("Catálogo de gameplay ausente: %s" % CATALOG_PATH)
		return {}
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(CATALOG_PATH))
	if not parsed is Dictionary:
		push_error("Catálogo de gameplay inválido: %s" % CATALOG_PATH)
		return {}
	_catalog_cache = parsed
	return _catalog_cache


static func entry(collection: String, entry_id: String) -> Dictionary:
	for item in catalog().get(collection, []):
		if str(item.get("id", "")) == entry_id:
			return item
	return {}


static func vocation(vocation_id: String) -> Dictionary:
	return entry("vocations", vocation_id)


static func weapon(weapon_id: String) -> Dictionary:
	return entry("weapons_and_tools", weapon_id)


static func monster(monster_id: String) -> Dictionary:
	return entry("monsters", monster_id)


static func skill(skill_id: String) -> Dictionary:
	return entry("skills", skill_id)


static func recipe(recipe_id: String) -> Dictionary:
	return entry("recipes", recipe_id)


static func xp_to_next_level(level: int) -> int:
	var progression: Dictionary = catalog().get("attributes_and_levels", {})
	var requirements: Array = progression.get("xp_to_next_level_from_1_to_9", [])
	if level < 1 or level > requirements.size():
		return 0
	return int(requirements[level - 1])


static func effective_attributes(raw: Dictionary, vocation_id: String) -> Dictionary:
	var multipliers: Dictionary = vocation(vocation_id).get("stat_multiplier", {})
	return {
		"FOR": float(raw.get("FOR", 0)) * float(multipliers.get("str", 1.0)),
		"AGI": float(raw.get("AGI", 0)) * float(multipliers.get("agi", 1.0)),
		"INT": float(raw.get("INT", 0)) * float(multipliers.get("int", 1.0))
	}


static func max_hp_mp(raw: Dictionary, vocation_id: String) -> Vector2:
	var base: Dictionary = vocation(vocation_id)
	var effects: Dictionary = catalog().get("ui_and_audio", {}).get("inventory_prototype_v0_7", {}).get("attribute_derived_effects", {})
	var effective := effective_attributes(raw, vocation_id)
	var hp_per_point := float(effects.get("FOR", {}).get("max_hp_per_effective_point", 3))
	var mp_per_point := float(effects.get("INT", {}).get("max_mp_per_effective_point", 3))
	return Vector2(
		float(base.get("hp", 0)) + effective.FOR * hp_per_point,
		float(base.get("mp", 0)) + effective.INT * mp_per_point
	)


static func physical_attack(raw: Dictionary, vocation_id: String, weapon_id: String) -> float:
	var weapon_data := weapon(weapon_id)
	var effective := effective_attributes(raw, vocation_id)
	var per_point := float(
		catalog().get("ui_and_audio", {}).get("inventory_prototype_v0_7", {}).get("attribute_derived_effects", {}).get("FOR", {}).get("melee_damage_per_effective_point", 0.6)
	)
	return float(weapon_data.get("damage", 0)) + effective.FOR * per_point


static func magic_attack(raw: Dictionary, vocation_id: String) -> float:
	var effective := effective_attributes(raw, vocation_id)
	var per_point := float(
		catalog().get("ui_and_audio", {}).get("inventory_prototype_v0_7", {}).get("attribute_derived_effects", {}).get("INT", {}).get("magic_damage_per_effective_point", 0.6)
	)
	return effective.INT * per_point


## Returns HP/MP regeneration rates as percent of each maximum per second.
## Combat ends after the catalogued idle delay; the incoming value is the time
## since the last player attack or damage received.
static func regeneration_rates_percent_per_sec(raw: Dictionary, vocation_id: String, seconds_since_combat_activity: float) -> Dictionary:
	var progression: Dictionary = catalog().get("attributes_and_levels", {})
	var regeneration: Dictionary = progression.get("regeneration", {})
	var idle_delay := float(regeneration.get("out_of_combat_delay_sec", 8.0))
	var period := "combat" if seconds_since_combat_activity < idle_delay else "outside_combat"
	var bases: Dictionary = regeneration.get("base_percent_per_sec", {})
	var bonuses: Dictionary = regeneration.get("effective_attribute_bonus_percentage_points_per_sec", {})
	var effective := effective_attributes(raw, vocation_id)
	var result := {}
	for resource_id in ["hp", "mp"]:
		var vocation_rates: Dictionary = bases.get(resource_id, {}).get(vocation_id, {})
		var rate := float(vocation_rates.get(period, 0.0))
		var attribute_id := "FOR" if resource_id == "hp" else "INT"
		var attribute_bonus: Dictionary = bonuses.get(attribute_id, {})
		rate += float(effective.get(attribute_id, 0.0)) * float(attribute_bonus.get(period, 0.0))
		var cap_key := "%s_regen_cap_%s_combat_percent_per_sec" % [resource_id, "outside" if period == "outside_combat" else "inside"]
		var cap_fallback := 1.0 if period == "outside_combat" else 0.25
		if resource_id == "hp":
			cap_fallback = 2.0 if period == "outside_combat" else 0.5
		var cap := float(progression.get(cap_key, cap_fallback))
		result[resource_id] = minf(maxf(rate, 0.0), cap)
	return result


static func regeneration_out_of_combat_delay_sec() -> float:
	var progression: Dictionary = catalog().get("attributes_and_levels", {})
	var regeneration: Dictionary = progression.get("regeneration", {})
	return maxf(0.0, float(regeneration.get("out_of_combat_delay_sec", 8.0)))


## Pure resource update, also used by tests and the attributes preview.
static func regenerated_resources(raw: Dictionary, vocation_id: String, seconds_since_combat_activity: float, current_hp: float, current_mp: float, maximum_hp: float, maximum_mp: float, delta: float) -> Dictionary:
	var rates := regeneration_rates_percent_per_sec(raw, vocation_id, seconds_since_combat_activity)
	var safe_delta := maxf(delta, 0.0)
	var hp_gain := maxf(maximum_hp, 0.0) * float(rates.get("hp", 0.0)) * 0.01 * safe_delta
	var mp_gain := maxf(maximum_mp, 0.0) * float(rates.get("mp", 0.0)) * 0.01 * safe_delta
	var next_hp := clampf(current_hp + hp_gain, 0.0, maxf(maximum_hp, 0.0))
	var next_mp := clampf(current_mp + mp_gain, 0.0, maxf(maximum_mp, 0.0))
	return {
		"hp": next_hp,
		"mp": next_mp,
		"hp_gained": next_hp - current_hp,
		"mp_gained": next_mp - current_mp,
		"rates": rates
	}
