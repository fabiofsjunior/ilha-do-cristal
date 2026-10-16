class_name CreatureActor
extends CharacterBody2D

signal player_damaged(amount: float, species_id: String)
signal feedback_requested(message: String)
signal defeated(actor: CreatureActor, death_id: String)

const ART_LOADER = preload("res://game/scripts/actors/creature_art_loader.gd")

const MOVE_SPEEDS := {"fox": 116.0, "wolf": 92.0, "bear": 39.0}
const ATTACK_INTERVALS := {"fox": 2.0, "wolf": 1.8, "bear": 3.0}
const AGGRO_RANGES := {"fox": 0.0, "wolf": 190.0, "bear": 170.0}
const ATTACK_RANGES := {"fox": 44.0, "wolf": 48.0, "bear": 50.0}
const BEAR_WINDUP := 0.9

var slot_id := ""
var runtime_id := ""
var species_id := "fox"
var display_name := "Raposa"
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
var _pose: Sprite2D


func configure(
	spawn_slot_id: String,
	creature_data: Dictionary,
	state: ExpeditionState,
	player: CharacterBody2D,
	refuge_position: Vector2,
	stored_state: Dictionary,
	instance_id: String
) -> void:
	slot_id = spawn_slot_id
	runtime_id = instance_id
	species_id = str(creature_data.get("id", "fox"))
	max_hp = float(creature_data.get("hp", 1))
	attack_damage = float(creature_data.get("attack", 1))
	_world_state = state
	_player = player
	_refuge_position = refuge_position
	var names := {"fox": "Raposa", "wolf": "Lobo", "bear": "Urso"}
	display_name = str(names.get(species_id, species_id.capitalize()))
	hp = clampf(float(stored_state.get("hp", max_hp)), 0.0, max_hp)
	var position_data: Array = stored_state.get("position", [0.0, 0.0])
	position = Vector2(float(position_data[0]), float(position_data[1]))
	provoked = bool(stored_state.get("provoked", false))
	attack_remaining = maxf(0.0, float(stored_state.get("attack_remaining", 0.0)))
	windup_remaining = maxf(0.0, float(stored_state.get("windup_remaining", 0.0)))
	stunned_remaining = maxf(0.0, float(stored_state.get("stunned_remaining", 0.0)))
	is_alive = bool(stored_state.get("alive", true))


func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	var collision := CollisionShape2D.new()
	var shape := CapsuleShape2D.new()
	shape.radius = 9.0 if species_id != "bear" else 17.0
	shape.height = 22.0 if species_id != "bear" else 34.0
	collision.shape = shape
	collision.position.y = -1.0
	add_child(collision)
	_pose = Sprite2D.new()
	_pose.name = "StaticCandidatePoseSE"
	add_child(_pose)
	ART_LOADER.apply_static_pose(_pose, species_id)
	_label = Label.new()
	_label.text = display_name
	_label.position = Vector2(-42, -44 if species_id != "bear" else -64)
	_label.size = Vector2(84, 20)
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
	attack_remaining = maxf(0.0, attack_remaining - delta)
	stunned_remaining = maxf(0.0, stunned_remaining - delta)
	if _inside_refuge(_player.global_position):
		windup_remaining = 0.0
		velocity = Vector2.ZERO
		move_and_slide()
		_sync_state()
		return
	if windup_remaining > 0.0:
		windup_remaining = maxf(0.0, windup_remaining - delta)
		if windup_remaining == 0.0:
			if global_position.distance_to(_player.global_position) <= float(ATTACK_RANGES.get(species_id, 44.0)) + 8.0:
				player_damaged.emit(attack_damage, species_id)
			feedback_requested.emit("O urso golpeia o chão.")
			attack_remaining = float(ATTACK_INTERVALS.get(species_id, 2.0))
			_sync_state()
			return
	if stunned_remaining > 0.0:
		velocity = Vector2.ZERO
		move_and_slide()
		_sync_state()
		return
	var to_player := _player.global_position - global_position
	var distance := to_player.length()
	var attack_range := float(ATTACK_RANGES.get(species_id, 44.0))
	if distance <= attack_range and attack_remaining <= 0.0:
		if species_id == "fox" and not provoked:
			velocity = -to_player.normalized() * float(MOVE_SPEEDS.get(species_id, 60.0))
			move_and_slide()
			_sync_state()
			return
		if species_id == "bear":
			windup_remaining = BEAR_WINDUP
			feedback_requested.emit("O urso prepara um golpe pesado!")
		else:
			player_damaged.emit(attack_damage, species_id)
			attack_remaining = float(ATTACK_INTERVALS.get(species_id, 2.0))
		_sync_state()
		return
	var direction := Vector2.ZERO
	if species_id == "fox":
		if distance <= 150.0 and distance > attack_range:
			direction = -to_player.normalized()
	elif distance <= float(AGGRO_RANGES.get(species_id, 0.0)) and distance > attack_range - 5.0:
		direction = to_player.normalized()
	velocity = direction * float(MOVE_SPEEDS.get(species_id, 60.0))
	move_and_slide()
	_sync_state()


func take_hit(amount: float) -> bool:
	if not is_alive or amount <= 0.0:
		return false
	provoked = true
	hp = maxf(0.0, hp - amount)
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
