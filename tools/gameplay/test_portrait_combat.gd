extends SceneTree
## Regression: portrait flow, unobstructed targeting and damage feedback lifecycle.
const MAIN = preload("res://game/scenes/main.tscn")
var failures := 0

func _initialize() -> void:
	OS.set_environment("GAMEPLAY_TEST_SAVE_DIR", "user://portrait_test_%d" % Time.get_ticks_usec())
	call_deferred("_run")

func _check(value: bool, message: String) -> void:
	if not value:
		failures += 1
		push_error(message)

func _settle() -> void:
	for i in range(4):
		await process_frame

func _bounds(node: Node, viewport: Rect2) -> void:
	for child in node.get_children():
		if child is Control and child.is_visible_in_tree() and (child is Button or child is PanelContainer):
			_check(viewport.grow(2).encloses(child.get_global_rect()), "Clipped %s: %s in %s" % [child.name, child.get_global_rect(), viewport])
		_bounds(child, viewport)

func _run() -> void:
	root.size = Vector2i(720, 1280)
	var app = MAIN.instantiate()
	root.add_child(app)
	await _settle()
	_bounds(app, Rect2(Vector2.ZERO, Vector2(720, 1280)))
	app.current_screen.begin_requested.emit()
	await _settle()
	_bounds(app, Rect2(Vector2.ZERO, Vector2(720, 1280)))
	app.current_screen.confirm_requested.emit("maira")
	await _settle()
	_bounds(app, Rect2(Vector2.ZERO, Vector2(720, 1280)))
	app.current_screen.host_solo_requested.emit()
	await _settle()
	var game = app.gameplay
	game.set_physics_process(false)
	var actors: Dictionary = game.get("_creature_actors")
	var fox = actors["fox_1"]
	var wolf = actors["wolf_1"]
	for actor in actors.values():
		actor.set_physics_process(false)
	var player = game.get("_player")
	player.global_position = Vector2(1000, 750)
	fox.global_position = player.global_position + Vector2(120, 0)
	wolf.global_position = player.global_position + Vector2(-120, 0)
	game.get("_camera").reset_smoothing()
	await _settle()
	for zoom in [0.5, 0.75, 1.0, 1.25]:
		game.get("_camera").zoom = Vector2.ONE * zoom
		await _settle()
		game._set_target(null)
		var event := InputEventScreenTouch.new()
		event.index = 2
		event.pressed = true
		event.position = root.get_canvas_transform() * (fox.global_position + Vector2(20, -36))
		root.push_input(event, true)
		await _settle()
		_check(game.get("_target") == fox and fox.selected, "Touch body selection failed at zoom %s" % zoom)
		event.pressed = false
		root.push_input(event, true)
		game._select_target_at(Vector2(-1000, -1000))
		_check(game.get("_target") == fox, "Ground tap lost the selected target")
	game._cycle_target()
	_check(game.get("_target") == wolf and not fox.selected and wolf.selected, "Cycle failed or old ring remained")
	fox.take_hit(5)
	game._on_player_damaged(7, "wolf")
	await _settle()
	var numbers: Array = game.find_children("FloatingDamage*", "Label", false, false)
	_check(numbers.size() == 2, "Expected outgoing and incoming floating damage")
	fox.take_hit(fox.hp)
	await _settle()
	_check(game.find_children("FloatingDamage*", "Label", false, false).size() == 3, "Fatal hit number disappeared with monster")
	var hud = game.get_node("HUD")
	for dimensions in [Vector2i(720, 1280), Vector2i(720, 1600), Vector2i(960, 1280)]:
		root.size = dimensions
		await _settle()
		_bounds(hud, Rect2(Vector2.ZERO, Vector2(dimensions)))
		hud._toggle_inventory()
		await _settle()
		_bounds(hud, Rect2(Vector2.ZERO, Vector2(dimensions)))
		hud._toggle_inventory()
		hud._toggle_camp()
		await _settle()
		_bounds(hud, Rect2(Vector2.ZERO, Vector2(dimensions)))
		hud._toggle_camp()
	root.size = Vector2i(720, 1280)
	await _settle()
	if DisplayServer.get_name() != "headless":
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://build/portrait-gameplay.png")
	await create_timer(1.1).timeout
	_check(game.find_children("FloatingDamage*", "Label", false, false).is_empty(), "Damage labels leaked after tween")
	app.queue_free()
	await process_frame
	if failures == 0:
		print("PASS portrait flow bounds, 3 viewport ratios, touch at 4 zooms, persistent/cycle selection, received/dealt/fatal damage and cleanup")
	quit(0 if failures == 0 else 1)
