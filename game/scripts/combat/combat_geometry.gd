extends RefCounted
## Distance helpers based on the active CollisionShape2D surfaces, rather than
## actor pivots. Visual spacing is calculated separately from navigation
## colliders so large candidate sprites do not make terrain paths impassable.

const VISUAL_FOOTPRINTS_PATH := "res://game/data/melee_visual_footprints.json"
const EPSILON := 0.0001
const CAMERA_YAW_DEGREES := 45.0
const CAMERA_PITCH_DEGREES := 30.0
const VISUAL_FOOTPRINT_MARGIN_PX := 4.0

static var _visual_footprints_cache: Dictionary = {}


static func surface_gap_between(first: CollisionObject2D, second: CollisionObject2D) -> float:
	if not is_instance_valid(first) or not is_instance_valid(second):
		return INF
	var first_shape := _find_collision_shape(first)
	var second_shape := _find_collision_shape(second)
	if first_shape == null or second_shape == null:
		push_error("Não foi possível medir combate: os dois atores precisam de CollisionShape2D.")
		return INF
	var first_geometry := _capsule_geometry(first_shape)
	var second_geometry := _capsule_geometry(second_shape)
	if first_geometry.is_empty() or second_geometry.is_empty():
		return INF
	var centerline_gap := _segment_distance(
		first_geometry.a, first_geometry.b, second_geometry.a, second_geometry.b
	)
	return centerline_gap - first_geometry.radius - second_geometry.radius


static func surface_distance_between(first: CollisionObject2D, second: CollisionObject2D) -> float:
	return maxf(0.0, surface_gap_between(first, second))


static func is_within_surface_range(
	first: CollisionObject2D, second: CollisionObject2D, max_surface_range: float
) -> bool:
	if max_surface_range < 0.0:
		return false
	return surface_distance_between(first, second) <= max_surface_range + EPSILON


## The sprite footprint is a conservative alpha-bounds proxy projected through
## the fixed 2.5D camera. `gap` is measured from the projected alpha bounds;
## positive values are visible clearance, negative values indicate overlap.
static func visual_surface_gap_between(first: Node2D, second: Node2D) -> float:
	if not is_instance_valid(first) or not is_instance_valid(second):
		return INF
	var displacement := second.global_position - first.global_position
	if displacement.length_squared() <= EPSILON:
		return -visual_contact_distance(first, second, Vector2.RIGHT, 0.0)
	var direction := displacement.normalized()
	return displacement.length() - visual_contact_distance(first, second, direction, 0.0)


## Minimum gap between the projected sprite bounds in screen pixels. Unlike
## visual_surface_gap_between(), this is suitable for attack tolerances because
## it measures the actual billboard-space clearance in the 2.5D camera.
static func projected_visual_surface_gap_px_between(first: Node2D, second: Node2D) -> float:
	if not is_instance_valid(first) or not is_instance_valid(second):
		return INF
	var displacement := second.global_position - first.global_position
	var first_extents := _visual_alpha_extents(first)
	var second_extents := _visual_alpha_extents(second)
	if first_extents == Vector4.ZERO or second_extents == Vector4.ZERO:
		return INF
	var yaw := deg_to_rad(CAMERA_YAW_DEGREES)
	var pitch := deg_to_rad(CAMERA_PITCH_DEGREES)
	var camera_right := Vector2(cos(yaw), -sin(yaw))
	var ground_depth_up := Vector2(sin(yaw), cos(yaw)) * sin(pitch)
	var projected_x := displacement.dot(camera_right)
	var projected_y := displacement.dot(ground_depth_up)
	var gap_x := INF
	var gap_y := INF
	if absf(projected_x) > EPSILON:
		var needed_x := first_extents.y - second_extents.x if projected_x > 0.0 else second_extents.y - first_extents.x
		gap_x = absf(projected_x) - needed_x
	if absf(projected_y) > EPSILON:
		var needed_y := first_extents.w - second_extents.z if projected_y > 0.0 else second_extents.w - first_extents.z
		gap_y = absf(projected_y) - needed_y
	# Screen-space rectangles are separated when either axis has a positive
	# clearance. Use the Euclidean edge distance only when both axes are clear;
	# when they overlap on both axes, return the shallowest penetration depth.
	if gap_x >= 0.0 and gap_y >= 0.0:
		return Vector2(gap_x, gap_y).length()
	if gap_x >= 0.0:
		return gap_x
	if gap_y >= 0.0:
		return gap_y
	return maxf(gap_x, gap_y)


## Distance between ground pivots required for the alpha bounds to clear in the
## projected view. A small margin prevents sub-pixel movement from reintroducing
## overlap. Passing zero margin returns the bounds' actual contact distance.
static func visual_contact_distance(
	first: Node2D,
	second: Node2D,
	direction: Vector2,
	margin_px := -1.0
) -> float:
	var first_extents := _visual_alpha_extents(first)
	var second_extents := _visual_alpha_extents(second)
	if first_extents == Vector4.ZERO or second_extents == Vector4.ZERO:
		return INF
	if margin_px < 0.0:
		margin_px = visual_footprint_margin_px()
	var axis := direction.normalized()
	if axis.length_squared() <= EPSILON:
		axis = Vector2.RIGHT
	var yaw := deg_to_rad(CAMERA_YAW_DEGREES)
	var pitch := deg_to_rad(CAMERA_PITCH_DEGREES)
	var camera_right := Vector2(cos(yaw), -sin(yaw))
	var ground_depth_up := Vector2(sin(yaw), cos(yaw)) * sin(pitch)
	var screen_right := axis.dot(camera_right)
	var screen_up := axis.dot(ground_depth_up)
	var first_left := first_extents.x
	var first_right := first_extents.y
	var second_left := second_extents.x
	var second_right := second_extents.y
	var first_bottom := first_extents.z * cos(pitch)
	var first_top := first_extents.w * cos(pitch)
	var second_bottom := second_extents.z * cos(pitch)
	var second_top := second_extents.w * cos(pitch)
	var lateral_clearance := INF
	var depth_clearance := INF
	if absf(screen_right) > EPSILON:
		var needed_x := first_right - second_left if screen_right > 0.0 else second_right - first_left
		lateral_clearance = maxf(0.0, needed_x + margin_px) / absf(screen_right)
	if absf(screen_up) > EPSILON:
		var needed_y := first_top - second_bottom if screen_up > 0.0 else second_top - first_bottom
		depth_clearance = maxf(0.0, needed_y + margin_px) / absf(screen_up)
	return minf(lateral_clearance, depth_clearance)


## Clamp only actor-to-actor movement to the projected sprite footprint. The
## caller still uses the actor's original small capsule for terrain and props.
static func constrain_velocity_to_visual_contact(
	mover: CharacterBody2D, blockers: Array, desired_velocity: Vector2, delta: float
) -> Vector2:
	if delta <= EPSILON or desired_velocity.length_squared() <= EPSILON:
		return desired_velocity
	var start := mover.global_position
	var end := start + desired_velocity * delta
	for value in blockers:
		var blocker := value as Node2D
		if blocker == null or blocker == mover or not is_instance_valid(blocker):
			continue
		if blocker.is_in_group("combat_creatures") and not bool(blocker.get("is_alive")):
			continue
		var separation := end - blocker.global_position
		if separation.length_squared() <= EPSILON:
			separation = start - blocker.global_position
			if separation.length_squared() <= EPSILON:
				separation = Vector2.RIGHT
		var minimum_distance := visual_contact_distance(mover, blocker, separation.normalized())
		if separation.length() < minimum_distance:
			end = blocker.global_position + separation.normalized() * minimum_distance
	return (end - start) / delta


static func player_visual_alpha_bounds() -> Vector2:
	var data := _visual_footprints()
	var bounds: Array = data.get("player_alpha_bounds_px", [0, 0])
	return Vector2(float(bounds[0]), float(bounds[1])) if bounds.size() >= 2 else Vector2.ZERO


static func player_visual_alpha_extents() -> Vector4:
	var extents: Array = _visual_footprints().get("player_alpha_extents_px", [])
	return _array_to_extents(extents)


static func creature_visual_alpha_bounds(species_id: String) -> Vector2:
	var creatures: Dictionary = _visual_footprints().get("creatures", {})
	var entry: Dictionary = creatures.get(species_id, {})
	var bounds: Array = entry.get("rendered_alpha_bounds_px", [])
	return Vector2(float(bounds[0]), float(bounds[1])) if bounds.size() >= 2 else Vector2.ZERO


static func creature_visual_alpha_extents(species_id: String) -> Vector4:
	var creatures: Dictionary = _visual_footprints().get("creatures", {})
	var entry: Dictionary = creatures.get(species_id, {})
	return _array_to_extents(entry.get("rendered_alpha_extents_px", []))


static func visual_footprint_margin_px() -> float:
	return float(_visual_footprints().get("separation_margin_px", VISUAL_FOOTPRINT_MARGIN_PX))


static func _visual_alpha_extents(actor: Node2D) -> Vector4:
	if actor.has_method("melee_visual_alpha_extents_px"):
		var extents: Vector4 = actor.call("melee_visual_alpha_extents_px")
		return extents
	push_error("Ator sem contrato de alpha footprint para espaçamento melee: %s" % actor.name)
	return Vector4.ZERO


static func _array_to_extents(values: Array) -> Vector4:
	if values.size() < 4:
		return Vector4.ZERO
	return Vector4(float(values[0]), float(values[1]), float(values[2]), float(values[3]))


static func _visual_footprints() -> Dictionary:
	if not _visual_footprints_cache.is_empty():
		return _visual_footprints_cache
	if not FileAccess.file_exists(VISUAL_FOOTPRINTS_PATH):
		push_error("Contrato de alpha footprint ausente: %s" % VISUAL_FOOTPRINTS_PATH)
		return {}
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(VISUAL_FOOTPRINTS_PATH))
	if not parsed is Dictionary:
		push_error("Contrato de alpha footprint inválido: %s" % VISUAL_FOOTPRINTS_PATH)
		return {}
	_visual_footprints_cache = parsed
	return _visual_footprints_cache


static func _find_collision_shape(parent: Node) -> CollisionShape2D:
	for child in parent.get_children():
		if child is CollisionShape2D and not child.disabled:
			return child as CollisionShape2D
		var nested := _find_collision_shape(child)
		if nested != null:
			return nested
	return null


static func _capsule_geometry(shape_node: CollisionShape2D) -> Dictionary:
	var shape := shape_node.shape
	var transform := shape_node.global_transform
	var x_scale := transform.x.length()
	var y_scale := transform.y.length()
	var center := shape_node.global_position
	var radius := 0.0
	var half_segment := 0.0
	var axis := Vector2.UP

	if shape is CapsuleShape2D:
		radius = shape.radius * maxf(x_scale, y_scale)
		half_segment = maxf(0.0, shape.height * y_scale * 0.5 - radius)
		axis = transform.y.normalized()
	elif shape is CircleShape2D:
		radius = shape.radius * maxf(x_scale, y_scale)
	elif shape is RectangleShape2D:
		# No actor currently uses a rectangle, but approximating its shorter
		# axis with a capsule preserves a conservative surface measurement.
		var scaled_size: Vector2 = shape.size * Vector2(x_scale, y_scale)
		radius = minf(scaled_size.x, scaled_size.y) * 0.5
		half_segment = maxf(0.0, maxf(scaled_size.x, scaled_size.y) * 0.5 - radius)
		axis = transform.x.normalized() if scaled_size.x > scaled_size.y else transform.y.normalized()
	else:
		push_error("Forma de colisão não suportada para alcance melee: %s" % shape.get_class())
		return {}

	var half_axis := axis * half_segment
	return {"a": center - half_axis, "b": center + half_axis, "radius": radius}


static func _segment_distance(p1: Vector2, q1: Vector2, p2: Vector2, q2: Vector2) -> float:
	# Closest points between two segments, including degenerate circle spines.
	var d1 := q1 - p1
	var d2 := q2 - p2
	var r := p1 - p2
	var a := d1.dot(d1)
	var e := d2.dot(d2)
	var f := d2.dot(r)
	var s := 0.0
	var t := 0.0

	if a <= EPSILON and e <= EPSILON:
		return p1.distance_to(p2)
	if a <= EPSILON:
		t = clampf(f / e, 0.0, 1.0)
	else:
		var c := d1.dot(r)
		if e <= EPSILON:
			s = clampf(-c / a, 0.0, 1.0)
		else:
			var b := d1.dot(d2)
			var denominator := a * e - b * b
			if absf(denominator) > EPSILON:
				s = clampf((b * f - c * e) / denominator, 0.0, 1.0)
			t = (b * s + f) / e
			if t < 0.0:
				t = 0.0
				s = clampf(-c / a, 0.0, 1.0)
			elif t > 1.0:
				t = 1.0
				s = clampf((b - c) / a, 0.0, 1.0)

	return (p1 + d1 * s).distance_to(p2 + d2 * t)
