extends SceneTree
const RULES = preload("res://game/scripts/combat/combat_rules.gd")
const STATE = preload("res://game/scripts/save/expedition_state.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var save_path := "user://vocations_regression_%d" % Time.get_ticks_usec()
	var warrior = STATE.open_for_character("melissa", save_path)
	assert(warrior.is_ready() and warrior.hp == 200 and warrior.mp == 100)
	warrior.total_xp = 37
	assert(warrior.save())
	var archer = STATE.open_for_character("melissa", save_path, "archer")
	assert(archer.is_ready() and archer.hp == 150 and archer.mp == 150)
	assert(archer.inventory.has("bow_basic") and not archer.inventory.has("sword_basic"))
	assert(is_equal_approx(RULES.physical_attack({"FOR": 0, "AGI": 1, "INT": 0}, "archer", "bow_basic"), 11.2))
	assert(archer.save())
	var mage = STATE.open_for_character("melissa", save_path, "mage")
	assert(mage.is_ready() and mage.hp == 100 and mage.mp == 200)
	assert(mage.magic_attack() == 10.0 and mage.inventory.has("staff_basic"))
	assert(mage.save())
	assert(STATE.open_for_character("melissa", save_path).total_xp == 37)
	assert(STATE.open_for_character("melissa", save_path, "mage").vocation_id == "mage")
	assert(RULES.skills_for_vocation("mage") == ["mag_bolt", "mag_fire", "mag_ice"])
	assert(RULES.skill_damage(RULES.skill("mag_bolt"), 10, 10) == 15.0)
	assert(RULES.skill_damage(RULES.skill("arc_precise"), 10, 4) == 12.0)
	assert(RULES.skill_damage(RULES.skill("arc_bounce"), 10, 0, 4) == 6.0)
	assert(is_equal_approx(RULES.skill_damage(RULES.skill("war_combo"), 12, 0) * 3, 43.2))
	for id in ["warrior", "archer", "mage"]:
		assert(RULES.skills_for_vocation(id).size() == 3)
		for skill_id in RULES.skills_for_vocation(id):
			var skill := RULES.skill(skill_id)
			assert(float(skill.range_px) > 0 and float(skill.mp) > 0 and float(skill.cooldown_sec) > 0)
	assert(RULES.skill("war_combo").range_px == 65)
	assert(RULES.skill("war_circle").range_px == 82)
	assert(RULES.skill("war_quake").range_px == 135)
	print("PASS vocation defaults, save isolation, skill damage, mana/cooldown catalog and Warrior range")
	quit(0)
