extends SceneTree
## Regression coverage for vocation-based HP/MP regeneration and caps.

const COMBAT_RULES = preload("res://game/scripts/combat/combat_rules.gd")
const EXPEDITION_STATE = preload("res://game/scripts/save/expedition_state.gd")

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var zero := {"FOR": 0, "AGI": 0, "INT": 0}
	var delay := COMBAT_RULES.regeneration_out_of_combat_delay_sec()
	_check_approx(delay, 8.0, "Out-of-combat delay must be eight seconds.")
	var regeneration: Dictionary = COMBAT_RULES.catalog().get("attributes_and_levels", {}).get("regeneration", {})
	_check_approx(float(regeneration.get("out_of_combat_rate_multiplier", 1.0)), 1.2, "Out-of-combat components must use the 1.2 multiplier.")

	# Combat rates stay unchanged; all base rates outside combat scale by 1.2.
	_check_rates(COMBAT_RULES.regeneration_rates_percent_per_sec(zero, "warrior", 0.0), 0.20, 0.03, "Warrior combat base")
	_check_rates(COMBAT_RULES.regeneration_rates_percent_per_sec(zero, "archer", 0.0), 0.15, 0.06, "Archer combat base")
	_check_rates(COMBAT_RULES.regeneration_rates_percent_per_sec(zero, "mage", 0.0), 0.10, 0.10, "Mage combat base")
	_check_rates(COMBAT_RULES.regeneration_rates_percent_per_sec(zero, "warrior", delay - 0.001), 0.20, 0.03, "Combat remains active before eight seconds")
	_check_rates(COMBAT_RULES.regeneration_rates_percent_per_sec(zero, "warrior", delay), 0.72, 0.144, "Warrior out-of-combat base at eight seconds")
	_check_rates(COMBAT_RULES.regeneration_rates_percent_per_sec(zero, "archer", delay), 0.60, 0.30, "Archer out-of-combat base")
	_check_rates(COMBAT_RULES.regeneration_rates_percent_per_sec(zero, "mage", delay), 0.42, 0.48, "Mage out-of-combat base")

	# Combat bonuses remain unchanged; outside-combat base and stat components both scale.
	var one_each := {"FOR": 1, "AGI": 0, "INT": 1}
	_check_rates(COMBAT_RULES.regeneration_rates_percent_per_sec(one_each, "warrior", 0.0), 0.206, 0.0305, "Warrior effective-point combat bonuses")
	_check_rates(COMBAT_RULES.regeneration_rates_percent_per_sec(one_each, "archer", 0.0), 0.153, 0.06075, "Archer vocation multipliers")
	_check_rates(COMBAT_RULES.regeneration_rates_percent_per_sec(one_each, "mage", 0.0), 0.1015, 0.102, "Mage vocation multipliers")
	_check_rates(COMBAT_RULES.regeneration_rates_percent_per_sec(one_each, "warrior", delay), 0.744, 0.1464, "Warrior effective-point rest bonuses")
	_check_rates(COMBAT_RULES.regeneration_rates_percent_per_sec(one_each, "archer", delay), 0.612, 0.3036, "Archer effective-point rest bonuses")
	_check_rates(COMBAT_RULES.regeneration_rates_percent_per_sec(one_each, "mage", delay), 0.426, 0.4896, "Mage effective-point rest bonuses")

	# Large endgame attributes still stop at catalogued hard caps.
	var endgame_attributes := {"FOR": 1000, "AGI": 0, "INT": 1000}
	_check_rates(COMBAT_RULES.regeneration_rates_percent_per_sec(endgame_attributes, "warrior", 0.0), 0.5, 0.25, "Combat endgame caps")
	_check_rates(COMBAT_RULES.regeneration_rates_percent_per_sec(endgame_attributes, "mage", delay), 2.0, 1.0, "Out-of-combat endgame caps")
	_check_rates(COMBAT_RULES.regeneration_rates_percent_per_sec(zero, "warrior", 0.0), 0.20, 0.03, "Combat rates remain independent of rest multiplier")

	# Per-second percentages are based on maxima and never overfill current resources.
	var full := COMBAT_RULES.regenerated_resources(zero, "warrior", 0.0, 199.99, 99.99, 200.0, 100.0, 100.0)
	_check_approx(float(full.hp), 200.0, "HP regeneration exceeded or failed to clamp to maximum.")
	_check_approx(float(full.mp), 100.0, "MP regeneration exceeded or failed to clamp to maximum.")
	var partial := COMBAT_RULES.regenerated_resources(zero, "warrior", 0.0, 100.0, 50.0, 200.0, 100.0, 1.0)
	_check_approx(float(partial.hp), 100.4, "HP tick was not a percentage of maximum HP.")
	_check_approx(float(partial.mp), 50.03, "MP tick was not a percentage of maximum MP.")
	var partial_rest := COMBAT_RULES.regenerated_resources(zero, "warrior", delay, 100.0, 50.0, 200.0, 100.0, 1.0)
	_check_approx(float(partial_rest.hp), 101.44, "Outside-combat HP tick did not apply 1.2× to its base component.")
	_check_approx(float(partial_rest.mp), 50.144, "Outside-combat MP tick did not apply 1.2× to its base component.")
	_check_approx(float(partial_rest.rates.hp), 0.72, "Outside-combat HP cap altered the un-capped 1.2× base rate.")
	_check_approx(float(partial_rest.rates.mp), 0.144, "Outside-combat MP cap altered the un-capped 1.2× base rate.")

	# Runtime state suspends regeneration while downed and resumes when active.
	var save_root := "user://regeneration_rules_%d" % Time.get_ticks_usec()
	var state = EXPEDITION_STATE.open_for_character("melissa", save_root)
	_check(state.is_ready(), "Could not initialize an isolated state for regen integration.")
	if state.is_ready():
		state.vocation_id = "warrior"
		state.hp = 100.0
		state.mp = 50.0
		state.downed_remaining = 1.0
		state.tick_regeneration(10.0, delay)
		_check_approx(float(state.hp), 100.0, "Downed state regenerated HP.")
		_check_approx(float(state.mp), 50.0, "Downed state regenerated MP.")
		state.downed_remaining = -1.0
		state.tick_regeneration(1.0, 0.0)
		_check(float(state.hp) > 100.0 and float(state.mp) > 50.0, "Active state did not regenerate HP/MP.")
		state.hp = 100.0
		state.mp = 50.0
		state.tick_regeneration(1.0, delay)
		_check_approx(float(state.hp), 101.44, "Active runtime did not apply outside-combat HP multiplier.")
		_check_approx(float(state.mp), 50.144, "Active runtime did not apply outside-combat MP multiplier.")
		state.hp = 0.0
		var dead_tick := state.tick_regeneration(10.0, delay)
		_check_approx(float(dead_tick.hp_gained), 0.0, "Zero-HP state regenerated after death.")

	if failures == 0:
		print("Regeneration passed: 1.2x outside-combat base/stat components across vocations, unchanged combat rates, eight-second delay, resource clamps, caps, downed/dead pause and active runtime ticks.")
	quit(failures)


func _check_rates(actual: Dictionary, hp_expected: float, mp_expected: float, context: String) -> void:
	_check_approx(float(actual.get("hp", -1.0)), hp_expected, "%s HP rate mismatch." % context)
	_check_approx(float(actual.get("mp", -1.0)), mp_expected, "%s MP rate mismatch." % context)


func _check_approx(actual: float, expected: float, message: String) -> void:
	if not is_equal_approx(actual, expected):
		failures += 1
		push_error("%s Expected %s, got %s." % [message, expected, actual])


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)
