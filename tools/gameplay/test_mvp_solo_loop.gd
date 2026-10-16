extends SceneTree
## Headless catalog/state integration test. Saves only to a unique test slot.

const EXPEDITION_STATE = preload("res://game/scripts/save/expedition_state.gd")
const COMBAT_RULES = preload("res://game/scripts/combat/combat_rules.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var root_path := "user://mvp_solo_loop_%d" % Time.get_ticks_usec()
	var state = EXPEDITION_STATE.open_for_character("melissa", root_path)
	if not _expect(state.is_ready(), "Fresh solo save did not initialize."):
		return
	var maximum: Vector2 = state.max_hp_mp()
	if not _expect(maximum == Vector2(200.0, 100.0), "Warrior HP/MP did not match catalog values."):
		return
	for index in range(3):
		if not _expect(state.harvest("herb_first_%d" % index, "herb", 1, 1), "Herb gathering failed."):
			return
	if not _expect(state.harvest("fiber_first", "fiber", 1, 0), "Fiber gathering failed."):
		return
	if not _expect(state.amount("herb") == 3 and state.amount("fiber") == 1, "Harvest quantities were not recorded."):
		return
	if not _expect(state.craft("recipe_bandage"), "Catalog bandage recipe failed."):
		return
	if not _expect(state.amount("herb") == 0 and state.amount("fiber") == 0 and state.amount("bandage") == 1, "Craft did not consume the exact recipe costs."):
		return
	if not _expect(state.total_xp == 13, "Harvest and first-craft XP did not follow the catalog/prototype values."):
		return
	state.take_damage(50.0)
	if not _expect(state.hp == 150.0 and state.start_bandage(), "Damage or bandage start failed."):
		return
	for _second in range(4):
		state.tick_bandage(1.0)
	if not _expect(state.hp == 190.0 and not state.bandages_in_use, "Bandage did not restore 40 HP over four seconds."):
		return
	for index in range(3):
		state.harvest("herb_second_%d" % index, "herb", 1, 1)
	state.harvest("fiber_second", "fiber", 1, 0)
	if not _expect(state.craft("recipe_bandage"), "Second bandage craft failed."):
		return
	state.take_damage(20.0)
	if not _expect(state.start_bandage(), "Second bandage did not start."):
		return
	state.tick_bandage(1.0)
	var partially_healed: float = state.hp
	var canceled := state.cancel_bandage()
	if not _expect(partially_healed == 177.5 and canceled, "Bandage interruption did not preserve partial healing: hp=%s active=%s canceled=%s" % [partially_healed, state.bandages_in_use, canceled]):
		return
	state.tick_bandage(3.0)
	if not _expect(state.hp == partially_healed, "Canceled bandage continued healing."):
		return
	state.register_actor("fox_1", "fox", float(COMBAT_RULES.monster("fox").get("hp", 0)), Vector2(800, 700))
	var death_id := state.actor_instance_id("fox_1")
	var first_reward := state.award_creature(death_id, "fox")
	if not _expect(int(first_reward.get("xp", 0)) == int(COMBAT_RULES.monster("fox").get("xp", 0)), "Fox XP did not match catalog."):
		return
	state.defeat_actor("fox_1")
	var meat_after_reward := state.amount("meat")
	if not _expect(meat_after_reward == 1, "Fox guaranteed meat drop was not awarded."):
		return
	if not _expect(state.award_creature(death_id, "fox").is_empty() and state.amount("meat") == meat_after_reward, "Repeated death event duplicated a reward."):
		return
	if not _expect(state.harvest("camp_wood_30", "wood", 30, 60), "Test wood grant failed."):
		return
	state.harvest("camp_stone_20", "stone", 20, 40)
	state.harvest("camp_fiber_10", "fiber", 10, 0)
	if not _expect(state.upgrade_camp() and state.camp_level == 2, "Catalog level II camp upgrade failed."):
		return
	state.harvest("camp_wood_60", "wood", 60, 120)
	state.harvest("camp_stone_40", "stone", 40, 80)
	state.harvest("camp_fiber_20", "fiber", 20, 0)
	state.harvest("camp_shard_5", "crystal_shard", 5, 0)
	if not _expect(state.upgrade_camp() and state.camp_level == 3, "Catalog level III camp upgrade failed."):
		return
	state.player_position = Vector2(512.125, 700.25)
	state.player_facing = "NW"
	var saved_hp: float = state.hp
	var saved_xp: int = state.total_xp
	var saved_meat: int = state.amount("meat")
	if not _expect(state.save() and state.save(), "Atomic save did not create active and previous slots."):
		return
	var snapshot_path: String = state.snapshot_path()
	var active_file := FileAccess.open(snapshot_path, FileAccess.WRITE)
	if not _expect(active_file != null, "Could not open the isolated test slot for corruption recovery test."):
		return
	active_file.store_string("{\"schema_version\":1,\"revision\":99,\"checksum_sha256\":\"invalid\",\"payload\":{}}")
	active_file.close()
	var recovered = EXPEDITION_STATE.open_for_character("melissa", root_path)
	if not _expect(recovered.is_ready() and recovered.recovered_from.contains("snapshot.previous.json"), "Corrupt active slot did not recover from the validated previous slot."):
		return
	if not _expect(recovered.player_position == Vector2(512.125, 700.25) and recovered.player_facing == "NW", "Player appearance position/facing did not survive save/reload."):
		return
	if not _expect(recovered.hp == saved_hp and recovered.total_xp == saved_xp and recovered.amount("meat") == saved_meat, "Saved combat/reward state did not survive recovery."):
		return
	if not _expect(recovered.award_creature(death_id, "fox").is_empty(), "Recovered death ledger allowed a duplicate fox reward."):
		return
	if not _expect(FileAccess.file_exists(root_path.path_join("snapshot.previous.json")), "Previous test snapshot was not preserved."):
		return
	print("Solo loop state test passed: catalog HP/MP, harvesting, bandage craft/heal/cancel, unique fox reward, camp II/III, checksummed save/reload and previous-slot recovery.")
	quit(0)


func _expect(condition: bool, message: String) -> bool:
	if condition:
		return true
	push_error(message)
	quit(1)
	return false
