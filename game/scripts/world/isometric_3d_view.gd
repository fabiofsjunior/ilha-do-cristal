extends Node3D
## 3D presentation for the existing 2D SQM simulation.
## The world model, collisions and saves remain 2D; X/Y map to X/Z here.

const TERRAIN_ATLAS_PATH := "res://assets/environments/terrain_mvp_candidate_v1/terrain_mvp_candidate_v1.png"
const TILE_PIXELS := 32.0
const LEGACY_GROUND_SIZE := Vector2i(64, 44)

@export var orthogonal_size := 16.0
@export var follow_distance := 24.0
@export var follow_speed := 5.0
@export var target_height := 0.8

var game: Node
var player_2d: Node2D
var camera: Camera3D
var actor_sprites: Dictionary = {}
var gatherable_sprites: Dictionary = {}
var selection_sprites: Dictionary = {}
var target_labels: Dictionary = {}
var _target_ring_texture: Texture2D
var crystal_light: OmniLight3D
var prop_root: Node3D
var damage_root: Node3D
var _ground_size := Vector2(64,44)

func _ready() -> void:
	camera = get_node("Camera3D")
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = orthogonal_size
	camera.near = 0.1
	camera.far = 120.0
	camera.rotation_degrees = Vector3(-30.0, 45.0, 0.0)
	camera.make_current()
	prop_root = Node3D.new()
	prop_root.name = "DepthSortedSprites"
	add_child(prop_root)
	damage_root = Node3D.new()
	damage_root.name = "FloatingDamage"
	add_child(damage_root)

func configure(world: Node) -> void:
	game = world
	player_2d = game._player
	var dimensions: Array = game._layout.get("grid_size", [64,44])
	_ground_size = Vector2(float(dimensions[0]), float(dimensions[1]))
	_build_lighting()
	_build_ground()
	_build_props()
	camera.current = true
	camera.global_position = _camera_position(_bounded_focus(_player_focus()))
	_sync_actors()
	_build_gatherables()

func _process(delta: float) -> void:
	if game == null or not is_instance_valid(player_2d):
		return
	var desired := _camera_position(_bounded_focus(_player_focus()))
	var weight := 1.0 - exp(-follow_speed * delta)
	camera.global_position = camera.global_position.lerp(desired, weight)
	_sync_actors()
	_build_gatherables()

func _player_focus() -> Vector3:
	return Vector3(player_2d.global_position.x / 32.0, target_height, player_2d.global_position.y / 32.0)

func _camera_position(focus: Vector3) -> Vector3:
	return focus + camera.global_basis.z * follow_distance

func _bounded_focus(focus: Vector3) -> Vector3:
	var viewport_size := get_viewport().get_visible_rect().size
	var aspect := viewport_size.x / maxf(1.0, viewport_size.y)
	var half_height := camera.size * 0.5
	# Orthographic frustum projected onto XZ, including inclination and yaw.
	var minimum := Vector2(INF, INF)
	var maximum := Vector2(-INF, -INF)
	var ray_direction := -camera.global_basis.z
	for x in [-1.0, 1.0]:
		for y in [-1.0, 1.0]:
			var origin: Vector3 = Vector3(0, target_height, 0) + camera.global_basis.x * x * half_height * aspect + camera.global_basis.y * y * half_height
			var ground: Vector3 = origin - ray_direction * (origin.y / ray_direction.y)
			minimum = minimum.min(Vector2(ground.x, ground.z))
			maximum = maximum.max(Vector2(ground.x, ground.z))
	focus.x = clampf(focus.x, -minimum.x, _ground_size.x - maximum.x)
	focus.z = clampf(focus.z, -minimum.y, _ground_size.y - maximum.y)
	return focus

func world_point(point: Vector2, height := 0.0) -> Vector3:
	return Vector3(point.x / 32.0, height, point.y / 32.0)

func point_from_screen(screen_point: Vector2) -> Vector2:
	var origin := camera.project_ray_origin(screen_point)
	var direction := camera.project_ray_normal(screen_point)
	var ground: Variant = Plane(Vector3.UP, 0.0).intersects_ray(origin, direction)
	if ground == null:
		return Vector2(-1e7, -1e7)
	return Vector2(ground.x * 32.0, ground.z * 32.0)

func minimap_camera_view() -> PackedVector2Array:
	# Use camera rays rather than guessed zoom/aspect math: this also tracks
	# camera smoothing, edge clamping and any viewport aspect ratio.
	var viewport_size := get_viewport().get_visible_rect().size
	var origin := point_from_screen(Vector2.ZERO)
	return PackedVector2Array([
		origin,
		point_from_screen(Vector2(viewport_size.x, 0.0)) - origin,
		point_from_screen(Vector2(0.0, viewport_size.y)) - origin
	])


func is_on_screen(point: Vector2) -> bool:
	var projected := camera.unproject_position(world_point(point, 0.5))
	return get_viewport().get_visible_rect().has_point(projected)

func _build_lighting() -> void:
	var environment := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("b7c5b6")
	env.ambient_light_energy = 0.65
	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color("1c3946")
	sky_material.sky_horizon_color = Color("e5c992")
	sky.sky_material = sky_material
	env.sky = sky
	environment.environment = env
	add_child(environment)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -28, 0)
	sun.light_color = Color("ffe0aa")
	sun.light_energy = 0.72
	sun.shadow_enabled = true
	add_child(sun)

func _build_ground() -> void:
	var atlas_texture := load(TERRAIN_ATLAS_PATH) as Texture2D
	if atlas_texture == null or game == null:
		push_error("Não foi possível carregar o atlas para a superfície 2.5D.")
		return
	for layer_name in ["BaseTiles", "Transitions", "Paths"]:
		_build_expanded_tile_surface(layer_name, atlas_texture)
	_build_legacy_ground_patch()


func _build_expanded_tile_surface(layer_name: String, atlas_texture: Texture2D) -> void:
	var layer := game.get_node_or_null(layer_name) as TileMapLayer
	if layer == null:
		return
	var vertices := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	for cell in layer.get_used_cells():
		# Keep the authored beach/start area pixel-for-pixel and tile the expanded land.
		if cell.x < LEGACY_GROUND_SIZE.x and cell.y < LEGACY_GROUND_SIZE.y:
			continue
		var atlas_cell := layer.get_cell_atlas_coords(cell)
		_append_tile_quad(cell, atlas_cell, atlas_texture, vertices, uvs, indices)
	if vertices.is_empty():
		return
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var tile_mesh := ArrayMesh.new()
	tile_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var surface := MeshInstance3D.new()
	surface.name = "ExpandedTerrain_%s" % layer_name
	surface.mesh = tile_mesh
	surface.material_override = _terrain_material(atlas_texture, layer_name != "BaseTiles")
	surface.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	match layer_name:
		"Transitions":
			surface.position.y = 0.004
		"Paths":
			surface.position.y = 0.008
	add_child(surface)


func _append_tile_quad(
	cell: Vector2i,
	atlas_cell: Vector2i,
	atlas_texture: Texture2D,
	vertices: PackedVector3Array,
	uvs: PackedVector2Array,
	indices: PackedInt32Array
) -> void:
	var base_index := vertices.size()
	var x0 := float(cell.x)
	var z0 := float(cell.y)
	vertices.append_array(PackedVector3Array([
		Vector3(x0, 0.0, z0),
		Vector3(x0 + 1.0, 0.0, z0),
		Vector3(x0 + 1.0, 0.0, z0 + 1.0),
		Vector3(x0, 0.0, z0 + 1.0)
	]))
	var pixel_size := Vector2(atlas_texture.get_width(), atlas_texture.get_height())
	var pixel_origin := Vector2(atlas_cell) * TILE_PIXELS
	var inset := Vector2(0.5, 0.5)
	var uv_min := (pixel_origin + inset) / pixel_size
	var uv_max := (pixel_origin + Vector2(TILE_PIXELS, TILE_PIXELS) - inset) / pixel_size
	uvs.append_array(PackedVector2Array([
		Vector2(uv_min.x, uv_min.y),
		Vector2(uv_max.x, uv_min.y),
		Vector2(uv_max.x, uv_max.y),
		Vector2(uv_min.x, uv_max.y)
	]))
	indices.append_array(PackedInt32Array([
		base_index, base_index + 2, base_index + 1,
		base_index, base_index + 3, base_index + 2
	]))


func _terrain_material(atlas_texture: Texture2D, has_transparency: bool) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	material.albedo_texture = atlas_texture
	if has_transparency:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
		material.alpha_scissor_threshold = 0.1
	return material


func _build_legacy_ground_patch() -> void:
	var legacy_size := Vector2(minf(_ground_size.x, LEGACY_GROUND_SIZE.x), minf(_ground_size.y, LEGACY_GROUND_SIZE.y))
	var plane := MeshInstance3D.new()
	plane.name = "OriginalBeachAndStartGround"
	var quad := QuadMesh.new()
	quad.size = legacy_size
	plane.mesh = quad
	plane.rotation_degrees.x = -90.0
	plane.position = Vector3(legacy_size.x * 0.5, 0.012, legacy_size.y * 0.5)
	var legacy_texture := load("res://assets/environments/tropical_oblique_candidate/ground.png") as Texture2D
	var material := _terrain_material(legacy_texture, false)
	material.uv1_scale = Vector3(1.0, -1.0, 1.0)
	plane.material_override = material
	add_child(plane)

func _build_props() -> void:
	for obstacle in game._layout.get("obstacles", []):
		var cell: Array = obstacle.get("cell", [0,0])
		var kind := str(obstacle.get("kind", "tree"))
		var id := "%s_%d_%d" % [kind, int(cell[0]), int(cell[1])]
		if game._state.harvested_nodes.has(id):
			continue
		var texture_path := "palm_generated" if kind == "tree" and int(cell[0]) < 35 else ("tree" if kind == "tree" else "boulder")
		var pivot := Vector2(69,126) if texture_path == "palm_generated" else (Vector2(52,109) if texture_path == "tree" else Vector2(32,40))
		var node := _make_sprite(load("res://assets/environments/tropical_oblique_candidate/%s.png" % texture_path), id)
		var foot := Vector2((float(cell[0]) + 0.5)*32.0, (float(cell[1]) + 0.5)*32.0)
		_place_sprite(node, foot, int(pivot.y))
	var beacon_cell: Array = game._layout.get("beacon_cell", [21,23])
	var crystal := _make_sprite(load("res://assets/environments/tropical_oblique_candidate/crystal.png"), "CrystalBeacon")
	_place_sprite(crystal, Vector2((float(beacon_cell[0])+0.5)*32.0,(float(beacon_cell[1])+0.5)*32.0), 84)
	crystal_light = OmniLight3D.new()
	crystal_light.name = "CrystalGlow"
	crystal_light.light_color = Color("64dfff")
	crystal_light.light_energy = 2.2
	crystal_light.omni_range = 7.0
	crystal_light.shadow_enabled = false
	crystal_light.position = Vector3((float(beacon_cell[0])+0.5), 1.1, (float(beacon_cell[1])+0.5))
	add_child(crystal_light)

func _make_sprite(texture: Texture2D, key: String) -> Sprite3D:
	var sprite := Sprite3D.new()
	sprite.name = key
	sprite.texture = texture
	sprite.pixel_size = 1.0 / 32.0
	sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	sprite.alpha_scissor_threshold = 0.12
	sprite.no_depth_test = false
	prop_root.add_child(sprite)
	return sprite

func _place_sprite(sprite: Sprite3D, foot: Vector2, pivot_y: int) -> void:
	var height := float(sprite.texture.get_height()) / 32.0
	sprite.offset = Vector2(0.0, float(pivot_y) - float(sprite.texture.get_height()) * 0.5)
	sprite.position = Vector3(foot.x / 32.0, 0.04, foot.y / 32.0)

func _sync_actors() -> void:
	if game == null:
		return
	var live: Dictionary = {}
	if is_instance_valid(player_2d):
		live["player"] = player_2d
	for key in game._creature_actors:
		var actor = game._creature_actors[key]
		if is_instance_valid(actor) and actor.is_alive:
			live[str(key)] = actor
	for key in actor_sprites.keys():
		if not live.has(key):
			if is_instance_valid(actor_sprites[key]): actor_sprites[key].queue_free()
			actor_sprites.erase(key)
	for key in live:
		var actor: Node2D = live[key]
		var sprite: Sprite3D = actor_sprites.get(key)
		if not is_instance_valid(sprite):
			var texture: Texture2D = _actor_texture(actor)
			if texture == null: continue
			sprite = _make_sprite(texture, "Actor_%s" % str(key))
			if key != "player":
				sprite.scale = Vector3.ONE * (1.0 if actor.species_id != "bear" else 1.3)
			actor_sprites[key] = sprite
		var current_texture := _actor_texture(actor)
		if current_texture != null and sprite.texture != current_texture:
			sprite.texture = current_texture
		var source_offset := Vector2.ZERO
		if key == "player":
			var animated_pose := actor.get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
			if animated_pose != null:
				source_offset = animated_pose.offset
		else:
			var static_pose := actor.get_node_or_null("StaticCandidatePoseSE") as Sprite2D
			if static_pose != null:
				source_offset = static_pose.offset
		# The simulation position is the feet/pivot. Mirror the 2D sprite offset
		# so its metadata pivot lands on the same ground point in the 3D view.
		sprite.offset = Vector2(source_offset.x, -source_offset.y)
		sprite.position = Vector3(actor.global_position.x / 32.0, 0.04, actor.global_position.y / 32.0)
		sprite.visible = true
		if key == "player":
			sprite.modulate = Color(1, 1, 1, 0.35 if bool(actor.get_meta("combat_invisible", false)) else 1.0)
		if key != "player":
			sprite.modulate = Color.WHITE if not actor.selected else Color("fff0b5")
			_update_target_feedback(str(key), actor)

func _build_gatherables() -> void:
	var active: Dictionary = {}
	for data in game._resource_nodes:
		var actor: Node2D = data.get("actor")
		if not is_instance_valid(actor):
			continue
		var kind := str(data.get("resource", ""))
		if kind in ["wood", "stone"]:
			continue
		var key := "gather_%s" % str(data.get("id", ""))
		active[key] = true
		var sprite := gatherable_sprites.get(key) as Sprite3D
		if not is_instance_valid(sprite):
			sprite = _make_sprite(_gatherable_texture(kind), key)
			gatherable_sprites[key] = sprite
		sprite.position = Vector3(actor.global_position.x/32.0, 0.42, actor.global_position.y/32.0 + 0.18)
	for key in gatherable_sprites.keys():
		if not active.has(key):
			if is_instance_valid(gatherable_sprites[key]): gatherable_sprites[key].queue_free()
			gatherable_sprites.erase(key)

func _gatherable_texture(kind: String) -> Texture2D:
	var image := Image.create(24, 24, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	var dark := Color("365740") if kind == "fiber" else (Color("725038") if kind == "persistent_bag" else Color("52693d"))
	var light := Color("91bf61") if kind == "fiber" else (Color("c18d52") if kind == "persistent_bag" else Color("80a950"))
	for x in range(5, 20):
		var center_y := 18 - int(absf(float(x)-12.0)*0.65)
		for dy in range(3): image.set_pixel(x, center_y+dy, dark if dy == 2 else light)
	for x in range(8, 18, 4):
		image.set_pixel(x, 8, light)
		image.set_pixel(x+1, 7, light)
	if kind == "herb":
		for flower in [Vector2i(7,6),Vector2i(12,4),Vector2i(17,6)]:
			image.set_pixelv(flower, Color("f7e5a3")); image.set_pixelv(flower+Vector2i(1,0),Color("e9a6c0"))
	elif kind == "persistent_bag":
		for y in range(10,20):
			for x in range(7,18):
				image.set_pixel(x,y,Color("754832") if x in [7,17] or y == 19 else Color("bd8c52"))
		image.set_pixel(11,9,Color("e1bd75")); image.set_pixel(12,9,Color("e1bd75"))
	return ImageTexture.create_from_image(image)

func _update_target_feedback(key: String, actor: Node2D) -> void:
	var ring := selection_sprites.get(key) as Sprite3D
	if not is_instance_valid(ring):
		ring = Sprite3D.new()
		ring.name = "TargetRing_%s" % key
		ring.texture = _get_target_ring_texture()
		ring.pixel_size = 1.0 / 32.0
		ring.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		ring.billboard = BaseMaterial3D.BILLBOARD_DISABLED
		# Face the ring's front side upward so the camera sees it from above.
		ring.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
		ring.position = _target_ground_position(actor)
		prop_root.add_child(ring)
		selection_sprites[key] = ring
	var active: bool = bool(actor.get("selected"))
	ring.visible = active
	ring.position = _target_ground_position(actor)
	var label := target_labels.get(key) as Label3D
	if not is_instance_valid(label):
		label = Label3D.new()
		label.name = "TargetInfo_%s" % key
		label.font_size = 18
		label.pixel_size = 0.01
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.outline_size = 5
		label.outline_modulate = Color("172026")
		label.modulate = Color("fff0b8")
		prop_root.add_child(label)
		target_labels[key] = label
	label.visible = active
	label.text = "%s  %d/%d" % [actor.display_name, roundi(actor.hp), roundi(actor.max_hp)] if active else ""
	label.position = Vector3(actor.global_position.x/32.0, sprite_height(actor)+0.35, actor.global_position.y/32.0)
	if crystal_light != null:
		crystal_light.light_energy = 1.8 + 0.35 * (1.0 + sin(Time.get_ticks_msec() * 0.002))

func _target_ground_position(actor: Node2D) -> Vector3:
	# The actor billboard is centered half a world unit ahead of its simulation point.
	# Matching that offset keeps the flat selection ellipse directly under its feet.
	return Vector3(actor.global_position.x / 32.0, 0.035, actor.global_position.y / 32.0)

func _get_target_ring_texture() -> Texture2D:
	if _target_ring_texture != null:
		return _target_ring_texture
	var image := Image.create(48, 48, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	var center := Vector2(23.5, 23.5)
	for y in range(48):
		for x in range(48):
			var radius := center.distance_to(Vector2(x, y))
			if radius < 15.5 or radius > 21.5:
				continue
			var color := Color("9b5c1f")
			if radius < 17.5:
				color = Color("fff0a1")
			elif radius < 19.5:
				color = Color("ffd34f")
			image.set_pixel(x, y, color)
	_target_ring_texture = ImageTexture.create_from_image(image)
	return _target_ring_texture


func show_damage(amount: float, point: Vector2, received: bool, serial: int) -> void:
	if amount <= 0.0 or damage_root == null:
		return
	var label := Label3D.new()
	label.name = "FloatingDamage_%d" % serial
	label.text = "−%d" % maxi(1, roundi(amount))
	label.font_size = 30
	label.pixel_size = 0.01
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = Color("ff6868") if received else Color("ffe9a6")
	label.outline_size = 8
	label.outline_modulate = Color("17141a")
	label.position = world_point(point, 1.0)
	damage_root.add_child(label)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y + 1.2, 0.95).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.45).set_delay(0.5)
	tween.chain().tween_callback(label.queue_free)

func sprite_height(actor: Node2D) -> float:
	var texture := _actor_texture(actor)
	return texture.get_height() / 32.0 if texture != null else 1.0

func _actor_texture(actor: Node2D) -> Texture2D:
	var anim := actor.get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if anim != null and anim.sprite_frames != null:
		return anim.sprite_frames.get_frame_texture(anim.animation, anim.frame)
	var pose := actor.get_node_or_null("StaticCandidatePoseSE") as Sprite2D
	return pose.texture if pose != null else null
