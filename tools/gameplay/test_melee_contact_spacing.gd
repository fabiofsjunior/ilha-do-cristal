extends SceneTree
## Regression: visual alpha footprints stop both approaches without changing
## navigation capsules; basic attacks work at visible and physical contact.

const MAIN = preload("res://game/scenes/main.tscn")
const PLAYER_SCENE = preload("res://game/scenes/player.tscn")
const CREATURE_ACTOR = preload("res://game/scripts/combat/creature_actor.gd")
const CREATURE_SCENES := {
	"fox": preload("res://game/scenes/creatures/fox.tscn"),
	"wolf": preload("res://game/scenes/creatures/wolf.tscn"),
	"bear": preload("res://game/scenes/creatures/bear.tscn")
}
const COMBAT_GEOMETRY = preload("res://game/scripts/combat/combat_geometry.gd")
const FOOTPRINTS_PATH := "res://game/data/melee_visual_footprints.json"

var failures := 0


func _initialize() -> void:
	OS.set_environment("GAMEPLAY_TEST_SAVE_DIR", "user://melee_spacing_%d" % Time.get_ticks_usec())
	call_deferred("_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)


func _settle_physics(frames: int) -> void:
	for _frame in range(frames):
		await physics_frame
		await process_frame


func _run() -> void:
	await _test_authored_shapes_are_preserved()
	await _test_player_approach_for_each_species()
	await _test_profile_direction_contact_window()
	await _test_monster_approach_to_player()
	await _test_combat_contact_and_unchanged_skill_range()
	if failures == 0:
		print("PASS melee: profile/facing alpha footprints stop both approaches within 1 px; fox/wolf/bear attacks wait until within 2 px; world capsules stay unchanged; sword stays at 1 SQM and war_quake still hits at 100 px")
	quit(0 if failures == 0 else 1)


func _new_player(at: Vector2) -> CharacterBody2D:
	var player := PLAYER_SCENE.instantiate() as CharacterBody2D
	player.position = at
	root.add_child(player)
	return player


func _new_creature(
	player: CharacterBody2D,
	species: String,
	at: Vector2,
	authored_overrides: Dictionary = {}
) -> CreatureActor:
	var creature_scene := CREATURE_SCENES.get(species) as PackedScene
	if creature_scene == null:
		push_error("Missing creature scene fixture for %s." % species)
		return null
	var creature := creature_scene.instantiate() as CreatureActor
	var hp := 240 if species == "bear" else (35 if species == "fox" else 90)
	var attack := 22 if species == "bear" else (5 if species == "fox" else 12)
	if authored_overrides.has("body_radius"):
		var body_collision := creature.get_node("CollisionShape2D") as CollisionShape2D
		var body_shape := (body_collision.shape as CapsuleShape2D).duplicate() as CapsuleShape2D
		body_shape.radius = float(authored_overrides.body_radius)
		body_shape.height = 22.0
		body_collision.shape = body_shape
	if authored_overrides.has("detection_radius"):
		var detection_collision := creature.get_node("DetectionArea/CollisionShape2D") as CollisionShape2D
		var detection_shape := (detection_collision.shape as CircleShape2D).duplicate() as CircleShape2D
		detection_shape.radius = float(authored_overrides.detection_radius)
		detection_collision.shape = detection_shape
	if authored_overrides.has("attack_radius"):
		var attack_collision := creature.get_node("AttackArea/CollisionShape2D") as CollisionShape2D
		var attack_shape := (attack_collision.shape as CircleShape2D).duplicate() as CircleShape2D
		attack_shape.radius = float(authored_overrides.attack_radius)
		attack_collision.shape = attack_shape
	if authored_overrides.has("collision_layer"):
		creature.collision_layer = int(authored_overrides.collision_layer)
	if authored_overrides.has("collision_mask"):
		creature.collision_mask = int(authored_overrides.collision_mask)
	creature.configure(
		"test_%s" % species,
		{"id": species, "hp": hp, "attack": attack},
		null,
		player,
		Vector2(10000, 10000),
		{"position": [at.x, at.y], "provoked": true, "attack_remaining": 30.0},
		"test-%s-runtime" % species
	)
	root.add_child(creature)
	return creature


func _test_authored_shapes_are_preserved() -> void:
	var player := _new_player(Vector2(100, 100))
	var index := 0
	for species in ["fox", "wolf", "bear"]:
		var creature := _new_creature(
			player,
			species,
			Vector2(400 + 200 * index, 100),
			{"body_radius": 10.0, "detection_radius": 27.0, "attack_radius": 42.0, "collision_layer": 8, "collision_mask": 4}
		)
		index += 1
		if creature == null:
			continue
		creature.set_physics_process(false)
		await _settle_physics(2)
		var body_collision := creature.get_node("CollisionShape2D") as CollisionShape2D
		var body_shape := body_collision.shape as CapsuleShape2D
		var detection_collision := creature.get_node("DetectionArea/CollisionShape2D") as CollisionShape2D
		var attack_collision := creature.get_node("AttackArea/CollisionShape2D") as CollisionShape2D
		var detection_shape := detection_collision.shape as CircleShape2D
		var attack_shape := attack_collision.shape as CircleShape2D
		_check(is_equal_approx(body_shape.radius, 10.0), "%s authored body radius was replaced during ready." % species)
		_check(is_equal_approx(detection_shape.radius, 27.0), "%s authored detection radius was replaced during ready." % species)
		_check(is_equal_approx(attack_shape.radius, 42.0), "%s authored attack radius was replaced during ready." % species)
		_check(creature.collision_layer == 8 and creature.collision_mask == 4, "%s authored body layers were replaced during ready." % species)
		player.global_position = creature.global_position + Vector2(20, 0)
		_check(bool(creature.call("_player_inside_area", "DetectionArea")), "%s detection area ignored its authored radius." % species)
		_check(bool(creature.call("_player_inside_area", "AttackArea")), "%s attack area ignored its authored radius." % species)
		player.global_position = creature.global_position + Vector2(30, 0)
		_check(not bool(creature.call("_player_inside_area", "DetectionArea")), "%s detection area exceeded its authored radius." % species)
		_check(bool(creature.call("_player_inside_area", "AttackArea")), "%s attack area ignored its authored radius." % species)
		player.global_position = creature.global_position + Vector2(43, 0)
		_check(not bool(creature.call("_player_inside_area", "AttackArea")), "%s attack area exceeded its authored radius." % species)
		creature.queue_free()
	player.queue_free()
	await process_frame


func _set_capsule_contact(player: CharacterBody2D, creature: CreatureActor) -> void:
	var player_shape := player.get_node("CollisionShape2D") as CollisionShape2D
	var creature_shape := creature.get_node("CollisionShape2D") as CollisionShape2D
	var player_radius := (player_shape.shape as CapsuleShape2D).radius
	var creature_radius := (creature_shape.shape as CapsuleShape2D).radius
	creature.global_position = player.global_position + Vector2(player_radius + creature_radius, 0.0)


func _test_player_approach_for_each_species() -> void:
	for species in ["fox", "wolf", "bear"]:
		var player := _new_player(Vector2(100, 100))
		var creature := _new_creature(player, species, Vector2(300, 100))
		await _settle_physics(3)
		creature.set_physics_process(false)
		player.call("set_joystick_vector", Vector2.RIGHT)
		await _settle_physics(120)
		player.call("set_joystick_vector", Vector2.ZERO)
		await _settle_physics(2)

		var visual_gap := COMBAT_GEOMETRY.projected_visual_surface_gap_px_between(player, creature)
		var capsule_gap := COMBAT_GEOMETRY.surface_gap_between(player, creature)
		var player_shape := player.get_node("CollisionShape2D") as CollisionShape2D
		var creature_shape := creature.get_node("CollisionShape2D") as CollisionShape2D
		var expected_creature_radius := 17.0 if species == "bear" else 9.0
		_check((player.collision_mask & 2) != 0, "Player mask must continue to include the creature collision layer")
		_check((player_shape.shape as CapsuleShape2D).radius == 10.0, "Player navigation collider must stay at its authored 10 px radius")
		_check((creature_shape.shape as CapsuleShape2D).radius == expected_creature_radius, "%s navigation collider must stay unchanged" % species)
		_check(visual_gap >= 0.0 and visual_gap <= 2.0, "%s player approach must stop without alpha overlap, near the 1 px margin; got %0.2f" % [species, visual_gap])
		_check(capsule_gap > 30.0, "%s must stop by alpha footprint without inflating the world collider" % species)
		_check(visual_gap <= 32.0, "%s contact must remain inside the sword's catalogued 1 SQM surface reach" % species)
		_check(creature.is_player_in_basic_attack_range(), "%s must be able to basic-attack at the visible stop point" % species)
		player.queue_free()
		creature.queue_free()
		await process_frame


func _test_profile_direction_contact_window() -> void:
	var player := _new_player(Vector2(400, 400))
	player.set_physics_process(false)
	var creatures: Dictionary = {}
	for index in range(3):
		var species: String = ["fox", "wolf", "bear"][index]
		creatures[species] = _new_creature(player, species, Vector2(900 + index * 100, 400))
	await process_frame
	for actor in creatures.values():
		(actor as CreatureActor).set_physics_process(false)
	var footprint_data = JSON.parse_string(FileAccess.get_file_as_string(FOOTPRINTS_PATH))
	var expected_by_profile: Dictionary = footprint_data.get("player_alpha_extents_by_profile_and_facing", {})
	var directions := {
		"N": Vector2(0, -1),
		"NE": Vector2(1, -1),
		"E": Vector2(1, 0),
		"SE": Vector2(1, 1),
		"S": Vector2(0, 1),
		"SW": Vector2(-1, 1),
		"W": Vector2(-1, 0),
		"NW": Vector2(-1, -1),
	}
	var attack_gap_tolerance := float(CREATURE_ACTOR.ATTACK_VISUAL_GAP_TOLERANCE)
	for profile in ["melissa", "helena", "maira", "fabio"]:
		player.selected_character_id = profile
		player._build_animations()
		for facing in directions:
			player.facing = facing
			player._play("idle_" + facing)
			var actual_extents: Vector4 = player.melee_visual_alpha_extents_px()
			var expected_values: Array = expected_by_profile.get(profile, {}).get(facing, [])
			var expected_extents := Vector4(
				float(expected_values[0]), float(expected_values[1]),
				float(expected_values[2]), float(expected_values[3])
			)
			_check(actual_extents.is_equal_approx(expected_extents), "%s %s must use its visible alpha footprint" % [profile, facing])
			for species in ["fox", "wolf", "bear"]:
				var creature := creatures[species] as CreatureActor
				var direction: Vector2 = directions[facing]
				var unit_direction := direction.normalized()
				var stop_distance := COMBAT_GEOMETRY.visual_contact_distance(
					player, creature, direction, COMBAT_GEOMETRY.visual_footprint_margin_px()
				)
				var original_player_position := player.global_position
				creature.global_position = original_player_position + unit_direction * (stop_distance + 5.0)
				var player_velocity := COMBAT_GEOMETRY.constrain_velocity_to_visual_contact(
					player, [creature], unit_direction * 100.0, 0.2
				)
				player.global_position = original_player_position + player_velocity * 0.2
				var player_stop_gap := COMBAT_GEOMETRY.projected_visual_surface_gap_px_between(player, creature)
				_check(player_stop_gap >= -0.05 and player_stop_gap <= 1.1, "%s %s player blocking must stop at alpha contact; got %0.2f px" % [species, facing, player_stop_gap])
				player.global_position = original_player_position
				var creature_velocity := COMBAT_GEOMETRY.constrain_velocity_to_visual_contact(
					creature, [player], -unit_direction * 100.0, 0.2
				)
				creature.global_position += creature_velocity * 0.2
				var creature_stop_gap := COMBAT_GEOMETRY.projected_visual_surface_gap_px_between(player, creature)
				_check(creature_stop_gap >= -0.05 and creature_stop_gap <= 1.1, "%s %s creature blocking must stop at alpha contact; got %0.2f px" % [species, facing, creature_stop_gap])
				creature.global_position = player.global_position + direction.normalized() * stop_distance
				var contact_gap := COMBAT_GEOMETRY.projected_visual_surface_gap_px_between(player, creature)
				_check(contact_gap >= -0.05 and contact_gap <= 1.1, "%s %s stop should match visible contact; got %0.2f px" % [species, facing, contact_gap])
				_check(creature.is_player_in_basic_attack_range(), "%s %s must attack at visible contact" % [species, facing])
				var outside_distance := COMBAT_GEOMETRY.visual_contact_distance(
					player, creature, direction, attack_gap_tolerance + 1.0
				)
				creature.global_position = player.global_position + direction.normalized() * outside_distance
				var outside_gap := COMBAT_GEOMETRY.projected_visual_surface_gap_px_between(player, creature)
				_check(outside_gap > attack_gap_tolerance, "%s %s attack began before alpha contact; got %0.2f px" % [species, facing, outside_gap])
				_check(not creature.is_player_in_basic_attack_range(), "%s %s must not attack beyond the 2 px contact window" % [species, facing])
	player.queue_free()
	for actor in creatures.values():
		(actor as CreatureActor).queue_free()
	await process_frame


func _test_monster_approach_to_player() -> void:
	for species in ["wolf", "bear"]:
		var player := _new_player(Vector2(100, 100))
		player.call("set_input_enabled", false)
		var start_distance := 150.0 if species == "bear" else 170.0
		var creature := _new_creature(player, species, player.global_position + Vector2(start_distance, 0.0))
		await _settle_physics(3)
		await _settle_physics(150)
		var visual_gap := COMBAT_GEOMETRY.projected_visual_surface_gap_px_between(creature, player)
		_check(visual_gap >= 0.0 and visual_gap <= 2.0, "%s approach must stop without alpha overlap, near the 1 px margin; got %0.2f" % [species, visual_gap])
		_check(creature.is_player_in_basic_attack_range(), "%s could not basic-attack after approaching visual contact" % species)
		_check(COMBAT_GEOMETRY.visual_surface_gap_between(player, creature) <= 32.0, "Player-side one-SQM melee must also allow %s contact" % species)
		player.queue_free()
		creature.queue_free()
		await process_frame


func _test_combat_contact_and_unchanged_skill_range() -> void:
	var app := MAIN.instantiate()
	root.add_child(app)
	await _settle_physics(4)
	app.current_screen.begin_requested.emit()
	await _settle_physics(4)
	app.current_screen.confirm_requested.emit("melissa")
	await _settle_physics(4)
	app.current_screen.host_solo_requested.emit()
	await _settle_physics(8)
	if app.gameplay == null:
		_check(false, "Solo flow failed to create gameplay for melee contact regression")
		app.queue_free()
		await process_frame
		return

	var game = app.gameplay
	game.set_physics_process(false)
	var player: CharacterBody2D = game.get("_player")
	var wolf: CreatureActor = game.get("_creature_actors").get("wolf_1")
	if player == null or wolf == null:
		_check(false, "Gameplay test could not find player and wolf_1")
	else:
		player.set_physics_process(false)
		for actor in game.get("_creature_actors").values():
			actor.set_physics_process(false)
		player.global_position = game.get("_beacon_position") + Vector2(400, 0)
		var contact_distance := COMBAT_GEOMETRY.visual_contact_distance(player, wolf, Vector2.RIGHT, 1.0)
		wolf.global_position = player.global_position + Vector2(contact_distance, 0)
		game._set_target(wolf)
		_check(game.player_basic_attack_can_reach(wolf), "Game basic attack must reach a target at visible alpha contact")
		_check(wolf.is_player_in_basic_attack_range(), "Monster basic attack must reach the player at visible alpha contact")
		var hp_before := wolf.hp
		game._perform_basic_attack()
		_check(wolf.hp < hp_before, "Player basic attack must actually deal damage at visible contact")
		var player_state = game.get("_state")
		var player_hp_before := float(player_state.hp)
		wolf.attack_remaining = 0.0
		wolf.provoked = true
		wolf._physics_process(1.0 / 60.0)
		_check(float(player_state.hp) < player_hp_before, "Monster basic attack must actually damage the player at visible contact")

		var beyond_one_sqm := contact_distance + 32.25
		wolf.global_position = player.global_position + Vector2(beyond_one_sqm, 0)
		_check(not game.player_basic_attack_can_reach(wolf), "Sword reach must stay capped at one SQM beyond the visible alpha boundary")

		_set_capsule_contact(player, wolf)
		_check(absf(COMBAT_GEOMETRY.surface_gap_between(player, wolf)) <= 0.05, "Capsule contact fixture must match the original physical hitboxes")
		_check(game.player_basic_attack_can_reach(wolf), "Physical capsule contact must still permit the player's basic attack")
		_check(wolf.is_player_in_basic_attack_range(), "Physical capsule contact must still permit the monster's basic attack")

		wolf.global_position = player.global_position + Vector2(100, 0)
		game._set_target(wolf)
		var previous_hp := wolf.hp
		game._use_skill("war_quake")
		_check(wolf.hp < previous_hp, "war_quake must retain its existing 112 px center-radius hit at 100 px")

	app.queue_free()
	await process_frame
