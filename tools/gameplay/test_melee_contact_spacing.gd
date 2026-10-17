extends SceneTree
## Regression: visual alpha footprints stop both approaches without changing
## navigation capsules; basic attacks work at visible and physical contact.

const MAIN = preload("res://game/scenes/main.tscn")
const PLAYER_SCENE = preload("res://game/scenes/player.tscn")
const CREATURE_ACTOR = preload("res://game/scripts/combat/creature_actor.gd")
const COMBAT_GEOMETRY = preload("res://game/scripts/combat/combat_geometry.gd")

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
	await _test_player_approach_for_each_species()
	await _test_monster_approach_to_player()
	await _test_combat_contact_and_unchanged_skill_range()
	if failures == 0:
		print("PASS melee: alpha-based footprints stop both approaches; world capsules stay unchanged; both basic attacks work at visible/physical contact; sword stays at 1 SQM and war_quake still hits at 100 px")
	quit(0 if failures == 0 else 1)


func _new_player(at: Vector2) -> CharacterBody2D:
	var player := PLAYER_SCENE.instantiate() as CharacterBody2D
	player.position = at
	root.add_child(player)
	return player


func _new_creature(player: CharacterBody2D, species: String, at: Vector2) -> CreatureActor:
	var creature := CREATURE_ACTOR.new() as CreatureActor
	var hp := 240 if species == "bear" else (35 if species == "fox" else 90)
	var attack := 22 if species == "bear" else (5 if species == "fox" else 12)
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
		_check(visual_gap >= 0.0 and visual_gap <= 8.0, "%s player approach must stop without alpha overlap, near the 4 px margin; got %0.2f" % [species, visual_gap])
		_check(capsule_gap > 30.0, "%s must stop by alpha footprint without inflating the world collider" % species)
		_check(visual_gap <= 32.0, "%s contact must remain inside the sword's catalogued 1 SQM surface reach" % species)
		_check(creature.is_player_in_basic_attack_range(), "%s must be able to basic-attack at the visible stop point" % species)
		player.queue_free()
		creature.queue_free()
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
		_check(visual_gap >= 0.0 and visual_gap <= 8.0, "%s approach must stop without alpha overlap, near the 4 px margin; got %0.2f" % [species, visual_gap])
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
		var contact_distance := COMBAT_GEOMETRY.visual_contact_distance(player, wolf, Vector2.RIGHT)
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
