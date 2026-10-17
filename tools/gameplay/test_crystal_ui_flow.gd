extends SceneTree
const HUD = preload("res://game/scripts/world/first_island_hud.gd")
const PAUSE = preload("res://game/scripts/ui/pause_overlay.gd")
const VOCATIONS = preload("res://game/scripts/ui/vocations_panel.gd")
var _hud

func _initialize() -> void:
	call_deferred("run")

func capture(label: String) -> void:
	await process_frame
	await process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("user://crystal-%s.png" % label)

func run() -> void:
	_hud = HUD.new()
	root.add_child(_hud)
	await process_frame
	_hud.set_combat_state(123, 200, 45, 100, 3, 25, 169, {"wood": 30, "stone": 20, "fiber": 10, "herb": 3, "bandage": 2}, 1, false, 0, "", 0, 1, {})
	assert(_hud._hp_bar.value == 123)
	assert(_hud._mp_bar.value == 45)
	assert(_hud._bag_slots.size() == 24)
	_hud._toggle_inventory()
	await capture("inventory")
	_hud._select_bag_slot(0)
	assert(_hud._item_detail.text.contains("Madeira"))
	assert(_hud._item_detail.text.contains("30"))
	assert(not _hud._craft_bandage_button.disabled)
	_hud._toggle_camp()
	assert(not _hud._camp_upgrade_button.disabled)
	await capture("camp")
	_hud._camp_overlay.hide()
	_hud._talents_overlay.show()
	_hud._refresh_joystick_blocking()
	assert(_hud._joystick.blocked)
	await capture("talents")
	_hud._talents_overlay.hide()
	_hud._refresh_joystick_blocking()
	assert(not _hud._joystick.blocked)
	_hud.set_simplified(true)
	assert(not _hud._status.visible)
	_hud.set_simplified(false)
	assert(_hud._status.visible)
	await capture("hud")
	var pause := PAUSE.new()
	root.add_child(pause)
	await process_frame
	pause.show_save_result(false)
	assert(pause._save_status.text.begins_with("Falha"))
	pause.show_save_result(true)
	assert(pause._save_status.text.contains("Jogo salvo"))
	await capture("pause")
	print("PASS: real resource values, 24 slots, selection, recipe/camp affordability, modal input and save status")
	quit()

