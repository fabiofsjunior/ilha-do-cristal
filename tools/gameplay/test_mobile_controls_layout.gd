extends SceneTree

var failures := 0


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)


func _initialize() -> void:
	OS.set_environment("GAMEPLAY_TEST_SAVE_DIR", "user://mobile_controls_%d" % Time.get_ticks_usec())
	call_deferred("_run")


func _run() -> void:
	var scenarios := [
		{"viewport": Vector2i(720, 1280), "screen": Vector2i(1080, 2400), "safe": Rect2i(48, 120, 984, 2196)},
		{"viewport": Vector2i(720, 1600), "screen": Vector2i(1080, 2400), "safe": Rect2i(48, 96, 984, 2240)},
		{"viewport": Vector2i(1280, 720), "screen": Vector2i(2400, 1350), "safe": Rect2i(50, 45, 2300, 1260)},
		{"viewport": Vector2i(720, 1600), "screen": Vector2i(2400, 1080), "safe": Rect2i(48, 120, 984, 2196), "expect_fallback": true},
	]
	for scenario in scenarios:
		await _test_layout(scenario)
	if failures == 0:
		print("Mobile controls layout: 9:16 corner placement, safe areas, viewport bounds and joystick touch passed.")
	quit(failures)


func _test_layout(scenario: Dictionary) -> void:
	var viewport_size: Vector2i = scenario.viewport
	root.size = viewport_size
	var game: Node2D = load("res://game/scenes/first_island.tscn").instantiate() as Node2D
	root.add_child(game)
	await process_frame
	var hud: CanvasLayer = game.get_node("HUD")
	hud._layout_safe_area()
	var actual_viewport: Rect2 = root.get_visible_rect()
	var factor := minf(actual_viewport.size.x, actual_viewport.size.y) / 720.0
	hud._apply_safe_area_layout(actual_viewport.size, factor, scenario.safe, scenario.screen)
	await process_frame

	var ratio: Vector2 = actual_viewport.size / Vector2(scenario.screen)
	var expected_safe_rect := Rect2(Vector2(scenario.safe.position) * ratio, Vector2(scenario.safe.size) * ratio)
	var effective_safe_rect := Rect2(hud._safe_rect.position * factor, hud._safe_rect.size * factor)
	if scenario.get("expect_fallback", false):
		check(actual_viewport.grow(1.0).encloses(effective_safe_rect) and effective_safe_rect.size.is_equal_approx(actual_viewport.size), "Malformed Android safe area did not fall back to the full viewport: %s / %s" % [effective_safe_rect, actual_viewport])
	else:
		check(expected_safe_rect.grow(1.0).encloses(effective_safe_rect), "Effective safe area escaped the simulated Android safe area: %s / %s" % [effective_safe_rect, expected_safe_rect])
	var actual_root_rect: Rect2 = hud._root.get_global_rect()
	check(actual_viewport.grow(1.0).encloses(actual_root_rect), "HUD root does not cover the complete viewport: %s vs %s" % [actual_root_rect, actual_viewport])

	var interactive: Array[Control] = [
		hud._portrait.get_parent() as Control,
		hud._name_label as Control,
		hud._hp_bar as Control,
		hud._mp_bar as Control,
		hud._xp_bar as Control,
		hud._minimap as Control,
		hud._status as Control,
		hud._interact_button as Control,
		hud._bandage_button as Control,
		hud._joystick as Control,
	]
	for button in hud._nav_buttons:
		interactive.append(button as Control)
	for button in hud._skill_buttons.values():
		interactive.append(button as Control)
	var safe_bounds := effective_safe_rect.grow(1.0)
	var viewport_bounds: Rect2 = actual_viewport.grow(1.0)
	for control in interactive:
		var rect := control.get_global_rect()
		check(safe_bounds.encloses(rect), "%s is outside the safe rectangle: %s / %s" % [control.name, rect, safe_bounds])
		check(viewport_bounds.encloses(rect), "%s is outside the viewport: %s / %s" % [control.name, rect, viewport_bounds])

	var joystick_rect: Rect2 = hud._joystick.get_global_rect()
	var first_spell: Rect2 = hud._skill_buttons["war_combo"].get_global_rect()
	var last_spell: Rect2 = hud._skill_buttons["war_quake"].get_global_rect()
	var expected_joystick_size: Vector2 = hud.MOBILE_JOYSTICK_BASE_SIZE * hud.MOBILE_JOYSTICK_SCALE * factor
	check(hud.MOBILE_JOYSTICK_SCALE == 2.0, "Mobile joystick scale is not exactly 200%.")
	check(joystick_rect.size.is_equal_approx(expected_joystick_size), "Joystick visual/touch bounds are not twice the previous size: %s vs %s" % [joystick_rect.size, expected_joystick_size])
	check(is_equal_approx(hud._joystick.radius, hud.MOBILE_JOYSTICK_BASE_RADIUS * 2.0), "Joystick movement radius did not double with its visual size.")
	check(absf(joystick_rect.position.x - (effective_safe_rect.position.x + 16.0 * factor)) <= 1.0, "Joystick is not inset from the bottom-left safe corner: %s / %s" % [joystick_rect, effective_safe_rect])
	check(absf(joystick_rect.end.y - (effective_safe_rect.end.y - 16.0 * factor)) <= 1.0, "Joystick is not aligned to the bottom-left safe corner: %s / %s" % [joystick_rect, effective_safe_rect])
	check(not joystick_rect.intersects(hud._bandage_button.get_global_rect()), "Enlarged joystick overlaps the bandage control.")
	check(not joystick_rect.intersects(hud._interact_button.get_global_rect()), "Enlarged joystick overlaps the interact control.")
	for skill_button in hud._skill_buttons.values():
		check(not joystick_rect.intersects((skill_button as Control).get_global_rect()), "Enlarged joystick overlaps a skill control.")
	check(first_spell.position.x > actual_viewport.size.x * 0.5, "Spells are not positioned on the right half of the screen: %s" % first_spell)
	check(absf(last_spell.end.x - (effective_safe_rect.end.x - 16.0 * factor)) <= 1.0, "Spell row is not inset from the bottom-right safe corner: %s / %s" % [last_spell, effective_safe_rect])
	check(absf(last_spell.end.y - joystick_rect.end.y) <= 1.0, "Spell row and joystick do not share the bottom alignment.")

	var joystick: Control = hud._joystick
	var player: CharacterBody2D = game.get("_player")
	var transform: Transform2D = joystick.get_global_transform_with_canvas()
	var touch := InputEventScreenTouch.new()
	touch.index = 3
	touch.pressed = true
	touch.position = transform * (joystick.size * 0.5 + Vector2(joystick.radius * 0.55, 0.0))
	joystick._input(touch)
	check(player != null and is_equal_approx(player.joystick_vector.x, 0.55), "Touch inside the enlarged joystick did not move the player with expected response: %s" % (player.joystick_vector if player != null else Vector2.ZERO))
	var drag := InputEventScreenDrag.new()
	drag.index = touch.index
	drag.position = transform * (joystick.size * 0.5 + Vector2(joystick.radius * 1.5, 0.0))
	joystick._input(drag)
	check(player != null and is_equal_approx(player.joystick_vector.x, 1.0), "Dragging beyond the enlarged joystick radius did not clamp to full movement.")
	var release := InputEventScreenTouch.new()
	release.index = 3
	release.pressed = false
	release.position = touch.position
	joystick._input(release)
	check(player == null or player.joystick_vector.is_zero_approx(), "Releasing joystick touch did not stop movement.")

	game.queue_free()
	await process_frame
