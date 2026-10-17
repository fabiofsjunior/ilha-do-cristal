extends SceneTree
## Regression: level-ups restore resources and survive the existing save format.

const EXPEDITION_STATE = preload("res://game/scripts/save/expedition_state.gd")
const COMBAT_RULES = preload("res://game/scripts/combat/combat_rules.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var root_path := "user://level_up_restores_resources_%d" % Time.get_ticks_usec()
	var state = EXPEDITION_STATE.open_for_character("melissa", root_path)
	if not _expect(state.is_ready(), "Isolated save did not initialize."):
		return

	# Include applied attributes and a non-default vocation in the expected maxima.
	state.vocation_id = "mage"
	state.raw_attributes = {"FOR": 4, "AGI": 2, "INT": 3}
	var expected_max: Vector2 = COMBAT_RULES.max_hp_mp(state.raw_attributes, state.vocation_id)
	state.hp = 17.0
	state.mp = 23.0
	state.add_xp(COMBAT_RULES.xp_to_next_level(1))
	if not _expect(state.level == 2 and state.total_xp == 100, "One level-up did not preserve level/XP progression."):
		return
	if not _expect(state.hp == expected_max.x and state.mp == expected_max.y, "One level-up did not fully restore vocation/attribute-adjusted HP and MP."):
		return
	if not _expect(state.available_attribute_points == 1, "One level-up did not award exactly one attribute point."):
		return

	# A single XP grant can cross multiple thresholds; every earned level awards points.
	state.hp = 5.0
	state.mp = 6.0
	var multi_level_xp := COMBAT_RULES.xp_to_next_level(2) + COMBAT_RULES.xp_to_next_level(3)
	state.add_xp(multi_level_xp)
	if not _expect(state.level == 4 and state.total_xp == 399, "Multi-level XP grant did not cross both thresholds correctly."):
		return
	if not _expect(state.hp == expected_max.x and state.mp == expected_max.y, "Multi-level grant left HP or MP below maximum."):
		return
	if not _expect(state.available_attribute_points == 3, "Multi-level grant did not award one point per level."):
		return

	if not _expect(state.save(), "Could not save progression after level-up."):
		return
	var restored = EXPEDITION_STATE.open_for_character("melissa", root_path)
	if not _expect(restored.is_ready(), "Saved progression could not be reloaded."):
		return
	if not _expect(restored.level == 4 and restored.total_xp == 399 and restored.available_attribute_points == 3, "Level, XP, or pending attribute points changed across save/reload."):
		return
	if not _expect(restored.vocation_id == "mage" and restored.raw_attributes == state.raw_attributes, "Vocation or applied attributes changed across save/reload."):
		return
	if not _expect(restored.hp == expected_max.x and restored.mp == expected_max.y, "Restored HP/MP did not survive save/reload."):
		return

	print("Level-up resource regression passed: adjusted maxima, single/multiple level-ups, attribute points, XP and save/reload.")
	quit(0)


func _expect(condition: bool, message: String) -> bool:
	if condition:
		return true
	push_error(message)
	quit(1)
	return false
