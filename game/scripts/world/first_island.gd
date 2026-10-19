extends Node2D

signal pause_requested
signal interaction_requested
signal ally_revive_started(reviver_id: String, duration_seconds: float)
signal ally_revive_completed(reviver_id: String)
signal ally_revive_cancelled(reviver_id: String)

const LAYOUT_PATH := "res://game/data/first_island_layout.json"
const TILES_PATH := "res://game/data/first_island_tiles.json"
const PLAYER_SCENE := preload("res://game/scenes/player.tscn")
const CANDIDATE_TILESETS = preload("res://game/scripts/world/island_candidate_tileset_builder.gd")
const COMBAT_RULES = preload("res://game/scripts/combat/combat_rules.gd")
const COMBAT_GEOMETRY = preload("res://game/scripts/combat/combat_geometry.gd")
const CREATURE_SCENES := {
	"fox": preload("res://game/scenes/creatures/fox.tscn"),
	"wolf": preload("res://game/scenes/creatures/wolf.tscn"),
	"bear": preload("res://game/scenes/creatures/bear.tscn")
}
const EXPEDITION_STATE = preload("res://game/scripts/save/expedition_state.gd")
const TILE_SIZE := 32
const RESPAWN_PLAYER_RADIUS_SQM := 5.0
const ORTHOGONAL_SIZES := [24.0, 16.0, 12.0, 9.0]
const SAFE_RADIUS := 142.0
const RESOURCE_INTERACTION_RADIUS := 72.0
const CREATURE_SELECT_RADIUS := 42.0
const BASE_ATTACK_INTERVAL := 1.0

var selected_character_id := "melissa"
var selected_vocation_id := "warrior"
var _speed_boost_remaining := 0.0
var _precise_remaining := 0.0
var _burns: Dictionary = {}
var character_name := "Melissa"
var _player
var _iso_view: Node3D
var _hud
var _beacon_position := Vector2.ZERO
var _current_zoom_index := 1
var _layout: Dictionary
var _tile_data: Dictionary
var _state: ExpeditionState
var _resource_nodes: Array[Dictionary] = []
var _creature_actors: Dictionary = {}
var _creature_spawn_specs: Dictionary = {}
var _damage_serial := 0
var _target: CreatureActor
var _auto_attack_enabled := true
var _attack_remaining := 0.0
var _combat_idle_seconds := 8.0
var _hud_remaining := 0.0
var _save_remaining := 120.0
var _bandage_tick_remaining := 0.0
var _bleeds: Dictionary = {}
var _fatal_save_error := false


func _ready() -> void:
	var save_root_override := OS.get_environment("GAMEPLAY_TEST_SAVE_DIR")
	_state = EXPEDITION_STATE.open_for_character(selected_character_id, save_root_override, selected_vocation_id)
	_layout = _load_json(LAYOUT_PATH)
	_tile_data = _load_json(TILES_PATH)
	if _layout.is_empty() or _tile_data.is_empty() or not _configure_island_tiles() or not _validate_tile_layers():
		return
	_build_world_collision()
	_build_beacon()
	_connect_hud()
	_build_minimap()
	if not _state.is_ready():
		_fatal_save_error = true
		_hud.set_status(_state.load_error)
		return
	_build_props()
	_build_gatherables()
	_build_player()
	_build_creatures()
	_change_zoom(_state.zoom_index - _current_zoom_index)
	_iso_view = get_node("Isometric3DView")
	_iso_view.isometric_tile_cover_scale = 1.0
	_iso_view.configure(self)
	_player.set_camera_ground_basis(_iso_view.camera.global_basis)
	for layer_name in ["BaseTiles", "Transitions", "Paths", "ManualTerrain", "ManualProps", "Actors"]:
		get_node(layer_name).visible = false
	_change_zoom(0)
	if not _state.recovered_from.is_empty():
		_hud.set_status("Snapshot recuperado da cópia de segurança. O progresso continua disponível.")
	elif not _state.recent_activity.is_empty():
		_hud.set_status(_state.recent_activity)
	else:
		_hud.set_status("Colete materiais, escolha um alvo e ataque ao se aproximar. Refúgio seguro junto ao cristal.")
	_update_hud()


func _process(delta: float) -> void:
	if _player == null or _state == null or not _state.is_ready():
		return
	var player_position: Vector2 = _player.global_position
	var nearby := _nearest_resource(player_position)
	if not nearby.is_empty():
		_hud.set_interaction_prompt("E · Coletar %s" % _resource_display(str(nearby.resource)), true)
	elif player_position.distance_to(_beacon_position) <= 104.0:
		_hud.set_interaction_prompt("◇ · Descansar", true)
	else:
		_hud.set_interaction_prompt("E · Interagir", false)
	_combat_idle_seconds = minf(
		_combat_idle_seconds + delta,
		COMBAT_RULES.regeneration_out_of_combat_delay_sec()
	)
	_attack_remaining = maxf(0.0, _attack_remaining - delta)
	_speed_boost_remaining = maxf(0.0, _speed_boost_remaining - delta)
	_tick_burns(delta)
	if _precise_remaining > 0.0:
		_precise_remaining = maxf(0.0, _precise_remaining - delta)
		if _precise_remaining == 0.0:
			_fire_precise_shot()
	_state.tick_cooldowns(delta)
	if _state.bandages_in_use:
		_state.tick_bandage(delta)
	if _state.downed_remaining >= 0.0:
		var reviver_id := _state.ally_reviver_id
		var downed_result := _state.tick_downed(delta)
		if downed_result == "revived":
			_player.set_input_enabled(true)
			_set_target(null)
			ally_revive_completed.emit(reviver_id)
			_hud.set_status("Reanimado por um aliado · HP %d / %d. XP e materiais foram mantidos." % [roundi(_state.hp), roundi(_state.max_hp_mp().x)])
			save_progress()
			_update_hud()
		elif downed_result == "expired":
			_return_to_refuge(true)
	if _target != null and is_instance_valid(_target) and _auto_attack_enabled and _target.is_alive:
		if player_basic_attack_can_reach(_target) and _attack_remaining <= 0.0:
			_attack_remaining = BASE_ATTACK_INTERVAL / (1.25 if _speed_boost_remaining > 0.0 else 1.0)
			_perform_basic_attack()
	_state.tick_regeneration(delta, _combat_idle_seconds)
	_tick_bleeds(delta)
	_tick_respawns()
	_save_remaining -= delta
	if _save_remaining <= 0.0 and _state.revision > 0:
		_save_remaining = 120.0
		save_progress()
	_hud_remaining -= delta
	if _hud_remaining <= 0.0:
		_hud_remaining = 0.2
		_update_hud()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_P:
			save_progress()
			pause_requested.emit()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_E:
			interact_with_nearest()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_1:
			_use_skill(COMBAT_RULES.skills_for_vocation(_state.vocation_id)[0])
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_2:
			_use_skill(COMBAT_RULES.skills_for_vocation(_state.vocation_id)[1])
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_3:
			_use_skill(COMBAT_RULES.skills_for_vocation(_state.vocation_id)[2])
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_B:
			_hud.toggle_inventory_from_game()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_H:
			_use_bandage()
			get_viewport().set_input_as_handled()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_select_target_on_screen(event.position)
	if event is InputEventScreenTouch and event.pressed:
		_select_target_on_screen(event.position)


func interact_with_beacon() -> void:
	interact_with_nearest()


func _connect_hud() -> void:
	_hud = get_node("HUD") as CanvasLayer
	_hud.layer = 1
	_hud.set_character_name(character_name)
	_hud.cycle_target_pressed.connect(_cycle_target)
	_hud.pause_pressed.connect(_on_pause_requested)
	_hud.attributes_pressed.connect(_on_attributes_requested)
	_hud.attributes_committed.connect(_on_attributes_committed)
	_hud.interact_pressed.connect(interact_with_nearest)
	_hud.joystick_moved.connect(_set_joystick_vector)
	_hud.zoom_requested.connect(_change_zoom)
	_hud.auto_attack_toggled.connect(func(enabled: bool) -> void: _auto_attack_enabled = enabled)
	_hud.skill_pressed.connect(_use_skill)
	_hud.bandage_pressed.connect(_use_bandage)
	_hud.craft_bandage_pressed.connect(_craft_bandage)
	_hud.upgrade_camp_pressed.connect(_upgrade_camp)
	_hud.respawn_pressed.connect(func() -> void: _return_to_refuge(true))


func _on_attributes_requested() -> void:
	if _state != null and _state.is_ready():
		_hud.open_attributes_for_state(_state)


func _on_attributes_committed(_committed_state: Object) -> void:
	save_progress()
	_update_hud()


func _validate_tile_layers() -> bool:
	var expected_tile_sizes := {
		"BaseTiles": Vector2i(128, 64),
		"Transitions": Vector2i(TILE_SIZE, TILE_SIZE),
		"Paths": Vector2i(TILE_SIZE, TILE_SIZE),
		"ManualTerrain": Vector2i(128, 64),
		"ManualProps": Vector2i(128, 64)
	}
	for layer_name in expected_tile_sizes:
		var layer := get_node_or_null(layer_name) as TileMapLayer
		if layer == null:
			push_error("Camada de terreno ausente na cena: %s" % layer_name)
			return false
		if layer.tile_set == null:
			push_error("Camada de terreno sem TileSet: %s" % layer_name)
			return false
		var expected_tile_size: Vector2i = expected_tile_sizes[layer_name]
		if layer.tile_set.tile_size != expected_tile_size:
			push_error("TileSet incompatível em %s: esperada célula %s." % [layer_name, str(expected_tile_size)])
			return false
	for layer_name in ["BaseTiles", "ManualTerrain", "ManualProps"]:
		var layer := get_node(layer_name) as TileMapLayer
		var atlas_source := layer.tile_set.get_source(0) as TileSetAtlasSource
		if atlas_source == null or atlas_source.texture == null or atlas_source.texture_region_size != Vector2i(128, 128):
			push_error("Atlas tropical inválido em %s: esperado slice 128×128." % layer_name)
			return false
	return true


func _configure_island_tiles() -> bool:
	var tile_sets: Dictionary = CANDIDATE_TILESETS.build()
	var terrain_tileset := tile_sets.get("terrain") as TileSet
	var props_tileset := tile_sets.get("props") as TileSet
	if terrain_tileset == null or props_tileset == null:
		return false
	var grid: Array = _layout.get("grid_size", [])
	var tile_grid: Array = _tile_data.get("tile_grid_size", [])
	var base_tiles: Array = _tile_data.get("base_tiles", [])
	if grid.size() < 2 or tile_grid.size() < 2 or base_tiles.size() != int(tile_grid[0]) * int(tile_grid[1]):
		push_error("Mapa da Ilha do Cristal: dimensões do bake não correspondem ao layout.")
		return false
	if _tile_data.get("grid_size", []) != grid:
		push_error("Mapa da Ilha do Cristal: grid do bake diverge do layout de produção.")
		return false
	var base_layer := get_node("BaseTiles") as TileMapLayer
	base_layer.tile_set = terrain_tileset
	base_layer.clear()
	for index in range(base_tiles.size()):
		var atlas_index := int(base_tiles[index])
		if atlas_index < 0 or atlas_index >= 64:
			push_error("Mapa da Ilha do Cristal: índice de atlas inválido %d na peça %d." % [atlas_index, index])
			return false
		var cell := Vector2i(index % int(tile_grid[0]), int(index / int(tile_grid[0])))
		base_layer.set_cell(cell, 0, Vector2i(atlas_index % 8, int(atlas_index / 8)))
	for layer_name in ["Transitions", "Paths"]:
		var layer := get_node(layer_name) as TileMapLayer
		layer.clear()
	var manual_terrain := get_node("ManualTerrain") as TileMapLayer
	manual_terrain.tile_set = terrain_tileset
	manual_terrain.clear()
	for tile in _layout.get("path_tiles", []):
		if tile.size() < 2:
			continue
		manual_terrain.set_cell(Vector2i(int(tile[0]), int(tile[1])), 0, Vector2i(0, 2))
	var manual_props := get_node("ManualProps") as TileMapLayer
	manual_props.tile_set = props_tileset
	manual_props.clear()
	for placement in _layout.get("prop_placements", []):
		var tile: Array = placement.get("tile", [])
		var atlas_index := int(placement.get("atlas_index", -1))
		if tile.size() < 2 or atlas_index < 0 or atlas_index >= 16:
			push_error("Mapa da Ilha do Cristal: prop inválido no layout: %s" % str(placement))
			return false
		manual_props.set_cell(Vector2i(int(tile[0]), int(tile[1])), 0, Vector2i(atlas_index % 4, int(atlas_index / 4)))
	return true


func _build_world_collision() -> void:
	var outline: Array = _layout.get("island_outline", [])
	if outline.size() >= 3:
		_add_polygon_border(outline, "IslandShoreBoundary", 12.0)
		for index in range(_layout.get("water_polygons", []).size()):
			_add_polygon_border(_layout.water_polygons[index], "LagoonBoundary_%02d" % index, 10.0)
		return
	var size_data: Array = _layout.get("grid_size", [64, 44])
	var map_width := float(size_data[0]) * TILE_SIZE
	var map_height := float(size_data[1]) * TILE_SIZE
	var water_end_cell := 0
	for band in _layout.get("surface_bands", []):
		if str(band.get("group", "")).begins_with("water_"):
			water_end_cell = maxi(water_end_cell, int(band.get("to_x", 0)))
	var blocked_water_width := float(water_end_cell) * TILE_SIZE
	_add_rect_collider(
		Vector2(blocked_water_width * 0.5, map_height * 0.5),
		Vector2(blocked_water_width, map_height),
		"BlockedWater"
	)
	_add_rect_collider(Vector2(-20, map_height * 0.5), Vector2(40, map_height + 80), "WestBoundary")
	_add_rect_collider(
		Vector2(map_width + 20, map_height * 0.5), Vector2(40, map_height + 80), "EastBoundary"
	)
	_add_rect_collider(Vector2(map_width * 0.5, -20), Vector2(map_width + 80, 40), "NorthBoundary")
	_add_rect_collider(
		Vector2(map_width * 0.5, map_height + 20), Vector2(map_width + 80, 40), "SouthBoundary"
	)


func _add_rect_collider(position: Vector2, dimensions: Vector2, label: String) -> void:
	var body := StaticBody2D.new()
	body.name = label
	body.position = position
	body.collision_layer = 1
	body.collision_mask = 1
	var shape_node := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = dimensions
	shape_node.shape = shape
	body.add_child(shape_node)
	add_child(body)


func _add_polygon_border(raw_points: Array, label: String, thickness: float) -> void:
	var points := PackedVector2Array()
	for value in raw_points:
		if value is Array and value.size() >= 2:
			points.append(Vector2(float(value[0]) * TILE_SIZE, float(value[1]) * TILE_SIZE))
	if points.size() < 3:
		push_error("Limite de terreno inválido no mapa: %s" % label)
		return
	for index in range(points.size()):
		var start := points[index]
		var finish := points[(index + 1) % points.size()]
		var segment := finish - start
		if segment.length() < 1.0:
			continue
		var body := StaticBody2D.new()
		body.name = "%s_%02d" % [label, index]
		body.position = (start + finish) * 0.5
		body.rotation = segment.angle()
		body.collision_layer = 1
		body.collision_mask = 1
		var shape_node := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = Vector2(segment.length(), thickness)
		shape_node.shape = shape
		body.add_child(shape_node)
		add_child(body)


func _add_terrain_sprite(parent: Node2D, asset: String, pivot: Vector2) -> void:
	var sprite := Sprite2D.new()
	sprite.name = "PixelArt"
	sprite.texture = load("res://assets/environments/tropical_oblique_candidate/%s.png" % asset)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.centered = false
	sprite.position = -pivot
	parent.add_child(sprite)


func _build_props() -> void:
	var actors := get_node("Actors") as Node2D
	actors.y_sort_enabled = true
	actors.z_index = 3
	for obstacle in _layout.get("obstacles", []):
		var cell: Array = obstacle.get("cell", [0, 0])
		var center := Vector2((int(cell[0]) + 0.5) * TILE_SIZE, (int(cell[1]) + 0.5) * TILE_SIZE)
		var kind := str(obstacle.get("kind", "tree"))
		var node_id := "%s_%d_%d" % [kind, int(cell[0]), int(cell[1])]
		if _state.harvested_nodes.has(node_id):
			continue
		var prop := Node2D.new()
		prop.name = "%s_%d_%d_proxy" % [kind, int(cell[0]), int(cell[1])]
		prop.position = center
		if kind == "tree":
			var coastal := int(cell[0]) < 35
			_add_terrain_sprite(prop, "palm_generated" if coastal else "tree", Vector2(69, 118) if coastal else Vector2(52, 109))
			_add_prop_collider(prop, Vector2(0, 8), Vector2(26, 28), prop.name + "Collision")
			_register_resource_node(prop, node_id, "wood", 15, center)
		else:
			_add_terrain_sprite(prop, "boulder", Vector2(32, 40))
			_add_prop_collider(prop, Vector2(0, 2), Vector2(32, 25), prop.name + "Collision")
			_register_resource_node(prop, node_id, "stone", 15, center)
		actors.add_child(prop)
	for node in _resource_nodes:
		var node_actor: Node2D = node.actor
		if is_instance_valid(node_actor) and node_actor.get_parent() == null:
			actors.add_child(node_actor)


func _add_polygon(parent: Node2D, points: Array, color: Color) -> void:
	var polygon := Polygon2D.new()
	var packed := PackedVector2Array()
	for point in points:
		packed.append(point)
	polygon.polygon = packed
	polygon.color = color
	parent.add_child(polygon)


func _add_prop_collider(parent: Node2D, offset: Vector2, dimensions: Vector2, label: String) -> void:
	var body := StaticBody2D.new()
	body.name = label
	body.position = offset
	body.collision_layer = 1
	body.collision_mask = 1
	var shape_node := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = dimensions
	shape_node.shape = shape
	body.add_child(shape_node)
	parent.add_child(body)


func _register_resource_node(actor: Node2D, node_id: String, resource_id: String, quantity: int, position: Vector2) -> void:
	var resource_data := COMBAT_RULES.entry("resources", resource_id)
	var xp_variant = resource_data.get("xp_per_extraction", 0)
	var xp := int(xp_variant) if xp_variant is int or xp_variant is float else 0
	_resource_nodes.append({
		"id": node_id,
		"resource": resource_id,
		"quantity": quantity,
		"xp": xp,
		"position": position,
		"actor": actor
	})


func _build_gatherables() -> void:
	var actors := get_node("Actors") as Node2D
	for node_data in _layout.get("harvest_nodes", []):
		var node_id := str(node_data.get("id", ""))
		if node_id.is_empty() or _state.harvested_nodes.has(node_id):
			continue
		var cell: Array = node_data.get("cell", [0, 0])
		var position := Vector2((int(cell[0]) + 0.5) * TILE_SIZE, (int(cell[1]) + 0.5) * TILE_SIZE)
		var resource_id := str(node_data.get("resource", ""))
		var plant := Node2D.new()
		plant.name = "Harvest_%s" % node_id
		plant.position = position
		if resource_id == "fiber":
			_add_polygon(plant, [Vector2(-7, 7), Vector2(-4, -7), Vector2(0, 3), Vector2(3, -12), Vector2(8, 8)], Color("63a76b"))
			_add_polygon(plant, [Vector2(-2, 4), Vector2(-14, -4), Vector2(-4, -1)], Color("95cb79"))
			_add_polygon(plant, [Vector2(3, 0), Vector2(14, -8), Vector2(6, 1)], Color("9bd27e"))
		else:
			_add_polygon(plant, [Vector2(0, 10), Vector2(-8, -4), Vector2(-5, -12), Vector2(0, -5)], Color("548b58"))
			_add_polygon(plant, [Vector2(0, 10), Vector2(8, -5), Vector2(5, -12), Vector2(0, -4)], Color("6da85e"))
			_add_polygon(plant, [Vector2(-4, 0), Vector2(0, -10), Vector2(4, 0)], Color("e4d782"))
		actors.add_child(plant)
		_register_resource_node(plant, node_id, resource_id, int(node_data.get("quantity", 1)), position)
	_build_persistent_bags()


func _build_persistent_bags() -> void:
	for bag in _state.persistent_bags:
		if bool(bag.get("claimed", false)):
			continue
		var already_spawned := false
		for node in _resource_nodes:
			if str(node.id) == str(bag.get("id", "")):
				already_spawned = true
				break
		if already_spawned:
			continue
		var bag_node := Node2D.new()
		bag_node.name = "PersistentBag_%s" % str(bag.get("id", "bag"))
		var position_data: Array = bag.get("position", [0.0, 0.0])
		bag_node.position = Vector2(float(position_data[0]), float(position_data[1]))
		_add_polygon(bag_node, [Vector2(-11, -5), Vector2(-7, -12), Vector2(7, -12), Vector2(11, -5), Vector2(8, 10), Vector2(-8, 10)], Color("9c7950"))
		_add_polygon(bag_node, [Vector2(-6, -8), Vector2(0, -15), Vector2(6, -8)], Color("d4b57a"))
		get_node("Actors").add_child(bag_node)
		_resource_nodes.append({
			"id": str(bag.get("id", "")),
			"resource": "persistent_bag",
			"quantity": 0,
			"xp": 0,
			"position": bag_node.position,
			"actor": bag_node
		})


func _build_creatures() -> void:
	for spawn in _layout.get("creature_spawns", []):
		var slot_id := str(spawn.get("id", ""))
		var species_id := str(spawn.get("species", ""))
		var creature_data := COMBAT_RULES.monster(species_id)
		var cell: Array = spawn.get("cell", [0, 0])
		var spawn_position := Vector2((int(cell[0]) + 0.5) * TILE_SIZE, (int(cell[1]) + 0.5) * TILE_SIZE)
		if slot_id.is_empty() or creature_data.is_empty():
			push_error("Ponto de criatura inválido no layout: %s" % str(spawn))
			continue
		_creature_spawn_specs[slot_id] = {"species": species_id, "position": spawn_position}
		var stored := _state.register_actor(slot_id, species_id, float(creature_data.get("hp", 1)), spawn_position)
		if bool(stored.get("alive", true)):
			_spawn_creature(slot_id, creature_data, stored)


func _spawn_creature(slot_id: String, creature_data: Dictionary, stored: Dictionary) -> void:
	var species_id := str(creature_data.get("id", ""))
	var creature_scene := CREATURE_SCENES.get(species_id) as PackedScene
	if creature_scene == null:
		push_error("Cena de criatura ausente para a espécie %s (slot %s)." % [species_id, slot_id])
		return
	var actor := creature_scene.instantiate() as CreatureActor
	if actor == null:
		push_error("A cena da espécie %s não tem CreatureActor na raiz (slot %s)." % [species_id, slot_id])
		return
	actor.name = "Creature_%s" % slot_id
	actor.configure(slot_id, creature_data, _state, _player, _beacon_position, stored, _state.actor_instance_id(slot_id))
	actor.defeated.connect(_on_creature_defeated)
	actor.damage_received.connect(func(amount: float, point: Vector2) -> void: _show_damage(amount, point, false))
	actor.player_damaged.connect(_on_player_damaged)
	actor.feedback_requested.connect(_hud.set_status)
	get_node("Actors").add_child(actor)
	_creature_actors[slot_id] = actor


func _tick_respawns() -> void:
	var now := int(Time.get_unix_time_from_system())
	for slot_id in _creature_spawn_specs:
		var record := _state.current_actor(str(slot_id))
		if record.is_empty() or bool(record.get("alive", false)):
			continue
		if int(record.get("respawn_at", 0)) > now:
			continue
		var spawn_data: Dictionary = _creature_spawn_specs[slot_id]
		var spawn_position: Vector2 = spawn_data.position
		if _is_safe_position(spawn_position) or _player.global_position.distance_to(spawn_position) <= RESPAWN_PLAYER_RADIUS_SQM * TILE_SIZE:
			continue
		var creature_data := COMBAT_RULES.monster(str(spawn_data.species))
		var refreshed := _state.respawn_actor(str(slot_id), float(creature_data.get("hp", 1)), spawn_position)
		_spawn_creature(str(slot_id), creature_data, refreshed)
		_hud.set_status("%s voltou à ilha, longe do jogador." % str(spawn_data.species).capitalize())
		save_progress()


func _position_is_visible(point: Vector2) -> bool:
	return _iso_view == null or _iso_view.is_on_screen(point)


func _nearest_resource(point: Vector2) -> Dictionary:
	var nearest: Dictionary = {}
	var nearest_distance := RESOURCE_INTERACTION_RADIUS
	for node in _resource_nodes:
		var actor: Node2D = node.actor
		if not is_instance_valid(actor):
			continue
		var distance := point.distance_to(actor.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = node
	return nearest


func interact_with_nearest() -> void:
	if _player == null or _state == null or not _state.is_ready() or _state.downed_remaining >= 0.0:
		return
	var nearby := _nearest_resource(_player.global_position)
	if not nearby.is_empty():
		if str(nearby.resource) == "persistent_bag":
			var recovered := _state.claim_persistent_bag(str(nearby.id))
			if recovered.is_empty():
				_hud.set_status("Esta mochila já foi recolhida ou não contém itens.")
			else:
				(nearby.actor as Node2D).queue_free()
				_hud.set_status("Materiais recuperados: %s." % _format_items(recovered))
				save_progress()
			_resource_nodes.erase(nearby)
			return
		var collected := _state.harvest(str(nearby.id), str(nearby.resource), int(nearby.quantity), int(nearby.xp))
		if collected:
			var harvested_actor: Node2D = nearby.actor
			harvested_actor.queue_free()
			_resource_nodes.erase(nearby)
			_hud.set_status("Coletado: %d %s%s." % [int(nearby.quantity), _resource_display(str(nearby.resource)), " · +%d XP" % int(nearby.xp) if int(nearby.xp) > 0 else ""])
			save_progress()
		_update_hud()
		return
	if _player.global_position.distance_to(_beacon_position) <= 104.0:
		if _is_downed():
			return
		var maximum := _state.max_hp_mp()
		_state.hp = maximum.x
		_state.mp = maximum.y
		_state.cancel_bandage()
		_hud.set_status("Cristal puro: HP e MP recuperados. A área está protegida.")
		save_progress()
		_update_hud()
	else:
		_hud.set_status("Aproxime-se de um recurso ou do cristal para interagir.")


func _select_target_on_screen(screen_point: Vector2) -> void:
	if _state == null or not _state.is_ready() or _state.downed_remaining >= 0.0:
		return
	var nearest: CreatureActor
	var nearest_pixels := 52.0
	for value in _creature_actors.values():
		var actor := value as CreatureActor
		if not is_instance_valid(actor) or not actor.is_alive:
			continue
		var target_anchor: Vector3 = _iso_view.world_point(actor.global_position, 1.0)
		var candidate_pixels := screen_point.distance_to(_iso_view.camera.unproject_position(target_anchor))
		if candidate_pixels <= nearest_pixels:
			nearest_pixels = candidate_pixels
			nearest = actor
	if nearest != null:
		_set_target(nearest)


func _select_target_at(point: Vector2) -> void:
	if _state == null or not _state.is_ready() or _state.downed_remaining >= 0.0:
		return
	var nearest: CreatureActor
	var distance := 1.0
	for actor_value in _creature_actors.values():
		var actor := actor_value as CreatureActor
		if not is_instance_valid(actor) or not actor.is_alive:
			continue
		var candidate := actor.selection_distance(point, 32.0 / _iso_view.camera.size)
		if candidate <= distance:
			distance = candidate
			nearest = actor
	if nearest != null:
		_set_target(nearest)


func _set_target(actor: CreatureActor) -> void:
	if is_instance_valid(_target):
		_target.set_selected(false)
	_target = actor
	if is_instance_valid(_target):
		_target.set_selected(true)
		_state.recent_activity = "%s selecionado. Ataque automático ao alcance." % _target.display_name
		_hud.set_status(_state.recent_activity)
	_update_hud()


func _cycle_target() -> void:
	var candidates: Array[CreatureActor] = []
	for value in _creature_actors.values():
		var actor := value as CreatureActor
		if is_instance_valid(actor) and actor.is_alive and _iso_view.is_on_screen(actor.global_position):
			candidates.append(actor)
	candidates.sort_custom(func(a: CreatureActor, b: CreatureActor) -> bool:
		return _player.global_position.distance_squared_to(a.global_position) < _player.global_position.distance_squared_to(b.global_position))
	if candidates.is_empty():
		_hud.set_status("Nenhum monstro visível. Explore a ilha.")
		return
	var index := candidates.find(_target)
	_set_target(candidates[(index + 1) % candidates.size()])


func _show_damage(amount: float, point: Vector2, received: bool) -> void:
	if amount <= 0.0:
		return
	_damage_serial += 1
	var offset := Vector2(float((_damage_serial % 3) - 1) * 22.0, -float(_damage_serial % 2) * 16.0)
	if _iso_view != null and is_instance_valid(_iso_view):
		_iso_view.show_damage(amount, point + offset, received, _damage_serial)


func _perform_basic_attack() -> void:
	if _target == null or not is_instance_valid(_target) or not _target.is_alive or _state.downed_remaining >= 0.0:
		return
	if not player_basic_attack_can_reach(_target):
		return
	if _is_safe_position(_player.global_position):
		_hud.set_status("O cristal protege o refúgio; ataque fora da área segura.")
		return
	if bool(_player.get_meta("combat_invisible", false)):
		_fire_precise_shot()
		return
	_state.cancel_bandage()
	var damage := _state.magic_attack() if _state.vocation_id == "mage" else _state.physical_attack()
	_show_spell_vfx("mag_bolt" if _state.vocation_id == "mage" else "basic", _target.global_position)
	var target := _target
	_mark_combat_activity()
	target.take_hit(damage)
	_hud.set_status("Ataque básico · %d de dano." % roundi(damage))
	_update_hud()


func player_basic_attack_can_reach(actor: CreatureActor) -> bool:
	if _player == null or not is_instance_valid(_player) or not is_instance_valid(actor) or not actor.is_alive:
		return false
	var sword := COMBAT_RULES.weapon(_state.weapon_id())
	var reach_tiles := maxf(0.0, float(sword.get("range_tiles", 1.0)))
	# Preserve the catalogued one-SQM sword reach, measuring from the projected
	# sprite surfaces so larger candidate art does not force visual overlap.
	return COMBAT_GEOMETRY.visual_surface_gap_between(_player, actor) <= reach_tiles * TILE_SIZE


func _use_skill(skill_id: String) -> void:
	if _state == null or not _state.is_ready() or _state.downed_remaining >= 0.0:
		return
	var skill := COMBAT_RULES.skill(skill_id)
	if skill.is_empty() or str(skill.get("vocation", "")) != _state.vocation_id:
		_hud.set_status("Habilidade indisponível para esta vocação.")
		return
	_state.cancel_bandage()
	if _is_safe_position(_player.global_position):
		_hud.set_status("Saia da área protegida pelo cristal para atacar.")
		return
	var cooldown := float(skill.get("cooldown_sec", 0.0))
	var mana_cost := float(skill.get("mp", 0))
	if float(_state.skill_cooldowns.get(skill_id, 0.0)) > 0.0:
		_hud.set_status("Habilidade em recarga.")
		return
	if _state.mp < mana_cost:
		_hud.set_status("Mana insuficiente.")
		return
	if skill_id == "arc_precise":
		_state.mp -= mana_cost
		_state.skill_cooldowns[skill_id] = cooldown
		_precise_remaining = 3.0
		_attack_remaining = 3.0
		_player.set_meta("combat_invisible", true)
		_hud.set_status("Invisível por até 3s; preparando disparo preciso.")
		save_progress()
		_update_hud()
		return
	var targets: Array[CreatureActor] = []
	var target_kind := str(skill.get("target", ""))
	var reach := float(skill.get("range_px", 65.0))
	if target_kind == "single":
		if is_instance_valid(_target) and _target.is_alive and _player.global_position.distance_to(_target.global_position) <= reach:
			targets.append(_target)
	elif target_kind == "line":
		if is_instance_valid(_target) and _target.is_alive:
			var direction: Vector2 = (_target.global_position - _player.global_position).normalized()
			for actor in _actors_in_radius(reach):
				var offset: Vector2 = actor.global_position - _player.global_position
				if offset.dot(direction) >= 0.0 and absf(offset.cross(direction)) <= 26.0:
					targets.append(actor)
	else:
		targets = _actors_in_radius(reach)
		if target_kind == "chain":
			targets.sort_custom(func(a: CreatureActor, b: CreatureActor) -> bool: return _player.global_position.distance_squared_to(a.global_position) < _player.global_position.distance_squared_to(b.global_position))
			if targets.size() > 5:
				targets.resize(5)
	if targets.is_empty():
		_hud.set_status("Nenhum alvo no alcance da habilidade.")
		return
	_precise_remaining = 0.0
	_player.set_meta("combat_invisible", false)
	_state.mp -= mana_cost
	_state.skill_cooldowns[skill_id] = cooldown
	_mark_combat_activity()
	var physical := _state.physical_attack()
	var magical := _state.magic_attack()
	for index in range(targets.size()):
		var actor := targets[index]
		_show_spell_vfx(skill_id, actor.global_position)
		for hit in range(maxi(1, int(skill.get("hits", 1)))):
			if not is_instance_valid(actor) or not actor.is_alive:
				break
			var died := actor.take_hit(COMBAT_RULES.skill_damage(skill, physical, magical, index))
			if not died and is_instance_valid(actor) and actor.is_alive:
				if str(skill.get("status", "")) == "bleed":
					_apply_bleed(actor, physical)
				if str(skill.get("status", "")) == "stun":
					actor.apply_stun(float(skill.get("status_duration_sec", 0)))
				if str(skill.get("status", "")) == "burn":
					_burns[actor.runtime_id] = {"actor": actor, "remaining": 6.0, "tick": 1.0, "damage": magical * 0.05}
	if skill_id == "arc_pierce":
		_speed_boost_remaining = 6.0
	_hud.set_status("%s · %d MP." % [skill_id, int(mana_cost)])
	save_progress()
	_update_hud()


func _actors_in_radius(radius: float) -> Array[CreatureActor]:
	var result: Array[CreatureActor] = []
	for actor_value in _creature_actors.values():
		var actor := actor_value as CreatureActor
		if is_instance_valid(actor) and actor.is_alive and _player.global_position.distance_to(actor.global_position) <= radius:
			result.append(actor)
	return result


func _apply_bleed(actor: CreatureActor, physical_attack: float) -> void:
	var damage_per_second := minf(actor.max_hp * 0.01, physical_attack * 0.2)
	_bleeds[actor.runtime_id] = {"actor": actor, "remaining": 5.0, "tick": 1.0, "damage": damage_per_second}


func _tick_bleeds(delta: float) -> void:
	for runtime_id in _bleeds.keys():
		var effect: Dictionary = _bleeds[runtime_id]
		var actor := effect.actor as CreatureActor
		if not is_instance_valid(actor) or not actor.is_alive:
			_bleeds.erase(runtime_id)
			continue
		effect.remaining = float(effect.remaining) - delta
		effect.tick = float(effect.tick) - delta
		if float(effect.tick) <= 0.0:
			effect.tick = 1.0
			actor.take_hit(float(effect.damage))
		if float(effect.remaining) <= 0.0:
			_bleeds.erase(runtime_id)
		else:
			_bleeds[runtime_id] = effect


func _on_creature_defeated(actor: CreatureActor, death_id: String) -> void:
	if actor == null or not is_instance_valid(actor):
		return
	var rewards := _state.award_creature(death_id, actor.species_id)
	if rewards.is_empty():
		return
	_state.defeat_actor(actor.slot_id)
	_creature_actors.erase(actor.slot_id)
	if _target == actor:
		_target = null
	actor.queue_free()
	var drops: Dictionary = rewards.get("drops", {})
	var feedback := "%s derrotado · +%d XP" % [actor.display_name, int(rewards.get("xp", 0))]
	if not drops.is_empty():
		feedback += " · %s" % _format_items(drops)
	_hud.set_status(feedback)
	save_progress()
	_update_hud()


func _on_player_damaged(amount: float, species_id: String) -> void:
	if _state == null or _state.downed_remaining >= 0.0:
		return
	var actual := _state.take_damage(amount)
	if actual <= 0.0:
		return
	_mark_combat_activity()
	_show_damage(actual, _player.global_position + Vector2(0, -56), true)
	_hud.set_status("%s atingiu você · %d de dano." % [species_id.capitalize(), roundi(actual)])
	if _state.hp <= 0.0:
		_player.set_input_enabled(false)
		_state.cancel_bandage()
		_hud.set_status("Você caiu. Reanimação por aliado: 5 s; prazo: 60 s. No modo solo, renasça no acampamento.")
		save_progress()
	_update_hud()


## API de sessão para o host iniciar a reanimação após validar um aliado.
## O modo solo atual não possui rede, descoberta de peers nem autenticação.
func request_ally_revive(reviver_id: String) -> bool:
	if _state == null or not _state.request_ally_revive(reviver_id):
		return false
	ally_revive_started.emit(_state.ally_reviver_id, EXPEDITION_STATE.ALLY_REVIVE_DURATION_SECONDS)
	_hud.set_status("Um aliado iniciou a reanimação. Aguarde 5 segundos.")
	save_progress()
	_update_hud()
	return true


## Session host calls this when the accepted ally disconnects or leaves range.
func cancel_ally_revive(reviver_id: String) -> bool:
	if _state == null or not _state.cancel_ally_revive(reviver_id):
		return false
	ally_revive_cancelled.emit(reviver_id.strip_edges())
	_hud.set_status("A reanimação foi interrompida. O prazo de 60 s continua.")
	save_progress()
	_update_hud()
	return true


func _use_bandage() -> void:
	if _state == null or not _state.is_ready():
		return
	if _state.start_bandage():
		_hud.set_status("Curativo em uso · 40 HP ao longo de 4 s. Ataques interrompem a cura.")
	else:
		_hud.set_status("Sem curativo ou HP cheio. Fabrique um com 3 ervas e 1 fibra.")
	_update_hud()


func _craft_bandage() -> void:
	if _state.craft("recipe_bandage"):
		_hud.set_status("Curativo fabricado · −3 ervas, −1 fibra · +10 XP na primeira receita.")
		save_progress()
	else:
		_hud.set_status("Faltam 3 ervas e 1 fibra para fabricar o curativo.")
	_update_hud()


func _upgrade_camp() -> void:
	if _player.global_position.distance_to(_beacon_position) > 104.0:
		_hud.set_status("Aproxime-se do cristal para melhorar o acampamento.")
		return
	if _state.upgrade_camp():
		_hud.set_status("Acampamento nível %d · +40 XP." % _state.camp_level)
		save_progress()
	else:
		_hud.set_status("Recursos insuficientes para a melhoria seguinte.")
	_update_hud()


func _return_to_refuge(drop_materials: bool) -> void:
	if _state == null or _player == null or _state.downed_remaining < 0.0:
		return
	if drop_materials:
		var refuge := _beacon_position + Vector2(64.0, 36.0)
		var bag_position: Vector2 = _player.global_position
		var lost := _state.begin_downed_respawn(refuge, bag_position)
		_build_persistent_bags()
		_player.global_position = refuge
		_player.set_input_enabled(true)
		_set_target(null)
		if lost.is_empty():
			_hud.set_status("Você renasceu no acampamento. Nenhum material foi para a mochila; HP e MP foram restaurados. XP e equipamentos permanecem.")
		else:
			_hud.set_status("Você renasceu no acampamento. Mochila persistente: %s. XP e equipamentos permanecem." % _format_items(lost))
		save_progress()
		_update_hud()


func _is_downed() -> bool:
	return _state != null and _state.downed_remaining >= 0.0


func _mark_combat_activity() -> void:
	_combat_idle_seconds = 0.0


func _is_safe_position(point: Vector2) -> bool:
	return point.distance_to(_beacon_position) <= SAFE_RADIUS


func _resource_display(resource_id: String) -> String:
	var labels := {"wood": "madeira", "stone": "pedra", "fiber": "fibra", "herb": "erva", "persistent_bag": "mochila"}
	return str(labels.get(resource_id, resource_id))


func _format_items(items: Dictionary) -> String:
	var labels := {"wood": "madeira", "stone": "pedra", "fiber": "fibra", "herb": "erva", "meat": "carne", "hide": "couro", "fang": "presa", "crystal_shard": "fragmento"}
	var parts: Array[String] = []
	for item_id in items:
		parts.append("%d %s" % [int(items[item_id]), str(labels.get(item_id, item_id))])
	return ", ".join(parts)


func _set_joystick_vector(value: Vector2) -> void:
	if _player != null:
		_player.set_joystick_vector(value)


func _on_pause_requested() -> void:
	save_progress()
	pause_requested.emit()


func save_progress() -> bool:
	if _fatal_save_error or _state == null or not _state.is_ready():
		return false
	if _player != null:
		_state.player_position = _player.global_position
		_state.player_facing = str(_player.facing)
	_state.zoom_index = _current_zoom_index
	for slot_id in _creature_actors:
		var actor := _creature_actors[slot_id] as CreatureActor
		if is_instance_valid(actor):
			actor._sync_state()
	if not _state.save():
		_hud.set_status("Falha ao salvar; confira o espaço disponível. O erro está no log.")
		return false
	return true


func _update_hud() -> void:
	if _hud == null:
		return
	if _hud._minimap != null and _player != null:
		var grid: Array = _layout.get("grid_size", [192, 132])
		_hud._minimap.update_position(_player.global_position, Vector2(float(grid[0]), float(grid[1])) * TILE_SIZE)
		if _iso_view != null and _iso_view.camera != null:
			var camera_view: PackedVector2Array = _iso_view.minimap_camera_view()
			_hud._minimap.set_camera_view(camera_view[0], camera_view[1], camera_view[2])
		var enemies := PackedVector2Array()
		for actor in _creature_actors.values():
			if is_instance_valid(actor) and actor.is_alive:
				enemies.append(actor.global_position)
		_hud._minimap.update_enemies(enemies)
	if _state == null or not _state.is_ready():
		return
	_hud.set_vocation(_state.vocation_id)
	var maximum := _state.max_hp_mp()
	var xp_before_level := 0
	for previous_level in range(1, _state.level):
		xp_before_level += COMBAT_RULES.xp_to_next_level(previous_level)
	var xp_for_level := COMBAT_RULES.xp_to_next_level(_state.level)
	var xp_into_level := maxi(0, _state.total_xp - xp_before_level)
	var target_name := ""
	var target_hp := 0.0
	var target_max_hp := 0.0
	if _target != null and is_instance_valid(_target) and _target.is_alive:
		target_name = _target.display_name
		target_hp = _target.hp
		target_max_hp = _target.max_hp
	_hud.set_combat_state(
		_state.hp, maximum.x, _state.mp, maximum.y, _state.level, xp_into_level, xp_for_level,
		_state.inventory, _state.camp_level, _state.bandages_in_use, _state.bandage_progress,
		target_name, target_hp, target_max_hp, _state.skill_cooldowns
	)
	_hud.set_downed_state(
		_state.downed_remaining, _state.downed_penalty_preview(),
		_state.ally_revive_remaining, _state.ally_reviver_id
	)


func _build_beacon() -> void:
	var cell: Array = _layout.get("beacon_cell", [21, 23])
	_beacon_position = Vector2((int(cell[0]) + 0.5) * TILE_SIZE, (int(cell[1]) + 0.5) * TILE_SIZE)
	var beacon := Node2D.new()
	beacon.name = "CrystalRefuge"
	beacon.position = _beacon_position
	_add_terrain_sprite(beacon, "crystal", Vector2(42, 84))
	get_node("Actors").add_child(beacon)


func _build_player() -> void:
	_player = PLAYER_SCENE.instantiate() as CharacterBody2D
	_player.selected_character_id = selected_character_id
	var initial_position: Vector2 = _state.player_position
	if not _is_walkable_world_position(initial_position):
		var spawn_cell: Array = _layout.get("spawn_cell", [40, 140])
		initial_position = Vector2((float(spawn_cell[0]) + 0.5) * TILE_SIZE, (float(spawn_cell[1]) + 0.5) * TILE_SIZE)
		_state.player_position = initial_position
	_player.position = initial_position
	_player.facing = _state.player_facing
	_player.set_input_enabled(_state.downed_remaining < 0.0)
	_player.name = "LocalPlayer"
	get_node("Actors").add_child(_player)
	get_viewport().size_changed.connect(func() -> void: _change_zoom(0))


func _change_zoom(delta: int) -> void:
	_current_zoom_index = clampi(_current_zoom_index + delta, 0, ORTHOGONAL_SIZES.size() - 1)
	if _iso_view != null and _iso_view.camera != null:
		_iso_view.camera.size = ORTHOGONAL_SIZES[_current_zoom_index]


func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("Dados do mapa ausentes: %s" % path)
		return {}
	var result = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not result is Dictionary:
		push_error("Dados do mapa inválidos: %s" % path)
		return {}
	return result


func _build_minimap() -> void:
	var grid: Array = _layout.get("grid_size", [250, 200])
	var width := int(grid[0])
	var height := int(grid[1])
	var image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	var base_layer := get_node("BaseTiles") as TileMapLayer
	var base_cells_per_tile := maxi(1, int(base_layer.tile_set.tile_size.x / TILE_SIZE))
	for cell in base_layer.get_used_cells():
		var color := _base_minimap_color(base_layer.get_cell_atlas_coords(cell))
		var origin := cell * base_cells_per_tile
		for offset_y in range(base_cells_per_tile):
			for offset_x in range(base_cells_per_tile):
				var minimap_cell := origin + Vector2i(offset_x, offset_y)
				if minimap_cell.x < width and minimap_cell.y < height:
					image.set_pixelv(minimap_cell, color)
	var manual_layer := get_node_or_null("ManualTerrain") as TileMapLayer
	if manual_layer != null and manual_layer.tile_set != null:
		var cells_per_manual_tile := maxi(1, int(manual_layer.tile_set.tile_size.x / TILE_SIZE))
		for cell in manual_layer.get_used_cells():
			var color := _manual_minimap_color(manual_layer.get_cell_atlas_coords(cell))
			if color.a <= 0.0:
				continue
			var origin := cell * cells_per_manual_tile
			for offset_y in range(cells_per_manual_tile):
				for offset_x in range(cells_per_manual_tile):
					var minimap_cell := origin + Vector2i(offset_x, offset_y)
					if minimap_cell.x >= 0 and minimap_cell.y >= 0 and minimap_cell.x < width and minimap_cell.y < height:
						image.set_pixelv(minimap_cell, color)
	_hud._minimap.set_map(ImageTexture.create_from_image(image))
	var allocation_points := PackedVector2Array()
	var allocation_colors := PackedColorArray()
	for allocation in _layout.get("monster_allocations", []):
		var cell: Array = allocation.get("cell", [])
		if cell.size() < 2:
			continue
		allocation_points.append(Vector2((float(cell[0]) + 0.5) * TILE_SIZE, (float(cell[1]) + 0.5) * TILE_SIZE))
		allocation_colors.append(_habitat_color(str(allocation.get("zone", ""))))
	_hud._minimap.set_allocations(allocation_points, allocation_colors)

func _base_minimap_color(atlas_cell: Vector2i) -> Color:
	if atlas_cell.y == 0:
		match atlas_cell.x:
			6:
				return Color("174b75")
			7:
				return Color("37a9bc")
			3:
				return Color("dfc17a")
			2:
				return Color("397c45")
			5:
				return Color("827f7b")
			_:
				return Color("75ab51")
	if atlas_cell.y == 7 and atlas_cell.x < 2:
		return Color("783f90")
	return Color("75ab51")
func _show_spell_vfx(skill_id: String, destination: Vector2) -> void:
	if not is_instance_valid(_iso_view):
		return
	var layer := CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	var effect = preload("res://game/scripts/combat/spell_vfx.gd").new()
	effect.view = _iso_view
	effect.source = _player.global_position
	effect.destination = destination
	effect.skill_id = skill_id
	effect.tree_exited.connect(func() -> void: layer.queue_free())
	layer.add_child(effect)


func _tick_burns(delta: float) -> void:
	for key in _burns.keys():
		var effect: Dictionary = _burns[key]
		var actor := effect.actor as CreatureActor
		if not is_instance_valid(actor) or not actor.is_alive:
			_burns.erase(key)
			continue
		effect.remaining -= delta
		effect.tick -= delta
		if effect.tick <= 0.0:
			effect.tick += 1.0
			actor.take_hit(float(effect.damage))
		if effect.remaining <= 0.0:
			_burns.erase(key)


func _fire_precise_shot() -> void:
	_precise_remaining = 0.0
	_player.set_meta("combat_invisible", false)
	if _state.downed_remaining >= 0.0 or _is_safe_position(_player.global_position):
		return
	if not is_instance_valid(_target) or not _target.is_alive:
		_hud.set_status("Disparo preciso encerrado: selecione um alvo vivo.")
		return
	if _player.global_position.distance_to(_target.global_position) > float(COMBAT_RULES.skill("arc_precise").range_px):
		_hud.set_status("Disparo preciso: alvo fora de alcance.")
		return
	_show_spell_vfx("arc_precise", _target.global_position)
	_target.take_hit(COMBAT_RULES.skill_damage(COMBAT_RULES.skill("arc_precise"), _state.physical_attack(), _state.magic_attack()))
	_mark_combat_activity()
	_attack_remaining = BASE_ATTACK_INTERVAL
	_update_hud()



func _manual_minimap_color(atlas_cell: Vector2i) -> Color:
	if atlas_cell == Vector2i(0, 2):
		return Color("ad8957")
	return Color.TRANSPARENT


func _habitat_color(zone: String) -> Color:
	match zone:
		"coast":
			return Color("35ddf3")
		"forest":
			return Color("98df58")
		"plateau":
			return Color("ffc75e")
		"corruption":
			return Color("c986ff")
	return Color("fff2d1")


func _polygon_from_layout(raw_points: Array) -> PackedVector2Array:
	var polygon := PackedVector2Array()
	for point in raw_points:
		if point is Array and point.size() >= 2:
			polygon.append(Vector2(float(point[0]), float(point[1])))
	return polygon


func _is_walkable_world_position(position: Vector2) -> bool:
	var outline := _polygon_from_layout(_layout.get("island_outline", []))
	if outline.size() < 3:
		return true
	var logical_point := position / float(TILE_SIZE)
	if not Geometry2D.is_point_in_polygon(logical_point, outline):
		return false
	for water in _layout.get("water_polygons", []):
		var polygon := _polygon_from_layout(water)
		if polygon.size() >= 3 and Geometry2D.is_point_in_polygon(logical_point, polygon):
			return false
	return true
