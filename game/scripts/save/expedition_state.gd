class_name ExpeditionState
extends RefCounted
## Single-player world snapshot with checksummed temp, active and previous slots.

const SCHEMA_VERSION := 1
const MONSTER_RESPAWN_SECONDS := 15
const DOWNED_DURATION_SECONDS := 60.0
const ALLY_REVIVE_DURATION_SECONDS := 5.0
const ALLY_REVIVE_HP_FRACTION := 0.30
const DEFAULT_SAVE_ROOT := "user://worlds/solo"
const APPEARANCE_IDS := ["melissa", "helena", "maira", "fabio"]

var character_id := "melissa"
var vocation_id := "warrior"
var world_id := ""
var revision := 0
var loaded := false
var load_error := ""
var recovered_from := ""
var save_root := DEFAULT_SAVE_ROOT
var active_pointer_root := DEFAULT_SAVE_ROOT
var player_position := Vector2.ZERO
var player_facing := "S"
var zoom_index := 1
var hp := 200.0
var mp := 100.0
var level := 1
var total_xp := 0
var available_attribute_points := 0
var raw_attributes := {"FOR": 0, "AGI": 0, "INT": 0}
var inventory := {"sword_basic": 1}
var harvested_nodes: Dictionary = {}
var actors: Dictionary = {}
var rewarded_deaths: Dictionary = {}
var crafted_recipes: Dictionary = {}
var expedition_items: Dictionary = {}
var camp_level := 1
var bandage_progress := 0.0
var bandage_hp_applied := 0.0
var bandage_heal_target := 0.0
var bandages_in_use := false
var skill_cooldowns: Dictionary = {}
var downed_remaining := -1.0
var ally_revive_remaining := -1.0
var ally_reviver_id := ""
var persistent_bags: Array[Dictionary] = []
var recent_activity := ""


static func active_character_id(root_override := "") -> String:
	var root_path := str(root_override) if not str(root_override).is_empty() else DEFAULT_SAVE_ROOT
	var pointer_path := root_path.path_join("active_character.txt")
	if FileAccess.file_exists(pointer_path):
		var value := FileAccess.get_file_as_string(pointer_path).strip_edges()
		if APPEARANCE_IDS.has(value):
			return value
	return "melissa"


static func open_for_character(requested_character_id: String, root_override := "") -> ExpeditionState:
	var result := ExpeditionState.new()
	result.character_id = requested_character_id if APPEARANCE_IDS.has(requested_character_id) else "melissa"
	result.world_id = "solo_%s" % result.character_id
	if not str(root_override).is_empty():
		result.save_root = str(root_override)
		result.active_pointer_root = str(root_override)
	else:
		result.save_root = DEFAULT_SAVE_ROOT.path_join(result.character_id)
		result.active_pointer_root = DEFAULT_SAVE_ROOT
	result._load_or_create()
	return result


func is_ready() -> bool:
	return loaded and load_error.is_empty()


func snapshot_path() -> String:
	return save_root.path_join("snapshot.slot.json")


func _candidate_paths() -> Array[String]:
	var paths: Array[String] = [
		save_root.path_join("snapshot.slot.json"),
		save_root.path_join("snapshot.tmp.json"),
		save_root.path_join("snapshot.previous.json")
	]
	var directory := DirAccess.open(save_root)
	if directory != null:
		directory.list_dir_begin()
		var filename := directory.get_next()
		while not filename.is_empty():
			if filename.begins_with("snapshot.archive.") and filename.ends_with(".json"):
				paths.append(save_root.path_join(filename))
			filename = directory.get_next()
		directory.list_dir_end()
	return paths


func _load_or_create() -> void:
	var existing := false
	var candidates: Array[Dictionary] = []
	for path in _candidate_paths():
		if not FileAccess.file_exists(path):
			continue
		existing = true
		var parsed := _read_snapshot(path)
		if parsed.ok:
			candidates.append({"path": path, "envelope": parsed.envelope})
		else:
			push_warning("Snapshot ignorado (%s): %s" % [path, parsed.error])
	if candidates.is_empty():
		if existing:
			load_error = "Não foi possível validar os slots de save em %s; o progresso foi preservado." % save_root
			push_error(load_error)
			return
		_initialize_new()
		loaded = true
		return
	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.envelope.get("revision", 0)) > int(b.envelope.get("revision", 0))
	)
	var selected: Dictionary = candidates[0]
	var payload: Dictionary = selected.envelope.get("payload", {})
	if int(selected.envelope.get("schema_version", -1)) != SCHEMA_VERSION:
		load_error = "Schema de save incompatível em %s." % selected.path
		push_error(load_error)
		return
	if str(payload.get("character_id", character_id)) != character_id:
		load_error = "O slot em %s pertence a outra aparência; o progresso foi preservado." % selected.path
		push_error(load_error)
		return
	_apply_payload(payload)
	revision = int(selected.envelope.get("revision", 0))
	loaded = true
	if str(selected.path) != snapshot_path():
		recovered_from = str(selected.path)
		push_warning("Save recuperado do slot válido: %s" % recovered_from)


func _initialize_new() -> void:
	var spawn_cell: Array = [16, 23]
	var layout_path := "res://game/data/first_island_layout.json"
	if FileAccess.file_exists(layout_path):
		var layout = JSON.parse_string(FileAccess.get_file_as_string(layout_path))
		if layout is Dictionary:
			spawn_cell = layout.get("spawn_cell", spawn_cell)
	player_position = Vector2((int(spawn_cell[0]) + 0.5) * 32.0, (int(spawn_cell[1]) + 0.5) * 32.0)
	var base := CombatRules.max_hp_mp(raw_attributes, vocation_id)
	hp = base.x
	mp = base.y
	inventory = {"sword_basic": 1}
	harvested_nodes = {}
	actors = {}
	rewarded_deaths = {}
	camp_level = 1
	level = 1
	total_xp = 0
	available_attribute_points = 0


func _read_snapshot(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"ok": false, "error": "falha ao abrir (%s)" % error_string(FileAccess.get_open_error())}
	var text := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if not parsed is Dictionary:
		return {"ok": false, "error": "JSON inválido"}
	var envelope: Dictionary = parsed
	if not envelope.get("payload") is Dictionary:
		return {"ok": false, "error": "payload ausente"}
	var expected := str(envelope.get("checksum_sha256", ""))
	var actual := _checksum(JSON.stringify(_canonicalize(envelope.payload)))
	if expected.is_empty() or expected.to_lower() != actual:
		return {"ok": false, "error": "checksum SHA-256 divergente"}
	return {"ok": true, "envelope": envelope}


func _apply_payload(payload: Dictionary) -> void:
	character_id = str(payload.get("character_id", character_id))
	vocation_id = str(payload.get("vocation_id", "warrior"))
	world_id = str(payload.get("world_id", "solo_%s" % character_id))
	var position_data: Array = payload.get("player_position", [528.0, 752.0])
	player_position = Vector2(float(position_data[0]), float(position_data[1]))
	player_facing = str(payload.get("player_facing", "S"))
	zoom_index = clampi(int(payload.get("zoom_index", 1)), 0, 3)
	level = clampi(int(payload.get("level", 1)), 1, 10)
	total_xp = maxi(0, int(payload.get("total_xp", 0)))
	available_attribute_points = maxi(0, int(payload.get("available_attribute_points", 0)))
	var raw: Dictionary = payload.get("raw_attributes", {})
	raw_attributes = {"FOR": int(raw.get("FOR", 0)), "AGI": int(raw.get("AGI", 0)), "INT": int(raw.get("INT", 0))}
	var base := CombatRules.max_hp_mp(raw_attributes, vocation_id)
	hp = clampf(float(payload.get("hp", base.x)), 0.0, base.x)
	mp = clampf(float(payload.get("mp", base.y)), 0.0, base.y)
	inventory = _int_dictionary(payload.get("inventory", {"sword_basic": 1}))
	harvested_nodes = payload.get("harvested_nodes", {}).duplicate(true)
	actors = payload.get("actors", {}).duplicate(true)
	rewarded_deaths = payload.get("rewarded_deaths", {}).duplicate(true)
	crafted_recipes = payload.get("crafted_recipes", {}).duplicate(true)
	expedition_items = _int_dictionary(payload.get("expedition_items", {}))
	camp_level = clampi(int(payload.get("camp_level", 1)), 1, 3)
	bandage_progress = maxf(0.0, float(payload.get("bandage_progress", 0.0)))
	bandage_hp_applied = maxf(0.0, float(payload.get("bandage_hp_applied", 0.0)))
	bandage_heal_target = maxf(0.0, float(payload.get("bandage_heal_target", 0.0)))
	bandages_in_use = bool(payload.get("bandages_in_use", false))
	skill_cooldowns = payload.get("skill_cooldowns", {}).duplicate(true)
	downed_remaining = float(payload.get("downed_remaining", -1.0))
	# A save cannot restore an in-progress ally action after the peer disconnects.
	ally_revive_remaining = -1.0
	ally_reviver_id = ""
	persistent_bags = []
	for bag in payload.get("persistent_bags", []):
		if bag is Dictionary:
			persistent_bags.append(bag.duplicate(true))
	recent_activity = str(payload.get("recent_activity", ""))


func _payload() -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"world_id": world_id,
		"character_id": character_id,
		"vocation_id": vocation_id,
		"player_position": [player_position.x, player_position.y],
		"player_facing": player_facing,
		"zoom_index": zoom_index,
		"hp": hp,
		"mp": mp,
		"level": level,
		"total_xp": total_xp,
		"available_attribute_points": available_attribute_points,
		"raw_attributes": raw_attributes,
		"inventory": inventory,
		"harvested_nodes": harvested_nodes,
		"actors": actors,
		"rewarded_deaths": rewarded_deaths,
		"crafted_recipes": crafted_recipes,
		"expedition_items": expedition_items,
		"camp_level": camp_level,
		"bandage_progress": bandage_progress,
		"bandage_hp_applied": bandage_hp_applied,
		"bandage_heal_target": bandage_heal_target,
		"bandages_in_use": bandages_in_use,
		"skill_cooldowns": skill_cooldowns,
		"downed_remaining": downed_remaining,
		"persistent_bags": persistent_bags,
		"recent_activity": recent_activity
	}


func save() -> bool:
	if not is_ready():
		push_error("Save recusado: estado não carregado (%s)." % load_error)
		return false
	var directory := ProjectSettings.globalize_path(save_root)
	var create_error := DirAccess.make_dir_recursive_absolute(directory)
	if create_error != OK:
		push_error("Não foi possível criar diretório de save %s: %s" % [directory, error_string(create_error)])
		return false
	var payload := _payload()
	var next_revision := revision + 1
	var envelope := {
		"schema_version": SCHEMA_VERSION,
		"revision": next_revision,
		"checksum_sha256": _checksum(JSON.stringify(_canonicalize(payload))),
		"payload": payload
	}
	var active_path := snapshot_path()
	var temp_path := save_root.path_join("snapshot.tmp.json")
	var previous_path := save_root.path_join("snapshot.previous.json")
	var file := FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		push_error("Não foi possível abrir snapshot temporário %s: %s" % [temp_path, error_string(FileAccess.get_open_error())])
		return false
	file.store_string(JSON.stringify(envelope, "\t"))
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		push_error("Falha ao gravar snapshot temporário %s: %s" % [temp_path, error_string(write_error)])
		return false
	var verified := _read_snapshot(temp_path)
	if not verified.ok or int(verified.envelope.get("revision", -1)) != next_revision:
		push_error("Snapshot temporário não passou na verificação: %s" % str(verified.get("error", "revisão incorreta")))
		return false
	var active_check := _read_snapshot(active_path) if FileAccess.file_exists(active_path) else {"ok": false}
	if active_check.ok:
		if FileAccess.file_exists(previous_path):
			# The verified temporary snapshot and active slot remain intact during rotation.
			var rotation_error := DirAccess.remove_absolute(ProjectSettings.globalize_path(previous_path))
			if rotation_error != OK:
				push_error("Não foi possível rotacionar o slot anterior %s: %s" % [previous_path, error_string(rotation_error)])
				return false
		var rename_previous := DirAccess.rename_absolute(
			ProjectSettings.globalize_path(active_path), ProjectSettings.globalize_path(previous_path)
		)
		if rename_previous != OK:
			push_error("Não foi possível preservar o slot anterior: %s" % error_string(rename_previous))
			return false
	elif FileAccess.file_exists(active_path):
		var preserved_corrupt := save_root.path_join("snapshot.invalid.%d.json" % Time.get_unix_time_from_system())
		var quarantine_error := DirAccess.rename_absolute(
			ProjectSettings.globalize_path(active_path), ProjectSettings.globalize_path(preserved_corrupt)
		)
		if quarantine_error != OK:
			push_error("Não foi possível preservar o slot inválido antes da gravação: %s" % error_string(quarantine_error))
			return false
	var rename_active := DirAccess.rename_absolute(
		ProjectSettings.globalize_path(temp_path), ProjectSettings.globalize_path(active_path)
	)
	if rename_active != OK:
		push_error("Não foi possível promover snapshot temporário para slot ativo: %s" % error_string(rename_active))
		return false
	revision = next_revision
	var pointer_error := _write_active_character()
	if pointer_error != OK:
		push_error("Snapshot salvo, mas não foi possível atualizar a aparência recente: %s" % error_string(pointer_error))
		return false
	return true


func _write_active_character() -> Error:
	var pointer_path := active_pointer_root.path_join("active_character.txt")
	var directory := ProjectSettings.globalize_path(active_pointer_root)
	var mkdir_error := DirAccess.make_dir_recursive_absolute(directory)
	if mkdir_error != OK:
		return mkdir_error
	var temporary := pointer_path + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(character_id)
	file.flush()
	var file_error := file.get_error()
	file.close()
	if file_error != OK:
		return file_error
	var absolute_target := ProjectSettings.globalize_path(pointer_path)
	if FileAccess.file_exists(pointer_path):
		var remove_error := DirAccess.remove_absolute(absolute_target)
		if remove_error != OK:
			return remove_error
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary), absolute_target)


func max_hp_mp() -> Vector2:
	return CombatRules.max_hp_mp(raw_attributes, vocation_id)


func physical_attack() -> float:
	return CombatRules.physical_attack(raw_attributes, vocation_id, "sword_basic")


func magic_attack() -> float:
	return CombatRules.magic_attack(raw_attributes, vocation_id)


func harvest(node_id: String, resource_id: String, quantity: int, xp: int) -> bool:
	if not is_ready() or harvested_nodes.has(node_id) or quantity <= 0:
		return false
	harvested_nodes[node_id] = true
	_add_inventory(resource_id, quantity)
	expedition_items[resource_id] = int(expedition_items.get(resource_id, 0)) + quantity
	add_xp(xp)
	recent_activity = "+%d %s" % [quantity, resource_id]
	return true


func craft(recipe_id: String) -> bool:
	if not is_ready():
		return false
	var recipe_data := CombatRules.recipe(recipe_id)
	if recipe_data.is_empty():
		push_error("Receita ausente no catálogo: %s" % recipe_id)
		return false
	var requirements: Dictionary = recipe_data.get("requires", {})
	var output_id := str(recipe_data.get("output", ""))
	if output_id.is_empty():
		push_error("Receita sem saída: %s" % recipe_id)
		return false
	for item_id in requirements:
		if amount(str(item_id)) < int(requirements[item_id]):
			return false
	for item_id in requirements:
		_consume_inventory(str(item_id), int(requirements[item_id]))
	_add_inventory(output_id, 1)
	if not crafted_recipes.has(recipe_id):
		crafted_recipes[recipe_id] = true
		add_xp(10)
	recent_activity = "Curativo fabricado."
	return true


func start_bandage() -> bool:
	if not is_ready() or bandages_in_use or hp <= 0.0 or amount("bandage") <= 0:
		return false
	var bandage_data := CombatRules.entry("consumables", "bandage")
	if bandage_data.is_empty():
		push_error("Curativo ausente no catálogo.")
		return false
	var max_values := max_hp_mp()
	bandage_heal_target = minf(float(bandage_data.get("healing_hp", 0)), max_values.x - hp)
	if bandage_heal_target <= 0.0:
		return false
	_consume_inventory("bandage", 1)
	bandages_in_use = true
	bandage_progress = 0.0
	bandage_hp_applied = 0.0
	return true


func tick_bandage(delta: float) -> float:
	if not bandages_in_use:
		return 0.0
	var data := CombatRules.entry("consumables", "bandage")
	var duration := maxf(0.01, float(data.get("duration_sec", 4)))
	bandage_progress = minf(duration, bandage_progress + delta)
	var desired := bandage_heal_target * bandage_progress / duration
	var recovered := maxf(0.0, desired - bandage_hp_applied)
	var max_values := max_hp_mp()
	recovered = minf(recovered, max_values.x - hp)
	hp += recovered
	bandage_hp_applied += recovered
	if bandage_progress >= duration:
		bandages_in_use = false
		bandage_progress = 0.0
		bandage_hp_applied = 0.0
		bandage_heal_target = 0.0
	return recovered


func cancel_bandage() -> bool:
	if not bandages_in_use:
		return false
	bandages_in_use = false
	bandage_progress = 0.0
	bandage_hp_applied = 0.0
	bandage_heal_target = 0.0
	return true


func take_damage(amount_value: float) -> float:
	if amount_value <= 0.0 or hp <= 0.0:
		return 0.0
	cancel_bandage()
	var actual := minf(hp, amount_value)
	hp -= actual
	if hp <= 0.0:
		hp = 0.0
		downed_remaining = DOWNED_DURATION_SECONDS
		ally_revive_remaining = -1.0
		ally_reviver_id = ""
	return actual


func downed_penalty_preview() -> Dictionary:
	var lost: Dictionary = {}
	for item_id in expedition_items:
		var quantity := int(floor(float(expedition_items[item_id]) * 0.5))
		if quantity > 0:
			lost[str(item_id)] = quantity
	return lost


## Entry point for an already-authenticated session/host to begin ally revival.
## This local game has no multiplayer peer validation or transport.
func request_ally_revive(reviver_id: String) -> bool:
	if not is_ready() or downed_remaining <= 0.0 or reviver_id.strip_edges().is_empty():
		return false
	if ally_revive_remaining >= 0.0:
		return false
	ally_reviver_id = reviver_id.strip_edges()
	ally_revive_remaining = ALLY_REVIVE_DURATION_SECONDS
	return true


## Host/session adapter can cancel an accepted action when the ally disconnects.
func cancel_ally_revive(reviver_id: String) -> bool:
	if ally_revive_remaining < 0.0 or ally_reviver_id != reviver_id.strip_edges():
		return false
	_clear_ally_revive()
	return true


## Advance the downed deadline and any accepted five-second revive request.
## Returns "revived", "expired", or "" while waiting.
func tick_downed(delta: float) -> String:
	if downed_remaining < 0.0 or delta <= 0.0:
		return ""
	var elapsed_before_deadline := minf(delta, downed_remaining)
	downed_remaining = maxf(0.0, downed_remaining - delta)
	if ally_revive_remaining >= 0.0:
		ally_revive_remaining = maxf(0.0, ally_revive_remaining - elapsed_before_deadline)
		if ally_revive_remaining <= 0.0:
			var maximum := max_hp_mp()
			hp = maximum.x * ALLY_REVIVE_HP_FRACTION
			downed_remaining = -1.0
			_clear_ally_revive()
			recent_activity = "Um aliado reanimou você."
			return "revived"
	if downed_remaining <= 0.0:
		_clear_ally_revive()
		return "expired"
	return ""


func _clear_ally_revive() -> void:
	ally_revive_remaining = -1.0
	ally_reviver_id = ""


func award_creature(actor_death_id: String, species_id: String) -> Dictionary:
	if not is_ready() or rewarded_deaths.has(actor_death_id):
		return {}
	var monster_data := CombatRules.monster(species_id)
	if monster_data.is_empty():
		push_error("Criatura ausente no catálogo: %s" % species_id)
		return {}
	var drops_received: Dictionary = {}
	for drop in monster_data.get("drops", []):
		var item_id := str(drop.get("item", ""))
		var quantity := int(drop.get("quantity", 0))
		var chance := clampf(float(drop.get("chance", 1.0)), 0.0, 1.0)
		if item_id.is_empty() or quantity <= 0:
			continue
		var deterministic_roll := float(abs(hash("%s:%s" % [actor_death_id, item_id])) % 100000) / 100000.0
		if deterministic_roll < chance:
			_add_inventory(item_id, quantity)
			expedition_items[item_id] = int(expedition_items.get(item_id, 0)) + quantity
			drops_received[item_id] = quantity
	rewarded_deaths[actor_death_id] = {"species": species_id, "drops": drops_received.duplicate(true)}
	add_xp(int(monster_data.get("xp", 0)))
	recent_activity = "%s derrotado · +%d XP" % [species_id.capitalize(), int(monster_data.get("xp", 0))]
	return {"xp": int(monster_data.get("xp", 0)), "drops": drops_received}


func register_actor(slot_id: String, species_id: String, hp_value: float, position: Vector2) -> Dictionary:
	if not actors.has(slot_id):
		actors[slot_id] = {
			"species": species_id,
			"life": 1,
			"hp": hp_value,
			"position": [position.x, position.y],
			"alive": true,
			"respawn_at": 0,
			"provoked": false,
			"attack_remaining": 0.0,
			"windup_remaining": 0.0,
			"stunned_remaining": 0.0
		}
	return actors[slot_id].duplicate(true)


func current_actor(slot_id: String) -> Dictionary:
	return actors.get(slot_id, {}).duplicate(true)


func actor_instance_id(slot_id: String) -> String:
	var record: Dictionary = actors.get(slot_id, {})
	return "%s@%d" % [slot_id, int(record.get("life", 1))]


func update_actor(slot_id: String, hp_value: float, position: Vector2, extra_state: Dictionary = {}) -> void:
	if not actors.has(slot_id):
		return
	actors[slot_id]["hp"] = hp_value
	actors[slot_id]["position"] = [position.x, position.y]
	for key in extra_state:
		actors[slot_id][key] = extra_state[key]


func defeat_actor(slot_id: String) -> void:
	if not actors.has(slot_id):
		return
	actors[slot_id]["hp"] = 0.0
	actors[slot_id]["alive"] = false
	actors[slot_id]["respawn_at"] = int(Time.get_unix_time_from_system()) + MONSTER_RESPAWN_SECONDS


func respawn_actor(slot_id: String, hp_value: float, position: Vector2) -> Dictionary:
	if not actors.has(slot_id):
		return {}
	var record: Dictionary = actors[slot_id]
	record["life"] = int(record.get("life", 1)) + 1
	record["hp"] = hp_value
	record["position"] = [position.x, position.y]
	record["alive"] = true
	record["respawn_at"] = 0
	return record.duplicate(true)


func upgrade_camp() -> bool:
	if not is_ready() or camp_level >= 3:
		return false
	var next_level := camp_level + 1
	var upgrade_data: Dictionary = {}
	for item in CombatRules.catalog().get("camp_upgrades", []):
		if int(item.get("to_level", -1)) == next_level:
			upgrade_data = item
			break
	if upgrade_data.is_empty():
		push_error("Custo de acampamento nível %d ausente no catálogo." % next_level)
		return false
	var requirements: Dictionary = upgrade_data.get("requires", {})
	for item_id in requirements:
		if amount(str(item_id)) < int(requirements[item_id]):
			return false
	for item_id in requirements:
		_consume_inventory(str(item_id), int(requirements[item_id]))
	camp_level = next_level
	add_xp(40)
	recent_activity = "Acampamento nível %d." % camp_level
	return true


func tick_cooldowns(delta: float) -> void:
	for key in skill_cooldowns.keys():
		skill_cooldowns[key] = maxf(0.0, float(skill_cooldowns[key]) - delta)
		if float(skill_cooldowns[key]) <= 0.0:
			skill_cooldowns.erase(key)


func tick_regeneration(delta: float, seconds_since_combat_activity: float) -> Dictionary:
	if not is_ready() or hp <= 0.0 or downed_remaining >= 0.0 or delta <= 0.0:
		return {"hp_gained": 0.0, "mp_gained": 0.0}
	var maximum := max_hp_mp()
	var result := CombatRules.regenerated_resources(
		raw_attributes, vocation_id, seconds_since_combat_activity,
		hp, mp, maximum.x, maximum.y, delta
	)
	hp = float(result.hp)
	mp = float(result.mp)
	return result


func begin_downed_respawn(refuge_position: Vector2, bag_position: Vector2) -> Dictionary:
	if not is_ready() or downed_remaining < 0.0:
		return {}
	var lost := downed_penalty_preview()
	for item_id in lost:
		_consume_inventory(str(item_id), int(lost[item_id]))
	if not lost.is_empty():
		persistent_bags.append({
			"id": "downed_bag_%d" % persistent_bags.size(),
			"position": [bag_position.x, bag_position.y],
			"items": lost,
			"claimed": false
		})
	expedition_items.clear()
	var maximum := max_hp_mp()
	hp = maximum.x
	mp = maximum.y
	downed_remaining = -1.0
	_clear_ally_revive()
	bandages_in_use = false
	bandage_progress = 0.0
	bandage_hp_applied = 0.0
	bandage_heal_target = 0.0
	player_position = refuge_position
	recent_activity = "Você voltou à barraca; a mochila mantém metade dos materiais coletados."
	return lost


func claim_persistent_bag(bag_id: String) -> Dictionary:
	for bag in persistent_bags:
		if str(bag.get("id", "")) == bag_id and not bool(bag.get("claimed", false)):
			var items: Dictionary = bag.get("items", {}).duplicate(true)
			for item_id in items:
				_add_inventory(str(item_id), int(items[item_id]))
			bag["claimed"] = true
			bag["items"] = {}
			recent_activity = "Materiais recuperados da mochila persistente."
			return items
	return {}


func _add_inventory(item_id: String, quantity: int) -> void:
	inventory[item_id] = amount(item_id) + quantity


func _consume_inventory(item_id: String, quantity: int) -> void:
	var remaining := maxi(0, amount(item_id) - quantity)
	if remaining <= 0:
		inventory.erase(item_id)
	else:
		inventory[item_id] = remaining
	var expedition_count := maxi(0, int(expedition_items.get(item_id, 0)) - quantity)
	if expedition_count == 0:
		expedition_items.erase(item_id)
	else:
		expedition_items[item_id] = expedition_count


func add_xp(amount: int) -> void:
	if amount <= 0:
		return
	total_xp += amount
	while level < 10:
		var earned_before_level := 0
		for index in range(level - 1):
			earned_before_level += CombatRules.xp_to_next_level(index + 1)
		var next_required := CombatRules.xp_to_next_level(level)
		if next_required <= 0 or total_xp - earned_before_level < next_required:
			break
		level += 1
		available_attribute_points += int(CombatRules.catalog().get("attributes_and_levels", {}).get("attribute_points_per_level_up", 1))
		var resource_max := max_hp_mp()
		hp = resource_max.x
		mp = resource_max.y
		recent_activity = "Nível %d alcançado." % level


func amount(item_id: String) -> int:
	return int(inventory.get(item_id, 0))


func _int_dictionary(source) -> Dictionary:
	var result := {}
	if source is Dictionary:
		for key in source:
			result[str(key)] = int(source[key])
	return result


func _checksum(value: String) -> String:
	var context := HashingContext.new()
	var start_error := context.start(HashingContext.HASH_SHA256)
	if start_error != OK:
		push_error("Não foi possível iniciar checksum SHA-256: %s" % error_string(start_error))
		return ""
	context.update(value.to_utf8_buffer())
	return context.finish().hex_encode()


func _canonicalize(value: Variant) -> Variant:
	if value is Dictionary:
		var result: Dictionary = {}
		var keys: Array[String] = []
		for key in value.keys():
			keys.append(str(key))
		keys.sort()
		for key in keys:
			result[key] = _canonicalize(value[key])
		return result
	if value is Array:
		var result: Array = []
		for item in value:
			result.append(_canonicalize(item))
		return result
	if typeof(value) == TYPE_FLOAT or typeof(value) == TYPE_INT:
		return "%.3f" % float(value)
	return value
