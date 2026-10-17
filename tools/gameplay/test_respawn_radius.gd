extends SceneTree
var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void:
	OS.set_environment("GAMEPLAY_TEST_SAVE_DIR", "user://respawn_radius_%d" % Time.get_ticks_usec())
	call_deferred("run")
func run() -> void:
	var game = load("res://game/scenes/first_island.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	game._player.set_physics_process(false)
	var fox = game._creature_actors["fox_1"]
	var point: Vector2 = game._creature_spawn_specs["fox_1"].position
	fox.take_hit(fox.hp)
	await process_frame
	var record: Dictionary = game._state.actors["fox_1"]
	var now := int(Time.get_unix_time_from_system())
	check(int(record.respawn_at) - now in [14,15], "Respawn delay must be 15 seconds")
	game._player.global_position = point + Vector2(161,0)
	game._tick_respawns()
	check(not record.alive, "Respawn before deadline")
	record.respawn_at = now - 1
	for distance in [0.0, 159.0, 160.0]:
		game._player.global_position = point + Vector2(distance,0)
		game._tick_respawns()
		check(not record.alive, "Respawn within five SQMs")
	game._player.global_position = point + Vector2(161,0)
	game._iso_view.camera.global_position = game._iso_view._camera_position(game._iso_view._player_focus())
	game._tick_respawns()
	check(record.alive, "No respawn beyond five SQMs")
	check(int(record.life) == 2, "Respawn must increment life once")
	game._tick_respawns()
	check(int(record.life) == 2, "Duplicate respawn")
	print("Respawn radius: %d failures" % failures)
	quit(failures)
