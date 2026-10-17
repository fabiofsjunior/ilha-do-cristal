extends SceneTree
## Functional test for temporary allocation, confirmation, reset, and modal close.

const EXPEDITION_STATE = preload("res://game/scripts/save/expedition_state.gd")
const ATTRIBUTES_SCENE = preload("res://game/scenes/ui/attributes_window.tscn")

var failures := 0
var committed_count := 0
var observed_state: Object


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(720, 1280)
	var save_root := "user://attributes_window_%d" % Time.get_ticks_usec()
	var state = EXPEDITION_STATE.open_for_character("melissa", save_root)
	_check(state.is_ready(), "Could not initialize isolated ExpeditionState.")
	if failures > 0:
		quit(failures)
		return
	state.vocation_id = "warrior"
	state.level = 3
	state.available_attribute_points = 2
	state.raw_attributes = {"FOR": 0, "AGI": 0, "INT": 0}

	var window: Control = ATTRIBUTES_SCENE.instantiate()
	root.add_child(window)
	await process_frame
	_check(window._main_frame.custom_minimum_size.x <= 660.0 and window._main_frame.custom_minimum_size.y <= 1180.0, "Attributes window exceeded its portrait layout limits.")
	window.attributes_committed.connect(func(committed: Object) -> void:
		committed_count += 1
		observed_state = committed
	)
	_check(window.open_for_state(state), "Window refused a ready ExpeditionState.")
	_check(paused, "Modal did not pause gameplay behind the overlay.")
	_check(window.visible, "Modal was not made visible when opened.")

	# Click the actual plus controls and ensure temporary values do not mutate the save state.
	window._add_buttons["FOR"].emit_signal("pressed")
	window._add_buttons["INT"].emit_signal("pressed")
	_check(not window.allocate_point("AGI"), "Temporary allocation exceeded the available point balance.")
	_check(state.raw_attributes == {"FOR": 0, "AGI": 0, "INT": 0}, "Temporary allocation modified live attributes before confirmation.")
	_check(state.available_attribute_points == 2, "Temporary allocation spent points before confirmation.")
	_check(window._value_labels["FOR"].text.contains("Bruto 0  (+1)"), "FOR raw and pending allocation are not visible.")
	_check(window._effective_labels["FOR"].text.contains("Efetivo 0  →  2"), "FOR effective value did not use the vocation multiplier.")
	_check(window._resource_label.text.contains("206"), "FOR preview did not use the vocation's HP coefficient.")
	_check(window._resource_label.text.contains("101.5"), "INT preview did not use the vocation's MP coefficient.")
	_check(window._benefit_labels["FOR"].text.contains("+6 HP máximo") and window._benefit_labels["FOR"].text.contains("+1.2 de dano melee") and window._benefit_labels["FOR"].text.contains("+0,006 p.p./s em combate") and window._benefit_labels["FOR"].text.contains("+0,024 p.p./s fora"), "FOR next-point benefit is not based on the Warrior multiplier, regeneration coefficients and caps.")
	_check(window._derived_labels["melee"].text == "12 → 13.2", "Melee attack preview did not follow the catalog formula.")
	_check(window._regen_label.text.contains("HP máximo/s · combate: 0,2% → 0,206%") and window._regen_label.text.contains("Tetos HP: 0,5%/s em combate, 2%/s fora"), "Current/projected HP rates and their caps are not shown accurately.")
	_check(window._regen_label.text.contains("MP máximo/s · combate:") and window._regen_label.text.contains("MP: 0,25%/s em combate, 1%/s fora"), "Current MP rates and their caps are not shown accurately.")
	_check(window.confirm_changes(), "Confirm failed with a valid allocation.")
	_check(state.raw_attributes == {"FOR": 1, "AGI": 0, "INT": 1}, "Confirmed allocation was not applied to the state.")
	_check(state.available_attribute_points == 0, "Confirm did not deduct the exact number of points.")
	_check(committed_count == 1 and observed_state == state, "Confirm did not emit the state update/save signal exactly once.")

	# Re-open with one available point; Resetar discards staged changes, while close also discards.
	state.available_attribute_points = 1
	window.close_window()
	_check(not paused, "Closing modal did not restore the prior pause state.")
	_check(window.open_for_state(state), "Window could not be reopened with the same state.")
	window._add_buttons["AGI"].emit_signal("pressed")
	window.reset_allocation()
	_check(window._spent_points() == 0, "Resetar did not clear the temporary allocation.")
	_check(state.raw_attributes["AGI"] == 0 and state.available_attribute_points == 1, "Resetar changed the live state or spent a point.")
	_check(window.allocate_point("AGI"), "Could not stage a point after reset.")
	window.close_window()
	_check(not window.visible and not paused, "Close did not hide the overlay and unpause gameplay.")
	_check(state.raw_attributes["AGI"] == 0 and state.available_attribute_points == 1, "Closing with pending points committed them unexpectedly.")

	# Each vocation must get its own next-point effect from the same catalog multipliers.
	state.vocation_id = "archer"
	state.raw_attributes = {"FOR": 0, "AGI": 0, "INT": 0}
	_check(window.open_for_state(state), "Archer attributes view could not be reopened.")
	_check(window.allocate_point("AGI"), "Archer could not stage AGI.")
	_check(window._effective_labels["AGI"].text.ends_with("2"), "Archer AGI did not use its 2x vocation multiplier.")
	_check(window._benefit_labels["AGI"].text.contains("+1.2 dano à distância") and window._benefit_labels["AGI"].text.contains("+0.1 p.p. crítico"), "Archer AGI benefit does not match the catalog.")
	window.close_window()
	state.vocation_id = "mage"
	state.raw_attributes = {"FOR": 0, "AGI": 0, "INT": 0}
	_check(window.open_for_state(state), "Mage attributes view could not be reopened.")
	_check(window.allocate_point("INT"), "Mage could not stage INT.")
	_check(window._effective_labels["INT"].text.ends_with("2"), "Mage INT did not use its 2x vocation multiplier.")
	_check(window._benefit_labels["INT"].text.contains("+6 MP máximo") and window._benefit_labels["INT"].text.contains("+1.2 de ataque mágico") and window._benefit_labels["INT"].text.contains("+0,002 p.p./s em combate") and window._benefit_labels["INT"].text.contains("+0,01 p.p./s fora"), "Mage INT benefit does not include effective MP regeneration and the vocation multiplier.")
	window.close_window()

	window.queue_free()
	await process_frame
	if failures == 0:
		print("Attributes window passed: portrait layout, raw/effective stats, catalog-derived next-point benefits, attack/resource projections, honest regen limits, temporary allocation, confirm, reset, close and pause restoration.")
	quit(failures)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)
