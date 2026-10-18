extends SceneTree
## Exercises the startup screen with a local fake updater; no network is used.

class FakeContentUpdater extends Node:
	signal check_completed(result: Dictionary)
	signal download_progress(downloaded_bytes: int, total_bytes: int)
	signal operation_failed(message: String)
	signal content_installed(version: String)

	var check_result: Dictionary
	var download_called := false

	func check_for_updates() -> void:
		check_completed.emit(check_result)

	func download_available_update() -> void:
		download_called = true

	func get_active_content_version() -> String:
		return "1.0.0"

	func get_release_page_url() -> String:
		return "https://github.com/fabiofsjunior/ilha-do-cristal/releases"


var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var configured_updater := root.get_node_or_null("ContentUpdater")
	if configured_updater != null:
		root.remove_child(configured_updater)
		configured_updater.free()
	var updater := FakeContentUpdater.new()
	updater.name = "ContentUpdater"
	updater.check_result = {
		"status": "available",
		"content_version": "1.0.1",
		"size": 1024 * 1024,
		"release_notes": "- Novo trecho da ilha",
		"mandatory": false
	}
	root.add_child(updater)
	var boot: Control = load("res://game/scenes/update_boot.tscn").instantiate()
	root.add_child(boot)
	await process_frame
	var logo := boot.find_child("GameLogo", true, false) as TextureRect
	_check(logo != null and logo.texture != null, "The startup screen must show the game logo.")
	if logo != null and logo.texture != null:
		_check(logo.texture.get_size() == Vector2(512, 512), "The startup logo must use the generated square brand asset.")
	_check(_button_exists(boot, "Atualizar agora"), "An optional update must show the update button.")
	_check(_button_exists(boot, "Agora não"), "An optional update must allow deferring.")
	_find_button(boot, "Atualizar agora").emit_signal("pressed")
	_check(updater.download_called, "The update action must start the download.")
	_check(_label_exists(boot, "Preparando a atualização"), "Downloading must replace the offer with progress UI.")
	updater.operation_failed.emit("Sem conexão")
	_check(_button_exists(boot, "Continuar com a versão atual"), "An optional update failure must allow offline play.")

	updater.check_completed.emit({
		"status": "available",
		"content_version": "1.0.2",
		"size": 2048,
		"release_notes": "- Correção",
		"mandatory": true
	})
	_check(_button_exists(boot, "Atualizar agora"), "A mandatory update must keep the update action.")
	_check(not _button_exists(boot, "Agora não"), "A mandatory update must not offer a skip button.")
	if failures == 0:
		print("Startup UI tests passed: optional, mandatory, download and offline states.")
	quit(failures)


func _button_exists(node: Node, button_text: String) -> bool:
	return _find_button(node, button_text) != null


func _find_button(node: Node, button_text: String) -> Button:
	if node is Button and str((node as Button).text) == button_text:
		return node as Button
	for child in node.get_children():
		var match := _find_button(child, button_text)
		if match != null:
			return match
	return null


func _label_exists(node: Node, label_text: String) -> bool:
	if node is Label and str((node as Label).text) == label_text:
		return true
	for child in node.get_children():
		if _label_exists(child, label_text):
			return true
	return false


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)
