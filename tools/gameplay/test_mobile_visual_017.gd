extends SceneTree
var failures := 0
func _initialize() -> void:
	OS.set_environment("GAMEPLAY_TEST_SAVE_DIR", "user://visual_017_%d" % Time.get_ticks_usec())
	call_deferred("run")
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func capture(name: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	check(image != null and not image.is_empty(), "Renderer returned empty image")
	if image != null:
		DirAccess.make_dir_recursive_absolute("res://build/evidence")
		check(image.save_png("res://build/evidence/%s.png" % name) == OK, "Screenshot write failed")
func run() -> void:
	root.size = Vector2i(720,1280)
	var game = load("res://game/scenes/first_island.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await process_frame
	var view = game._iso_view
	var sprite: Sprite3D = view.actor_sprites.player
	var pose: AnimatedSprite2D = game._player.get_node("AnimatedSprite2D")
	check(sprite.offset.is_equal_approx(Vector2(pose.offset.x, -pose.offset.y)), "3D pivot has not inverted screen Y")
	for actor_sprite in view.actor_sprites.values():
		check(actor_sprite.position.y > 0.012, "Actor is below the top terrain plane")
	var hud = game._hud
	game._update_hud()
	check(hud._minimap._world_size == Vector2(6144,4224), "Minimap uses the old island dimensions")
	check(hud._minimap._map.get_size() == Vector2(192,132), "Minimap snapshot omits expanded land")
	check(hud._minimap._enemies.size() == game._creature_actors.size(), "Living monsters are missing from map")
	var creature = game._creature_actors.values()[0]
	creature.is_alive = false
	game._update_hud()
	check(hud._minimap._enemies.size() == game._creature_actors.size()-1, "Dead enemy marker remains visible")
	creature.is_alive = true
	for focus in [Vector3(1,0.8,1), Vector3(191,0.8,131)]:
		view.camera.global_position = view._camera_position(view._bounded_focus(focus))
		for point in [Vector2(0,0), Vector2(719,0), Vector2(0,1279), Vector2(719,1279)]:
			check(Rect2(Vector2(-1,-1), Vector2(6146,4226)).has_point(view.point_from_screen(point)), "Camera reveals void outside the island")
	game._player.global_position = Vector2(1000,800)
	view.camera.global_position = view._camera_position(view._bounded_focus(view._player_focus()))
	game._update_hud()
	await process_frame
	await capture("mobile_world_017")
	game._state.inventory = {"wood":12,"stone":8,"fiber":4,"herb":6,"bandage":2,"sword_basic":1,"hide":3,"crystal_shard":1}
	game._update_hud()
	hud._refresh_inventory()
	hud._inventory_overlay.show()
	await process_frame
	await process_frame
	var equipment: Control = hud._inventory_overlay.find_child("EquipmentPanel",true,false)
	var bag: Control = hud._inventory_overlay.find_child("BagPanel",true,false)
	check(bag.get_global_rect().position.x >= equipment.get_global_rect().end.x, "Equipment and backpack are not side by side")
	for slot in hud._bag_slots:
		check(root.get_visible_rect().encloses(slot.get_global_rect()), "Backpack slot overflows viewport")
	check(hud._bag_slots[0].get_node("ItemIcon").texture != null, "Item is still a text placeholder")
	await capture("mobile_inventory_017")
	hud._inventory_overlay.hide()
	game._state.available_attribute_points = 3
	hud.open_attributes_for_state(game._state)
	await process_frame
	await process_frame
	var attributes = hud._attributes_window
	check(attributes._profile_preview.texture != null, "Attributes character art is missing")
	check(root.get_visible_rect().encloses(attributes._main_frame.get_global_rect()), "Attributes panel overflows viewport")
	await capture("mobile_attributes_017")
	attributes.close_window()
	game.queue_free()
	await process_frame
	print("Mobile visual 0.1.7: %d failures; pivot/depth, camera bounds, live minimap, inventory and attributes." % failures)
	quit(failures)
