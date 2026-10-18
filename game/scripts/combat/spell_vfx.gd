extends Node2D
## Short lived, camera projected vector feedback; no unapproved sprite atlas.
var view: Node3D
var source := Vector2.ZERO
var destination := Vector2.ZERO
var skill_id := ""
var elapsed := 0.0
var duration := 0.45

func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= duration or not is_instance_valid(view):
		queue_free()
		return
	queue_redraw()

func _draw() -> void:
	if not is_instance_valid(view) or view.camera == null:
		return
	var a: Vector2 = view.camera.unproject_position(view.world_point(source, 0.4))
	var b: Vector2 = view.camera.unproject_position(view.world_point(destination, 0.4))
	var progress := clampf(elapsed / duration, 0.0, 1.0)
	var color := Color("ffcf56")
	if skill_id.begins_with("mag_"):
		color = Color("6be9ff") if skill_id != "mag_fire" else Color("ff8349")
	color.a = 1.0 - progress
	if skill_id.begins_with("arc_") or skill_id == "mag_bolt" or skill_id == "basic":
		var head := a.lerp(b, progress)
		draw_line(head - (b - a).normalized() * 28.0, head, color, 5.0)
		draw_circle(head, 5.0 if skill_id == "mag_bolt" else 3.0, color)
	else:
		var center := a if skill_id.begins_with("war_") else b
		draw_arc(center, 15.0 + progress * 70.0, 0.0, TAU, 24, color, 5.0)
		for i in range(8):
			var direction := Vector2.from_angle(i * TAU / 8.0)
			draw_line(center + direction * (8.0 + progress * 30.0), center + direction * (18.0 + progress * 68.0), color, 3.0)
