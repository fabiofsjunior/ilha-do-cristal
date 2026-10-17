extends SceneTree
## Regression: downed timer, public ally-revive entry point, exact bag penalty,
## respawn UI action, and persistent/recoverable bags.

const EXPEDITION_STATE = preload("res://game/scripts/save/expedition_state.gd")

var failures := 0


func _initialize() -> void:
	OS.set_environment("GAMEPLAY_TEST_SAVE_DIR", "user://death_revive_%d" % Time.get_ticks_usec())
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(720, 1280)
	var save_root := OS.get_environment("GAMEPLAY_TEST_SAVE_DIR")
	var game = load("res://game/scenes/first_island.tscn").instantiate()
	root.add_child(game)
	await process_frame
	var state = game._state
	var hud = game.get_node("HUD")
	if not _check(state.is_ready(), "Death/revive test save did not initialize."):
		quit(failures)
		return
	_check(state.harvest("death_wood_5", "wood", 5, 0), "Could not grant test wood.")
	_check(state.harvest("death_stone_2", "stone", 2, 0), "Could not grant test stone.")
	state.add_xp(100)
	state.inventory["sword_basic"] = 1
	state.mp = 37.0
	var saved_xp: int = state.total_xp
	var max_hp: float = state.max_hp_mp().x

	# Lethal damage begins the full 60-second downed window and shows real losses.
	game._on_player_damaged(state.hp, "Teste")
	_check(is_equal_approx(state.downed_remaining, 60.0), "A lethal hit did not start the 60-second timer.")
	_check(not game._player.input_enabled, "Downed player can still move.")
	_check(hud._downed_shade.visible and hud._downed_panel.is_visible_in_tree(), "Downed dialog is not visible.")
	_check(hud._downed_label.text.contains("60 s"), "Downed dialog does not show the 60-second revive window.")
	_check(hud._downed_penalty_label.text.contains("2 madeira") and hud._downed_penalty_label.text.contains("1 pedra"), "Downed dialog does not show the exact recoverable penalty.")
	_check(hud._downed_penalty_label.text.contains("arredondados para baixo"), "Downed dialog does not explain per-material rounding.")
	_check(hud._downed_revive_label.text.contains("ainda não tem co-op"), "Solo UI implies an ally is connected.")
	_check(hud._downed_respawn_button.text == "Renascer no acampamento", "Respawn button label does not match the requested action.")
	_check(state.amount("wood") == 5 and state.amount("stone") == 2, "Penalty was applied before respawn.")

	# Session host API emits an explicit start signal and completes after five seconds.
	var started: Array = []
	var completed: Array = []
	var cancelled: Array = []
	game.ally_revive_started.connect(func(reviver_id: String, duration: float) -> void: started.append([reviver_id, duration]))
	game.ally_revive_completed.connect(func(reviver_id: String) -> void: completed.append(reviver_id))
	game.ally_revive_cancelled.connect(func(reviver_id: String) -> void: cancelled.append(reviver_id))
	_check(not game.request_ally_revive(""), "Revive API accepted an empty ally ID.")
	_check(game.request_ally_revive("peer-2"), "Revive API rejected a valid caller during the downed window.")
	_check(started.size() == 1 and started[0][0] == "peer-2" and is_equal_approx(float(started[0][1]), 5.0), "Revive start signal did not expose the ally ID and five-second duration.")
	var reconnect_state = EXPEDITION_STATE.open_for_character("melissa", save_root)
	_check(reconnect_state.is_ready() and is_equal_approx(reconnect_state.downed_remaining, 60.0), "Downed deadline did not persist across reopen.")
	_check(reconnect_state.ally_revive_remaining < 0.0 and reconnect_state.ally_reviver_id.is_empty(), "Reopening the save restored a stale connected ally action.")
	_check(not game.cancel_ally_revive("peer-3"), "Revive cancellation accepted the wrong ally ID.")
	_check(game.cancel_ally_revive("peer-2") and cancelled == ["peer-2"], "Session host could not cancel the disconnected ally action.")
	_check(state.downed_remaining > 59.0 and state.ally_revive_remaining < 0.0, "Canceling revive changed the downed deadline or left it active.")
	_check(game.request_ally_revive("peer-2"), "A new ally could not begin a revive after cancellation.")
	_check(not game.request_ally_revive("peer-3"), "Revive API accepted a second concurrent reviver.")
	game._process(4.99)
	_check(state.downed_remaining > 55.0 and state.ally_revive_remaining > 0.0, "Revive completed before five seconds.")
	_check(state.amount("wood") == 5 and state.amount("stone") == 2 and state.persistent_bags.is_empty(), "Revive applied the camp-respawn penalty.")
	game._process(0.02)
	_check(state.downed_remaining < 0.0 and game._player.input_enabled, "Completed revive did not restore active control.")
	_check(completed == ["peer-2"], "Revive completion signal did not identify the ally.")
	_check(absf(state.hp - max_hp * 0.30) < 0.1, "Revive did not restore the documented provisional 30% HP.")
	_check(absf(state.mp - 37.0) < 0.1, "Revive changed current MP.")
	_check(state.total_xp == saved_xp and state.amount("sword_basic") == 1, "Revive removed XP or equipment.")
	_check(not hud._downed_shade.visible, "Revive left the downed overlay visible.")

	# The explicit button applies the exact penalty, leaves one persistent bag,
	# and saves it so a recovered snapshot can claim its contents.
	game._on_player_damaged(state.hp, "Teste")
	_check(hud._downed_respawn_button.text == "Renascer no acampamento", "Respawn action disappeared on a later downed event.")
	hud._downed_respawn_button.emit_signal("pressed")
	_check(state.downed_remaining < 0.0 and game._player.input_enabled, "Respawn button did not return control to the player.")
	_check(game._player.global_position.distance_to(game._beacon_position + Vector2(64.0, 36.0)) < 0.1, "Respawn button did not place the player at camp.")
	_check(state.amount("wood") == 3 and state.amount("stone") == 1, "Respawn did not remove exactly the previewed quantities.")
	_check(state.persistent_bags.size() == 1 and state.persistent_bags[0].items == {"wood": 2, "stone": 1}, "Respawn bag does not contain the exact penalty.")
	_check(state.total_xp == saved_xp and state.amount("sword_basic") == 1, "Camp respawn removed XP or equipment.")
	_check(hud._status.text.contains("2 madeira") and hud._status.text.contains("1 pedra"), "Respawn status did not confirm the actual bag contents.")
	var recovered = EXPEDITION_STATE.open_for_character("melissa", save_root)
	_check(recovered.is_ready() and recovered.persistent_bags.size() == 1, "Persistent bag did not survive save/reload.")
	var recovered_items: Dictionary = recovered.claim_persistent_bag("downed_bag_0")
	_check(int(recovered_items.get("wood", 0)) == 2 and int(recovered_items.get("stone", 0)) == 1, "Recovered bag did not yield the exact dropped materials.")
	_check(recovered.amount("wood") == 5 and recovered.amount("stone") == 2, "Claiming the bag did not restore its items.")
	_check(recovered.persistent_bags[0].claimed, "Claimed bag was not marked as claimed.")
	var first_bag_position: Array = state.persistent_bags[0].position
	game._player.global_position = Vector2(float(first_bag_position[0]), float(first_bag_position[1]))
	game.interact_with_nearest()
	_check(state.persistent_bags[0].claimed and state.amount("wood") == 5 and state.amount("stone") == 2, "In-world interaction did not recover the persistent bag.")
	_check(hud._status.text.contains("Materiais recuperados"), "In-world bag recovery did not report the recovered contents.")

	# No ally means the full deadline expires into camp respawn. An older bag is
	# retained when a later death creates another bag. Recovered materials do
	# not count as newly collected for a future death.
	_check(state.harvest("later_wood_4", "wood", 4, 0), "Could not grant post-respawn wood.")
	game._on_player_damaged(state.hp, "Teste")
	game._process(59.0)
	_check(is_equal_approx(state.downed_remaining, 1.0), "Downed deadline did not count down from 60 seconds.")
	_check(hud._downed_label.text.contains("01 s"), "HUD countdown did not reflect the remaining second.")
	game._process(1.0)
	_check(state.downed_remaining < 0.0 and game._player.input_enabled, "Deadline expiry did not automatically respawn at camp.")
	_check(game._player.global_position.distance_to(game._beacon_position + Vector2(64.0, 36.0)) < 0.1, "Automatic respawn did not place the player at camp.")
	_check(state.persistent_bags.size() == 2, "A later death replaced the earlier persistent bag.")
	_check(state.persistent_bags[0].claimed and state.persistent_bags[1].items == {"wood": 2}, "A later death replaced the earlier claimed bag record or stored the wrong contents.")
	_check(state.amount("wood") == 7 and state.amount("stone") == 2, "Second death penalty included previously recovered materials or used the wrong amount.")
	var final_recovery = EXPEDITION_STATE.open_for_character("melissa", save_root)
	_check(final_recovery.is_ready() and final_recovery.persistent_bags.size() == 2, "Both bags were not persisted after the later automatic respawn.")

	if failures == 0:
		print("Death/revive passed: 60-second deadline, solo UI/API boundary, five-second ally revive, 30% HP, exact persistent penalty, manual/automatic respawn, save/reload and bag recovery.")
	game.queue_free()
	await process_frame
	quit(failures)


func _check(condition: bool, message: String) -> bool:
	if condition:
		return true
	failures += 1
	push_error(message)
	return false
