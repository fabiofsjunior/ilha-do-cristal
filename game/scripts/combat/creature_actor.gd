class_name CreatureActor
extends CharacterBody2D

signal damage_received(amount: float, point: Vector2)
signal player_damaged(amount: float, species_id: String)
signal feedback_requested(message: String)
signal defeated(actor: CreatureActor, death_id: String)

const HUD_ART = preload("res://game/scripts/ui/hud_art.gd")
const ART_LOADER = preload("res://game/scripts/actors/creature_art_loader.gd")
const COMBAT_GEOMETRY = preload("res://game/scripts/combat/combat_geometry.gd")

const MOVE_SPEEDS := {"fox": 116.0, "wolf": 92.0, "bear": 39.0}
const ATTACK_INTERVALS := {"fox": 2.0, "wolf": 1.8, "bear": 3.0}
## Basic attacks connect only within 2 logical pixels of projected alpha contact.
const ATTACK_VISUAL_GAP_TOLERANCE := 2.0
const BEAR_WINDUP := 0.9

var slot_id := ""
var runtime_id := ""
var region_id := ""
@export var species_id := "fox"
var display_name := "Raposa"
var _behavior := "aggressive"
var _attack_style := "basic"
var _windup_duration := BEAR_WINDUP
var _move_speed := 60.0
var _attack_interval := 2.0
var _visual_extents := Vector4(-24.0, 24.0, 0.0, 52.0)
var max_hp := 1.0
var hp := 1.0
var attack_damage := 1.0
var is_alive := true
var provoked := false
var attack_remaining := 0.0
var windup_remaining := 0.0
var stunned_remaining := 0.0
var _world_state: ExpeditionState
var _player: CharacterBody2D
var _refuge_position := Vector2.ZERO
var _label: Label
var selected := false
var _pose: Sprite2D


func configure(
	spawn_slot_id: String,
	creature_data: Dictionary,
	state: ExpeditionState,
	player: CharacterBody2D,
	refuge_position: Vector2,
	stored_state: Dictionary,
	instance_id: String,
	spawn_region_id := ""
) -> void:
	slot_id = spawn_slot_id
	runtime_id = instance_id
	species_id = str(creature_data.get("id", "fox"))
	region_id = spawn_region_id
	max_hp = float(creature_data.get("hp", 1))
	attack_damage = float(creature_data.get("attack", 1))
	_behavior = str(creature_data.get("behavior", "skittish" if species_id == "fox" else "aggressive"))
	_attack_style = str(creature_data.get("attack_style", "heavy" if species_id == "bear" else "basic"))
	_windup_duration = float(creature_data.get("windup_sec", BEAR_WINDUP))
	_move_speed = float(creature_data.get("move_speed", MOVE_SPEEDS.get(species_id, 60.0)))
	_attack_interval = float(creature_data.get("attack_interval_sec", ATTACK_INTERVALS.get(species_id, 2.0)))
	_world_state = state
	_player = player
	_refuge_position = refuge_position
	display_name = str(creature_data.get("name", species_id.capitalize()))
	hp = clampf(float(stored_state.get("hp", max_hp)), 0.0, max_hp)
	var position_data: Array = stored_state.get("position", [0.0, 0.0])
	position = Vector2(float(position_data[0]), float(position_data[1]))
	provoked = bool(stored_state.get("provoked", false))
	attack_remaining = maxf(0.0, float(stored_state.get("attack_remaining", 0.0)))
	windup_remaining = maxf(0.0, float(stored_state.get("windup_remaining", 0.0)))
	stunned_remaining = maxf(0.0, float(stored_state.get("stunned_remaining", 0.0)))
	is_alive = bool(stored_state.get("alive", true))


func _ready() -> void:
	add_to_group("combat_creatures")
	_validate_authored_collision_setup()
	_pose = get_node_or_null("StaticCandidatePoseSE") as Sprite2D
	if _pose == null:
		_pose = Sprite2D.new()
		_pose.name = "StaticCandidatePoseSE"
		add_child(_pose)
	ART_LOADER.apply_static_pose(_pose, species_id)
	var footprint_value: Variant = _pose.get_meta("melee_visual_alpha_extents_px", Vector4.ZERO)
	if footprint_value is Vector4 and footprint_value != Vector4.ZERO:
		_visual_extents = footprint_value
	else:
		var legacy_extents := COMBAT_GEOMETRY.creature_visual_alpha_extents(species_id)
		if legacy_extents != Vector4.ZERO:
			_visual_extents = legacy_extents
	_label = Label.new()
	_label.text = display_name
	var label_width := maxf(84.0, display_name.length() * 7.5)
	_label.position = Vector2(-label_width * 0.5, -_visual_extents.w - 24.0)
	_label.size = Vector2(label_width, 20)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.add_theme_font_size_override("font_size", 12)
	_label.add_theme_color_override("font_color", Color("fff0c3"))
	_label.add_theme_color_override("font_shadow_color", Color("171421"))
	_label.add_theme_constant_override("shadow_offset_x", 1)
	_label.add_theme_constant_override("shadow_offset_y", 1)
	add_child(_label)
	if not is_alive:
		queue_free()


func _physics_process(delta: float) -> void:
	if not is_alive or _player == null or not is_instance_valid(_player):
		velocity = Vector2.ZERO
		return
	if bool(_player.get_meta("combat_invisible", false)):
		windup_remaining = 0.0
		velocity = Vector2.ZERO
		_sync_state()
		return
	attack_remaining = maxf(0.0, attack_remaining - delta)
	stunned_remaining = maxf(0.0, stunned_remaining - delta)
	if _inside_refuge(_player.global_position):
		windup_remaining = 0.0
		velocity = Vector2.ZERO
		_move_with_visual_contact(delta)
		_sync_state()
		return
	if windup_remaining > 0.0:
		windup_remaining = maxf(0.0, windup_remaining - delta)
		if windup_remaining > 0.0:
			velocity = Vector2.ZERO
			_move_with_visual_contact(delta)
			_sync_state()
			return
		if windup_remaining == 0.0:
			if attack_damage > 0.0 and is_player_in_basic_attack_range():
				player_damaged.emit(attack_damage, species_id)
			feedback_requested.emit("%s golpeia." % display_name)
			attack_remaining = _attack_interval
			_sync_state()
			return
	if stunned_remaining > 0.0:
		velocity = Vector2.ZERO
		_move_with_visual_contact(delta)
		_sync_state()
		return
	var to_player := _player.global_position - global_position
	var visual_gap := COMBAT_GEOMETRY.projected_visual_surface_gap_px_between(self, _player)
	var fleeing := _behavior == "flee_only" or (_behavior == "skittish" and not provoked)
	if is_player_in_basic_attack_range() and attack_remaining <= 0.0:
		if fleeing:
			velocity = -to_player.normalized() * _move_speed
			_move_with_visual_contact(delta)
			_sync_state()
			return
		velocity = Vector2.ZERO
		_move_with_visual_contact(delta)
		if _attack_style == "heavy":
			windup_remaining = _windup_duration
			feedback_requested.emit("%s prepara um golpe pesado!" % display_name)
		else:
			if attack_damage > 0.0:
				player_damaged.emit(attack_damage, species_id)
			attack_remaining = _attack_interval
		_sync_state()
		return
	var direction := Vector2.ZERO
	if _player_inside_area("DetectionArea") and visual_gap > ATTACK_VISUAL_GAP_TOLERANCE:
		direction = -to_player.normalized() if fleeing else to_player.normalized()
	velocity = direction * _move_speed
	_move_with_visual_contact(delta)
	_sync_state()


func _move_with_visual_contact(delta: float) -> void:
	velocity = COMBAT_GEOMETRY.constrain_velocity_to_visual_contact(self, [_player], velocity, delta)
	move_and_slide()


func melee_visual_alpha_extents_px() -> Vector4:
	return _visual_extents


func is_player_in_basic_attack_range() -> bool:
	if _player == null or not is_instance_valid(_player) or not is_alive:
		return false
	return (
		_player_inside_area("AttackArea")
		and COMBAT_GEOMETRY.projected_visual_surface_gap_px_between(self, _player)
			<= ATTACK_VISUAL_GAP_TOLERANCE
	)


func _validate_authored_collision_setup() -> void:
	var body_shape := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if body_shape == null or body_shape.shape == null or not (body_shape.shape is CapsuleShape2D):
		push_error("A cena de criatura %s precisa de CollisionShape2D com CapsuleShape2D." % name)
	for area_name in ["DetectionArea", "AttackArea"]:
		var area := get_node_or_null(area_name) as Area2D
		var area_shape := area.get_node_or_null("CollisionShape2D") as CollisionShape2D if area != null else null
		if area == null or area_shape == null or area_shape.shape == null or not (area_shape.shape is CircleShape2D):
			push_error("A cena de criatura %s precisa de %s com CollisionShape2D circular." % [name, area_name])


func _player_inside_area(area_name: String) -> bool:
	if _player == null or not is_instance_valid(_player):
		return false
	var area := get_node_or_null(area_name) as Area2D
	if area == null or not area.monitoring:
		return false
	var shape_node := area.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape_node == null or shape_node.disabled or not (shape_node.shape is CircleShape2D):
		return false
	var circle := shape_node.shape as CircleShape2D
	return shape_node.to_local(_player.global_position).length_squared() <= circle.radius * circle.radius


func take_hit(amount: float) -> bool:
	if not is_alive or amount <= 0.0:
		return false
	provoked = true
	var actual := minf(hp, amount)
	hp = maxf(0.0, hp - amount)
	damage_received.emit(actual, global_position + Vector2(0, -48))
	queue_redraw()
	_sync_state()
	if hp <= 0.0:
		is_alive = false
		_sync_state()
		defeated.emit(self, runtime_id)
		return true
	return false


func apply_stun(duration: float) -> void:
	stunned_remaining = maxf(stunned_remaining, duration)
	windup_remaining = 0.0
	_sync_state()


func _inside_refuge(point: Vector2) -> bool:
	return point.distance_to(_refuge_position) <= 142.0


func _sync_state() -> void:
	if _world_state != null and _world_state.is_ready():
		_world_state.update_actor(slot_id, hp, global_position, {
			"alive": is_alive,
			"provoked": provoked,
			"attack_remaining": attack_remaining,
			"windup_remaining": windup_remaining,
			"stunned_remaining": stunned_remaining
		})


func set_selected(value: bool) -> void:
	selected = value
	queue_redraw()


func selection_distance(point: Vector2, zoom: float) -> float:
	# Target the visible body, not just the feet. Keep a minimum touch radius
	# in logical screen pixels at every supported camera zoom.
	var visual_height := _visual_extents.z + _visual_extents.w
	var center := global_position + Vector2(0, (_visual_extents.z - _visual_extents.w) * 0.5)
	var delta := point - center
	var radii := Vector2(maxf(28.0, (_visual_extents.x + _visual_extents.y) * 0.5), maxf(38.0, visual_height * 0.5))
	radii = radii.max(Vector2.ONE * 36.0 / zoom)
	return Vector2(delta.x / radii.x, delta.y / radii.y).length()


func _draw() -> void:
	var width := maxf(64.0, _visual_extents.x + _visual_extents.y)
	if selected:
		draw_texture_rect(HUD_ART.texture("selection_ring"), Rect2(-width * 0.6, -width * 0.25, width * 1.2, width * 0.65), false)
		draw_texture_rect(HUD_ART.texture("target_marker"), Rect2(-8, -_visual_extents.w - 14.0, 16, 14), false)
	if selected or hp < max_hp:
		var point := Vector2(-width / 2.0, -_visual_extents.w - 18.0)
		draw_rect(Rect2(point - Vector2.ONE, Vector2(width + 2, 8)), Color("18191e"))
		draw_rect(Rect2(point, Vector2(width * clampf(hp / max_hp, 0, 1), 6)), Color("d94848"))

