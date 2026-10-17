extends Node2D

signal pause_requested
signal interaction_requested

const TILE_MANIFEST_DIR := "res://assets/environments/terrain_mvp_candidate_v1"
const TILE_MANIFEST := TILE_MANIFEST_DIR + "/terrain_mvp_candidate_v1.json"
const LAYOUT_PATH := "res://game/data/first_island_layout.json"
const PLAYER_SCENE := preload("res://game/scenes/player.tscn")
const COMBAT_RULES = preload("res://game/scripts/combat/combat_rules.gd")
const CREATURE_ACTOR = preload("res://game/scripts/combat/creature_actor.gd")
const EXPEDITION_STATE = preload("res://game/scripts/save/expedition_state.gd")
const TILE_SIZE := 32
const ZOOM_LEVELS := [0.5, 0.75, 1.0, 1.25]
const SAFE_RADIUS := 142.0
const RESOURCE_INTERACTION_RADIUS := 72.0
const CREATURE_SELECT_RADIUS := 42.0
const BASE_ATTACK_INTERVAL := 1.0

var selected_character_id := "melissa"
var character_name := "Melissa"
var _player
var _camera: Camera2D
var _hud
var _beacon_position := Vector2.ZERO
var _current_zoom_index := 1
var _layout: Dictionary
var _tile_lookup: Dictionary = {}
var _state: ExpeditionState
var _resource_nodes: Array[Dictionary] = []
var _creature_actors: Dictionary = {}
var _creature_spawn_specs: Dictionary = {}
var _damage_serial := 0
var _target: CreatureActor
var _auto_attack_enabled := true
var _attack_remaining := 0.0
var _hud_remaining := 0.0
var _save_remaining := 120.0
var _bandage_tick_remaining := 0.0
var _bleeds: Dictionary = {}
var _fatal_save_error := false


func _ready() -> void:
	var save_root_override := OS.get_environment("GAMEPLAY_TEST_SAVE_DIR")
	_state = EXPEDITION_STATE.open_for_character(selected_character_id, save_root_override)
	_layout = _load_json(LAYOUT_PATH)
	var manifest := _load_json(TILE_MANIFEST)
	if _layout.is_empty() or manifest.is_empty():
		return
	if not _build_tile_set(manifest):
		return
	_paint_map(manifest)
	_build_world_collision()
	_build_beacon()
	_connect_hud()
	if not _state.is_ready():
		_fatal_save_error = true
		_hud.set_status(_state.load_error)
		return
	_build_props()
	_build_gatherables()
	_build_player()
	_build_creatures()
	_change_zoom(_state.zoom_index - _current_zoom_index)
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
	_attack_remaining = maxf(0.0, _attack_remaining - delta)
	_state.tick_cooldowns(delta)
	if _state.bandages_in_use:
		_state.tick_bandage(delta)
	if _state.downed_remaining >= 0.0:
		_state.downed_remaining = maxf(0.0, _state.downed_remaining - delta)
		if _state.downed_remaining <= 0.0:
			_return_to_refuge(true)
	if _target != null and is_instance_valid(_target) and _auto_attack_enabled and _target.is_alive:
		if _player.global_position.distance_to(_target.global_position) <= 42.0 and _attack_remaining <= 0.0:
			_attack_remaining = BASE_ATTACK_INTERVAL
			_perform_basic_attack()
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
			_use_skill("war_combo")
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_2:
			_use_skill("war_circle")
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_3:
			_use_skill("war_quake")
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_B:
			_hud.toggle_inventory_from_game()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_H:
			_use_bandage()
			get_viewport().set_input_as_handled()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_world_position: Vector2 = get_viewport().get_canvas_transform().affine_inverse() * event.position
		_select_target_at(mouse_world_position)
	if event is InputEventScreenTouch and event.pressed:
		var world_position: Vector2 = get_viewport().get_canvas_transform().affine_inverse() * event.position
		_select_target_at(world_position)


func interact_with_beacon() -> void:
	interact_with_nearest()


func _connect_hud() -> void:
	_hud = get_node("HUD") as CanvasLayer
	_hud.layer = 1
	_hud.set_character_name(character_name)
	_hud.cycle_target_pressed.connect(_cycle_target)
	_hud.pause_pressed.connect(_on_pause_requested)
	_hud.interact_pressed.connect(interact_with_nearest)
	_hud.joystick_moved.connect(_set_joystick_vector)
	_hud.zoom_requested.connect(_change_zoom)
	_hud.auto_attack_toggled.connect(func(enabled: bool) -> void: _auto_attack_enabled = enabled)
	_hud.skill_pressed.connect(_use_skill)
	_hud.bandage_pressed.connect(_use_bandage)
	_hud.craft_bandage_pressed.connect(_craft_bandage)
	_hud.upgrade_camp_pressed.connect(_upgrade_camp)
	_hud.respawn_pressed.connect(func() -> void: _return_to_refuge(true))


func _build_tile_set(manifest: Dictionary) -> bool:
	var atlas_data: Dictionary = manifest.get("atlas", {})
	var atlas_path := TILE_MANIFEST.get_base_dir().path_join(str(atlas_data.get("file", "")))
	if not ResourceLoader.exists(atlas_path):
		push_error("Atlas de terreno ausente: %s" % atlas_path)
		return false
	var atlas_texture := load(atlas_path) as Texture2D
	if atlas_texture == null:
		push_error("Falha ao importar terreno candidate: %s" % atlas_path)
		return false
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)
	var source := TileSetAtlasSource.new()
	source.texture = atlas_texture
	source.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	for tile in manifest.get("tiles", []):
		var id := str(tile.get("id", ""))
		var coordinate: Array = tile.get("atlas_xy_tiles", [0, 0])
		if id.is_empty() or coordinate.size() < 2:
			push_error("Tile de terreno com metadata incompleta: %s" % str(tile))
			continue
		var atlas_coordinate := Vector2i(int(coordinate[0]), int(coordinate[1]))
		source.create_tile(atlas_coordinate)
		_tile_lookup[id] = {
			"atlas": atlas_coordinate,
			"group": str(tile.get("group", "")),
			"role": str(tile.get("role", ""))
		}
	tile_set.add_source(source, 0)
	for node_name in ["BaseTiles", "Transitions", "Paths"]:
		var layer := get_node(node_name) as TileMapLayer
		layer.tile_set = tile_set
		layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	return true


func _paint_map(manifest: Dictionary) -> void:
	var size_data: Array = _layout.get("grid_size", [64, 44])
	var width := int(size_data[0])
	var height := int(size_data[1])
	var base_by_group: Dictionary = {}
	for tile in manifest.get("tiles", []):
		if str(tile.get("role", "")) == "base":
			var group := str(tile.get("group", ""))
			if not base_by_group.has(group):
				base_by_group[group] = []
			base_by_group[group].append(str(tile.get("id", "")))
	var base_layer := get_node("BaseTiles") as TileMapLayer
	var seeded := int(_layout.get("seed", 0))
	for band in _layout.get("surface_bands", []):
		var group := str(band.get("group", ""))
		var variants: Array = base_by_group.get(group, [])
		if variants.is_empty():
			push_error("Nenhum tile base no grupo %s" % group)
			continue
		for x in range(int(band.get("from_x", 0)), int(band.get("to_x", 0))):
			for y in range(height):
				var index := (x * 17 + y * 31 + seeded) % variants.size()
				_set_tile(base_layer, Vector2i(x, y), str(variants[index]))
	for area in _layout.get("surface_areas", []):
		var variants: Array = base_by_group.get(str(area.get("group", "")), [])
		if variants.is_empty():
			continue
		for x in range(int(area.get("from_x", 0)), int(area.get("to_x", 0))):
			for y in range(int(area.get("from_y", 0)), int(area.get("to_y", 0))):
				_set_tile(
					base_layer,
					Vector2i(x, y),
					str(variants[(x * 17 + y * 31 + seeded) % variants.size()])
				)
	for band in _layout.get("transition_bands", []):
		var id := "%s_edge_%s" % [str(band.get("prefix", "")), str(band.get("edge", ""))]
		var x := int(band.get("x", 0))
		for y in range(height):
			_set_tile(get_node("Transitions") as TileMapLayer, Vector2i(x, y), id)
	for patch in _layout.get("transition_patches", []):
		_paint_transition_patch(patch)
	for path in _layout.get("path_network", []):
		var cell: Array = path.get("cell", [0, 0])
		_set_tile(
			get_node("Paths") as TileMapLayer,
			Vector2i(int(cell[0]), int(cell[1])),
			str(path.get("id", ""))
		)


func _paint_transition_patch(patch: Dictionary) -> void:
	var prefix := str(patch.get("prefix", ""))
	var center: Array = patch.get("center", [0, 0])
	var cx := int(center[0])
	var cy := int(center[1])
	var center_id := str(patch.get("inner_base", ""))
	var layer := get_node("Transitions") as TileMapLayer
	var cells := [
		[Vector2i(cx - 1, cy - 1), "%s_corner_nw" % prefix],
		[Vector2i(cx, cy - 1), "%s_edge_n" % prefix],
		[Vector2i(cx + 1, cy - 1), "%s_corner_ne" % prefix],
		[Vector2i(cx - 1, cy), "%s_edge_w" % prefix],
		[Vector2i(cx, cy), center_id],
		[Vector2i(cx + 1, cy), "%s_edge_e" % prefix],
		[Vector2i(cx - 1, cy + 1), "%s_corner_sw" % prefix],
		[Vector2i(cx, cy + 1), "%s_edge_s" % prefix],
		[Vector2i(cx + 1, cy + 1), "%s_corner_se" % prefix]
	]
	for item in cells:
		_set_tile(layer, item[0], str(item[1]))


func _set_tile(layer: TileMapLayer, cell: Vector2i, tile_id: String) -> void:
	if not _tile_lookup.has(tile_id):
		push_error("ID de tile do layout não existe no atlas: %s" % tile_id)
		return
	var tile: Dictionary = _tile_lookup[tile_id]
	layer.set_cell(cell, 0, tile.atlas)


func _build_world_collision() -> void:
	var size_data: Array = _layout.get("grid_size", [64, 44])
	var map_width := float(size_data[0]) * TILE_SIZE
	var map_height := float(size_data[1]) * TILE_SIZE
	_add_rect_collider(
		Vector2(TILE_SIZE * 4.0, map_height * 0.5),
		Vector2(TILE_SIZE * 8.0, map_height),
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
	var camera := get_node("Camera2D") as Camera2D
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(map_width)
	camera.limit_bottom = int(map_height)
	camera.limit_smoothed = false
	camera.position_smoothing_enabled = false


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
			_add_polygon(
				prop,
				[Vector2(-7, 14), Vector2(7, 14), Vector2(7, 28), Vector2(-7, 28)],
				Color("79503c")
			)
			_add_polygon(
				prop,
				[
					Vector2(-21, 8),
					Vector2(-17, -10),
					Vector2(-6, -22),
					Vector2(11, -18),
					Vector2(22, -3),
					Vector2(16, 12),
					Vector2(0, 17)
				],
				Color("39694b")
			)
			_add_polygon(
				prop,
				[
					Vector2(-11, -9),
					Vector2(-4, -18),
					Vector2(8, -15),
					Vector2(13, -5),
					Vector2(1, 2)
				],
				Color("57885a")
			)
			_add_prop_collider(prop, Vector2(0, 8), Vector2(26, 28), prop.name + "Collision")
			_register_resource_node(prop, node_id, "wood", 15, center)
		else:
			_add_polygon(
				prop,
				[
					Vector2(-16, 10),
					Vector2(-20, 0),
					Vector2(-10, -13),
					Vector2(8, -16),
					Vector2(19, -4),
					Vector2(14, 10),
					Vector2(0, 15)
				],
				Color("7c8492")
			)
			_add_polygon(
				prop,
				[Vector2(-8, -7), Vector2(4, -12), Vector2(11, -5), Vector2(1, -2)],
				Color("a4adba")
			)
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
	var actor := CREATURE_ACTOR.new() as CreatureActor
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
		if _is_safe_position(spawn_position) or _position_is_visible(spawn_position):
			continue
		var creature_data := COMBAT_RULES.monster(str(spawn_data.species))
		var refreshed := _state.respawn_actor(str(slot_id), float(creature_data.get("hp", 1)), spawn_position)
		_spawn_creature(str(slot_id), creature_data, refreshed)
		_hud.set_status("%s voltou à ilha, fora da área visível." % str(spawn_data.species).capitalize())
		save_progress()


func _position_is_visible(point: Vector2) -> bool:
	if _camera == null:
		return true
	var center := _camera.get_screen_center_position()
	var viewport_size := get_viewport_rect().size / _camera.zoom
	var visible_rect := Rect2(center - viewport_size * 0.5, viewport_size)
	return visible_rect.has_point(point)


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


func _select_target_at(point: Vector2) -> void:
	if _state == null or not _state.is_ready() or _state.downed_remaining >= 0.0:
		return
	var nearest: CreatureActor
	var distance := 1.0
	for actor_value in _creature_actors.values():
		var actor := actor_value as CreatureActor
		if not is_instance_valid(actor) or not actor.is_alive:
			continue
		var candidate := actor.selection_distance(point, _camera.zoom.x)
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
	var screen := get_viewport_rect().grow(-24)
	var transform := get_viewport().get_canvas_transform()
	for value in _creature_actors.values():
		var actor := value as CreatureActor
		if is_instance_valid(actor) and actor.is_alive and screen.has_point(transform * actor.global_position):
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
	var label := Label.new()
	label.name = "FloatingDamage"
	label.text = "−%d" % maxi(1, roundi(amount))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.z_index = 100
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", Color("ff6868") if received else Color("ffe9a6"))
	label.add_theme_color_override("font_outline_color", Color("15141a"))
	label.add_theme_constant_override("outline_size", 6)
	label.scale = Vector2.ONE / _camera.zoom.x
	_damage_serial += 1
	label.position = point + Vector2(float((_damage_serial % 3) - 1) * 22.0, -float(_damage_serial % 2) * 16.0)
	add_child(label, true)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 68.0 / _camera.zoom.x, 0.95).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.45).set_delay(0.5)
	tween.chain().tween_callback(label.queue_free)


func _perform_basic_attack() -> void:
	if _target == null or not is_instance_valid(_target) or not _target.is_alive or _state.downed_remaining >= 0.0:
		return
	if _is_safe_position(_player.global_position):
		_hud.set_status("O cristal protege o refúgio; ataque fora da área segura.")
		return
	_state.cancel_bandage()
	var damage := _state.physical_attack()
	var target := _target
	target.take_hit(damage)
	_hud.set_status("Ataque básico · %d de dano." % roundi(damage))
	_update_hud()


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
	var targets: Array[CreatureActor] = []
	var target_kind := str(skill.get("target", ""))
	if target_kind == "single":
		if _target != null and is_instance_valid(_target) and _target.is_alive and _player.global_position.distance_to(_target.global_position) <= 54.0:
			targets.append(_target)
	elif target_kind == "adjacent_aoe":
		targets = _actors_in_radius(68.0)
	else:
		targets = _actors_in_radius(112.0)
	if targets.is_empty():
		_hud.set_status("Nenhum alvo no alcance da habilidade.")
		return
	_state.mp -= mana_cost
	_state.skill_cooldowns[skill_id] = cooldown
	var physical := _state.physical_attack()
	var magical := _state.magic_attack()
	if target_kind == "single":
		var hits := maxi(1, int(skill.get("hits", 1)))
		var ratio := float(skill.get("physical_percent", skill.get("physical_percent_each_hit", 100))) / 100.0
		for _hit in range(hits):
			if not is_instance_valid(targets[0]) or not targets[0].is_alive:
				break
			targets[0].take_hit(physical * ratio)
			if not is_instance_valid(targets[0]) or not targets[0].is_alive:
				break
	else:
		for actor in targets:
			if not is_instance_valid(actor) or not actor.is_alive:
				continue
			var damage := physical * float(skill.get("physical_percent", 0)) / 100.0
			damage += magical * float(skill.get("magic_percent", 0)) / 100.0
			var died := actor.take_hit(damage)
			if target_kind == "adjacent_aoe" and not died and is_instance_valid(actor) and actor.is_alive:
				_apply_bleed(actor, physical)
			if skill.has("status_duration_sec") and str(skill.get("status", "")) == "stun" and not died and is_instance_valid(actor) and actor.is_alive:
				actor.apply_stun(float(skill.get("status_duration_sec", 0)))
	_hud.set_status("%s · %d MP." % [skill_id.replace("war_", "").capitalize(), int(mana_cost)])
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
	_show_damage(actual, _player.global_position + Vector2(0, -56), true)
	_hud.set_status("%s atingiu você · %d de dano." % [species_id.capitalize(), roundi(actual)])
	if _state.hp <= 0.0:
		_player.set_input_enabled(false)
		_state.cancel_bandage()
		_hud.set_status("Você caiu. No modo solo, volte à barraca ou aguarde o retorno.")
		save_progress()
	_update_hud()


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
	if _state == null or _player == null:
		return
	if drop_materials:
		var refuge := _beacon_position + Vector2(64.0, 36.0)
		var bag_position: Vector2 = _player.global_position
		var lost := _state.begin_downed_respawn(refuge, bag_position)
		_build_persistent_bags()
		_player.global_position = refuge
		_player.set_input_enabled(true)
		_set_target(null)
		_hud.set_status("Você voltou à barraca. Metade dos materiais foi deixada na mochila persistente." if not lost.is_empty() else "Você voltou à barraca e recuperou HP e MP.")
		save_progress()
		_update_hud()


func _is_downed() -> bool:
	return _state != null and _state.downed_remaining >= 0.0


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
	if _hud == null or _state == null or not _state.is_ready():
		return
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
		target_name, target_hp, target_max_hp, _state.downed_remaining, _state.skill_cooldowns
	)


func _build_beacon() -> void:
	var cell: Array = _layout.get("beacon_cell", [21, 23])
	_beacon_position = Vector2((int(cell[0]) + 0.5) * TILE_SIZE, (int(cell[1]) + 0.5) * TILE_SIZE)
	var beacon := Node2D.new()
	beacon.name = "CrystalInteractionPlaceholder"
	beacon.position = _beacon_position
	_add_polygon(
		beacon, [Vector2(0, -28), Vector2(14, 0), Vector2(0, 28), Vector2(-14, 0)], Color("a780e7")
	)
	_add_polygon(
		beacon, [Vector2(0, -18), Vector2(7, 0), Vector2(0, 18), Vector2(-7, 0)], Color("bcecf5")
	)
	var ring := Polygon2D.new()
	ring.polygon = PackedVector2Array(
		[Vector2(-22, 31), Vector2(22, 31), Vector2(29, 38), Vector2(-29, 38)]
	)
	ring.color = Color(0.44, 0.77, 0.83, 0.62)
	beacon.add_child(ring)
	get_node("Actors").add_child(beacon)


func _build_player() -> void:
	_player = PLAYER_SCENE.instantiate() as CharacterBody2D
	_player.selected_character_id = selected_character_id
	_player.position = _state.player_position
	_player.facing = _state.player_facing
	_player.set_input_enabled(_state.downed_remaining < 0.0)
	_player.name = "LocalPlayer"
	get_node("Actors").add_child(_player)
	_camera = get_node("Camera2D") as Camera2D
	_camera.reparent(_player)
	_camera.position = Vector2.ZERO
	_camera.make_current()


func _change_zoom(delta: int) -> void:
	_current_zoom_index = clampi(_current_zoom_index + delta, 0, ZOOM_LEVELS.size() - 1)
	if _camera != null:
		_camera.zoom = Vector2.ONE * float(ZOOM_LEVELS[_current_zoom_index])


func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("Dados do mapa ausentes: %s" % path)
		return {}
	var result = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not result is Dictionary:
		push_error("Dados do mapa inválidos: %s" % path)
		return {}
	return result
