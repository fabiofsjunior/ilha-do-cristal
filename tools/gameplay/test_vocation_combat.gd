extends SceneTree
var failures := 0
func check(value: bool, message: String) -> void:
	if not value:
		failures += 1
		push_error(message)
func _initialize() -> void:
	OS.set_environment("GAMEPLAY_TEST_SAVE_DIR", "user://vocation_combat_%d" % Time.get_ticks_usec())
	call_deferred("run")
func run() -> void:
	var game = load("res://game/scenes/first_island.tscn").instantiate()
	game.selected_vocation_id = "mage"
	root.add_child(game)
	await process_frame
	game.set_process(false)
	game._auto_attack_enabled = false
	game._player.global_position = Vector2(1200, 1200)
	var actor = game._creature_actors.values()[0]
	actor.set_physics_process(false)
	actor.global_position = Vector2(1250, 1200)
	actor.hp = 10000
	actor.max_hp = 10000
	game._set_target(actor)
	var before: float = actor.hp
	game._use_skill("mag_bolt")
	check(is_equal_approx(actor.hp, before - 15), "Mage bolt failed to hit for staff magic damage")
	check(game._state.mp == 192 and game._state.skill_cooldowns.mag_bolt == 5, "Bolt mana or cooldown wrong")
	game._use_skill("mag_bolt")
	check(actor.hp == before - 15 and game._state.mp == 192, "Cooldown accepted duplicate cast")
	game._use_skill("mag_fire")
	check(game._burns.has(actor.runtime_id), "Fire failed to apply burn")
	var fire_hp: float = actor.hp
	game._tick_burns(1)
	check(is_equal_approx(actor.hp, fire_hp - 0.5), "Fire periodic damage wrong")
	game._state.vocation_id = "archer"
	game._state.mp = 150
	game._use_skill("arc_precise")
	check(bool(game._player.get_meta("combat_invisible", false)), "Precise shot did not enter invisibility")
	check(game._state.mp == 140, "Precise shot charged wrong mana")
	var precise_hp: float = actor.hp
	game._fire_precise_shot()
	check(not bool(game._player.get_meta("combat_invisible", true)), "Precise shot kept invisibility")
	check(is_equal_approx(actor.hp, precise_hp - 10), "Precise shot damage wrong")
	check(game._state.mp == 140, "Precise shot charged twice")
	game._use_skill("arc_pierce")
	check(game._speed_boost_remaining == 6, "Pierce failed to give speed bonus")
	game._state.vocation_id = "warrior"
	actor.global_position = Vector2(1260, 1200)
	var war_hp: float = actor.hp
	game._use_skill("war_combo")
	check(is_equal_approx(actor.hp, war_hp - 43.2), "Warrior combo did not hit at expanded 60px range")
	# Exercise projected VFX draw as well as construction.
	await process_frame
	await process_frame
	print("Vocation world combat: %d failures" % failures)
	game.queue_free()
	await process_frame
	quit(failures)
