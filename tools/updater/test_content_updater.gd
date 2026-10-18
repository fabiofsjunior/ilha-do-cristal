extends SceneTree
## Headless tests for GitHub release parsing and package validation rules.

const CONTENT_UPDATER = preload("res://game/scripts/core/content_updater.gd")

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var release := _valid_release("1.0.1")
	var available: Dictionary = CONTENT_UPDATER.select_latest_content_release([release], "0.1.10", "1.0.0")
	_check(available.get("status") == "available", "A newer valid content release must be offered.")
	_check(available.get("content_version") == "1.0.1", "The content version must come from the release tag.")
	_check(available.get("size") == 1024 * 1024, "The asset size must be exposed for the UI.")
	_check(available.get("release_notes") == "- Novo mapa", "Release metadata must be removed from user-facing notes.")

	var current: Dictionary = CONTENT_UPDATER.select_latest_content_release([_valid_release("1.0.1")], "0.1.10", "1.0.1")
	_check(current.get("status") == "current", "An already installed content version must not be downloaded again.")
	var empty: Dictionary = CONTENT_UPDATER.select_latest_content_release([], "0.1.10", "1.0.0")
	_check(empty.get("status") == "current", "No published content release should mean the app is current.")

	var app_required: Dictionary = CONTENT_UPDATER.select_latest_content_release([_valid_release("1.0.1", "0.1.11")], "0.1.10", "1.0.0")
	_check(app_required.get("status") == "app_update_required", "An incompatible APK must be directed to the app update flow.")

	var bad_digest_release := _valid_release("1.0.1")
	bad_digest_release.assets[0].digest = "sha256:bad"
	var bad_digest: Dictionary = CONTENT_UPDATER.select_latest_content_release([bad_digest_release], "0.1.10", "1.0.0")
	_check(bad_digest.get("status") == "error", "A release without a SHA-256 digest must be rejected.")

	var bad_url_release := _valid_release("1.0.1")
	bad_url_release.assets[0].browser_download_url = "https://example.com/evil.pck"
	var bad_url: Dictionary = CONTENT_UPDATER.select_latest_content_release([bad_url_release], "0.1.10", "1.0.0")
	_check(bad_url.get("status") == "error", "Assets outside the project GitHub Releases must be rejected.")

	var draft := _valid_release("1.0.2")
	draft.draft = true
	var draft_result: Dictionary = CONTENT_UPDATER.select_latest_content_release([draft], "0.1.10", "1.0.0")
	_check(draft_result.get("status") == "current", "Draft releases must never be offered.")
	_check(CONTENT_UPDATER.compare_versions("1.0.10", "1.0.9") > 0, "Version comparison must compare numeric segments.")
	_check(CONTENT_UPDATER.compare_versions("1.0.1", "1.0.1") == 0, "Equal semantic versions must compare equal.")

	if failures == 0:
		print("Content updater tests passed: releases, compatibility, digest, host and version ordering.")
	else:
		push_error("Content updater tests failed: %d" % failures)
	quit(failures)


func _valid_release(version: String, minimum_app := "0.1.10") -> Dictionary:
	var tag := "content-v%s" % version
	var asset_name := "ilha-do-cristal-content-v%s.pck" % version
	return {
		"tag_name": tag,
		"name": "Conteúdo %s" % version,
		"html_url": "https://github.com/fabiofsjunior/ilha-do-cristal/releases/tag/%s" % tag,
		"draft": false,
		"prerelease": false,
		"body": "min_app_version=%s\nmandatory=false\n\n- Novo mapa" % minimum_app,
		"assets": [{
			"name": asset_name,
			"browser_download_url": "https://github.com/fabiofsjunior/ilha-do-cristal/releases/download/%s/%s" % [tag, asset_name],
			"digest": "sha256:" + "a".repeat(64),
			"size": 1024 * 1024
		}]
	}


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)
