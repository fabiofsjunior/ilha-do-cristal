extends SceneTree
## Regression: the redesigned inventory keeps the paper-doll, bag grid, summary,
## and existing consumable actions connected to real MVP data.

var failures := 0


func _initialize() -> void:
	OS.set_environment("GAMEPLAY_TEST_SAVE_DIR", "user://inventory_ui_%d" % Time.get_ticks_usec())
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(720, 1280)
	var game = load("res://game/scenes/first_island.tscn").instantiate()
	root.add_child(game)
	await process_frame
	var hud = game.get_node("HUD")
	var overlay: Control = hud._inventory_overlay
	_check(overlay != null and not overlay.visible, "Inventory overlay was not created hidden.")
	_check(overlay.find_child("EquipmentBoard", true, false) != null, "Paper-doll equipment board is missing.")
	_check(overlay.find_child("InventoryCharacterStatus", true, false) != null, "Character summary below the paper doll is missing.")
	var character_preview: TextureRect = overlay.find_child("CharacterPreview", true, false) as TextureRect
	_check(character_preview != null and character_preview.texture != null, "Pixel-art character preview is missing or has no atlas frame.")
	_check(overlay.find_child("InventoryContentScroll", true, false) is ScrollContainer, "Inventory content is missing its height-limited scroll container.")
	_check(overlay.find_child("BagGrid", true, false) != null and hud._bag_slots.size() == 24, "Bag grid does not contain 24 slots.")
	_check(overlay.find_child("GoldUnavailableLabel", true, false) != null, "Gold footer does not expose the MVP-unavailable state.")
	_check(overlay.find_child("InventoryFooter", true, false) != null, "Gold and bag footer is missing.")
	var board: Control = overlay.find_child("EquipmentBoard", true, false)
	var main_hand: Control = board.find_child("EquipmentSlot_main_hand", false, false)
	var offhand: Control = board.find_child("EquipmentSlot_offhand", false, false)
	var helmet: Control = board.find_child("EquipmentSlot_head", false, false)
	var chest: Control = board.find_child("EquipmentSlot_chest", false, false)
	var boots: Control = board.find_child("EquipmentSlot_boots", false, false)
	_check(main_hand.position.x < 80.0 and offhand.position.x > 200.0, "Main-hand and off-hand slots are not flanking the character.")
	_check(helmet.position.y < chest.position.y and boots.position.y > chest.position.y, "Helmet, chest, and boots are not vertically arranged.")

	hud._inventory_items = {"wood": 3, "sword_basic": 1}
	hud._refresh_inventory()
	_check(hud._bag_header.text == "MOCHILA · 2 / 24 PILHAS", "Bag header does not reflect occupied item stacks.")
	_check(hud._bag_summary.text.contains("2 / 24") and hud._bag_summary.text.contains("Peso: não definido"), "Bag footer does not show actual capacity and undefined weight.")
	_check(hud._gold_summary.text.contains("indisponível no MVP"), "Gold footer invents a value or fails to explain the missing economy.")
	_check(hud._inventory_stats.text.contains("HP") and hud._inventory_stats.text.contains("MP"), "Character panel is missing live health or mana.")
	_check(hud._inventory_stats.text.contains("Dano da arma: 12"), "Base weapon damage does not match the MVP catalog.")
	_check(not hud._inventory_stats.text.contains("Defesa por equipamento: 0"), "Inventory shows a fabricated defense value.")
	var main_hand_slot: Control = hud._equipment_slots.get("main_hand") as Control
	_check(main_hand_slot.tooltip_text.contains("12 de dano"), "Main-hand slot does not explain the real catalog-backed weapon.")

	hud._select_bag_slot(0)
	_check(hud._item_detail.text.contains("Madeira") and hud._item_detail.text.contains("Quantidade: 3"), "Selecting a bag slot does not show the item count.")
	hud._inventory_items = {"herb": 3, "fiber": 1, "bandage": 1}
	hud._refresh_inventory()
	_check(not hud._craft_bandage_button.disabled, "Existing bandage crafting action no longer enables with its recipe.")
	_check(not hud._use_bandage_button.disabled, "Existing bandage use action no longer enables when present.")

	var status_panel: Control = overlay.find_child("InventoryCharacterStatus", true, false) as Control
	overlay.show()
	for dimensions in [Vector2i(720, 1280), Vector2i(720, 1600), Vector2i(960, 1280)]:
		root.size = dimensions
		hud._layout_safe_area()
		await process_frame
		var viewport_bounds := Rect2(Vector2.ZERO, Vector2(dimensions))
		var panel := overlay.find_child("InventoryPanel", true, false) as PanelContainer
		_check(panel != null and viewport_bounds.encloses(panel.get_global_rect()), "Inventory panel overflows %s viewport: %s" % [dimensions, panel.get_global_rect() if panel != null else Rect2()])
		_check(status_panel.get_global_rect().position.y >= board.get_global_rect().end.y - 1.0, "Character summary is not positioned below the paper doll at %s." % dimensions)
		_check_visible_inventory_bounds(overlay, viewport_bounds)

	if failures == 0:
		print("Inventory overlay passed: Tibia-style paper doll, 24-slot bag, live character/weapon summary, neutral gold/weight states, and existing item actions.")
	game.queue_free()
	await process_frame
	quit(failures)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)


func _check_visible_inventory_bounds(node: Node, viewport_bounds: Rect2) -> void:
	if node is Control and node.is_visible_in_tree() and (node is PanelContainer or node is Button):
		var control := node as Control
		var visible_rect := control.get_global_rect()
		var ancestor := control.get_parent()
		while ancestor != null:
			if ancestor is Control and ancestor.clip_contents:
				visible_rect = visible_rect.intersection(ancestor.get_global_rect())
			ancestor = ancestor.get_parent()
		_check(not visible_rect.has_area() or viewport_bounds.encloses(visible_rect), "Visible inventory control %s overflows the viewport: %s in %s" % [node.name, visible_rect, viewport_bounds])
	for child in node.get_children():
		_check_visible_inventory_bounds(child, viewport_bounds)
