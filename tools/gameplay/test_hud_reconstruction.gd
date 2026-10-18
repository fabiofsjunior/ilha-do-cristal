extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func _run() -> void:
	var hud = load("res://game/scripts/world/first_island_hud.gd").new()
	root.add_child(hud)
	await process_frame
	for viewport_size in [Vector2i(720, 1280), Vector2i(720, 1600), Vector2i(480, 800)]:
		root.size = viewport_size
		root.content_scale_size = viewport_size
		await process_frame
		hud._layout_safe_area()
		await process_frame
		var previous: Rect2
		for id in ["war_combo", "war_circle", "war_quake"]:
			var button: Button = hud._skill_buttons[id]
			_check(button.size == Vector2(144, 144), "Spells must be 144 x 144")
			var rect := button.get_global_rect()
			_check(Rect2(Vector2.ZERO, Vector2(viewport_size)).encloses(rect), "Spell outside viewport")
			_check(not previous.has_area() or not previous.intersects(rect), "Spells overlap")
			previous = rect
		_check(hud._equipment_slots.size() == 9, "Nine equipment slots required")
		for slot in hud._equipment_slots.values():
			_check(slot.size == Vector2(96, 96), "Equipment must be 96 x 96")
		hud._toggle_inventory()
		await process_frame
		_check(hud._character_preview.visible, "Character preview missing")
		_check(hud._inventory_scroll.size.y > 0, "Inventory has no scroll viewport")
		_check(Rect2(Vector2.ZERO, Vector2(viewport_size)).encloses(hud._inventory_panel.get_global_rect()), "Inventory outside viewport")
		hud._toggle_talents()
		_check(hud._talents_overlay.visible and not hud._inventory_overlay.visible, "Talents must replace inventory")
		hud._toggle_camp()
		_check(hud._camp_overlay.visible and not hud._talents_overlay.visible, "Base must replace talents")
		hud._toggle_inventory()
		_check(hud._inventory_overlay.visible and not hud._camp_overlay.visible, "Inventory must replace base")
		hud._toggle_inventory()
	_check(hud._nav_buttons[4].text == "⚙", "Settings gear missing")
	_check(hud._nav_buttons[5].position.y > hud._minimap.position.y, "Zoom should sit beside minimap")
	var emitted: Array[String] = []
	hud.skill_pressed.connect(func(id: String) -> void: emitted.append(id))
	for vocation in ["archer", "mage", "warrior"]:
		hud.set_vocation(vocation)
		hud.set_character_name("Melissa")
		hud._refresh_inventory_character_status()
		_check(hud._name_label.text.ends_with(hud.VOCATION_LABELS[vocation]), "Wrong profession in HUD")
		var weapon_id: String = hud.COMBAT_RULES.weapon_id_for_vocation(vocation)
		_check(hud._inventory_stats.text.contains(hud.ITEM_LABELS[weapon_id]), "Wrong inventory weapon")
		hud._inventory_items = {weapon_id: 1}
		hud._refresh_inventory()
		_check(hud._bag_header.text.contains("1 / 24"), "Vocation weapon disappeared from bag")
		var index := 0
		for id in hud._skill_buttons:
			var data: Dictionary = hud.COMBAT_RULES.skill(id)
			_check(str(data.vocation) == vocation, "Spell from incorrect vocation")
			hud._update_skill_button(id, str(hud.SKILL_LABELS[id]), 0.0, {})
			_check(hud._skill_buttons[id].disabled, "Spell without mana should be disabled")
			hud._update_skill_button(id, str(hud.SKILL_LABELS[id]), 200.0, {id: 3.0})
			_check(hud._skill_buttons[id].disabled, "Spell on cooldown should be disabled")
			hud._update_skill_button(id, str(hud.SKILL_LABELS[id]), 200.0, {})
			_check(not hud._skill_buttons[id].disabled, "Ready spell should be enabled")
			hud._skill_buttons[id].emit_signal("pressed")
			_check(emitted[-1] == id, "Touch emitted wrong vocation spell")
			index += 1
	hud.queue_free()
	await process_frame
	if failures == 0:
		print("HUD reconstruction passed: three viewports, spells, equipment, scroll, exclusive navigation, settings.")
	quit(failures)
