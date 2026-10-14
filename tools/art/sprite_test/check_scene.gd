extends SceneTree
## Executes real loader/animation transitions; visual quality remains manual.
func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene = load("res://tools/art/sprite_test/sprite_test.tscn").instantiate()
	root.add_child(scene)
	var checks := 0
	for state in ["idle", "walk"]:
		for facing in ["N", "S"]:
			for value in [0.5, 0.75, 1.0, 1.25]:
				scene.animation_name = state
				scene.direction = facing
				scene.zoom_value = value
				scene._refresh()
				if not scene.available:
					push_error("Scene loader failed: %s %s %.2f" % [state, facing, value])
					quit(1)
					return
				var expected := 4 if state == "idle" else 6
				if scene.actor.sprite_frames.get_frame_count(state) != expected:
					push_error("Frame count mismatch: " + state)
					quit(1)
					return
				for frame in range(expected):
					scene.actor.frame = frame
					checks += 1
	print("Sprite loader QA passed: %d frame selections (2 states × N/S × 4 zoom levels). Visual/Android approval pending." % checks)
	quit(0)
