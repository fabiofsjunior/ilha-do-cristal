extends SceneTree
## Executes real loader/animation transitions; visual quality remains manual.
func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene = load("res://tools/art/sprite_test/sprite_test.tscn").instantiate()
	root.add_child(scene)
	var checks := 0
	var selector_checks := 0
	for candidate_index in range(3):
		scene.candidate_index = candidate_index
		for state in ["idle", "walk"]:
			for facing in ["N", "S"]:
				for value in [0.5, 0.75, 1.0, 1.25]:
					scene.animation_name = state
					scene.direction = facing
					scene.zoom_value = value
					scene._refresh()
					var controls = scene.get_node("CanvasLayer/VBoxContainer")
					if controls.get_node("Candidate").get_selected() != candidate_index:
						push_error("Candidate selector mismatch: V%d" % (candidate_index + 1))
						quit(1)
						return
					if controls.get_node("Direction").get_selected() != scene.DIRECTIONS.find(facing):
						push_error("Direction selector mismatch: " + facing)
						quit(1)
						return
					if controls.get_node("State").get_selected() != ["idle", "walk"].find(state):
						push_error("Animation selector mismatch: " + state)
						quit(1)
						return
					if not is_equal_approx(controls.get_node("Zoom").value, value):
						push_error("Zoom selector mismatch: %.2f" % value)
						quit(1)
						return
					selector_checks += 1
					if not scene.available:
						push_error("Scene loader failed: V%d %s %s %.2f" % [candidate_index + 1, state, facing, value])
						quit(1)
						return
					var expected := 4 if state == "idle" else 6
					if scene.actor.sprite_frames.get_frame_count(state) != expected:
						push_error("Frame count mismatch: V%d %s" % [candidate_index + 1, state])
						quit(1)
						return
					for frame in range(expected):
						scene.actor.frame = frame
						checks += 1
	print("Sprite loader QA passed: %d frame selections and %d synchronized selector states across V1/V2/V3 (visual/Android approval pending)." % [checks, selector_checks])
	quit(0)
