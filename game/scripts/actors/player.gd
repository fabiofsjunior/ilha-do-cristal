extends CharacterBody2D

const SPEED := 165.0
const DIRECTIONS := ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
const APPEARANCE_DATA = preload("res://game/scripts/actors/appearance_data.gd")
const COMBAT_GEOMETRY = preload("res://game/scripts/combat/combat_geometry.gd")

var selected_character_id := "melissa"
var joystick_vector := Vector2.ZERO
var facing := "S"
var input_enabled := true
var _sprite: AnimatedSprite2D
var _sprite_frames: SpriteFrames
var _screen_right_in_world := Vector2.RIGHT
var _screen_down_in_world := Vector2.DOWN


func _ready() -> void:
	add_to_group("combat_player")
	_sprite = get_node("AnimatedSprite2D") as AnimatedSprite2D
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_build_animations()
	_sprite.play("idle_S")


func set_joystick_vector(value: Vector2) -> void:
	joystick_vector = value.limit_length(1.0)


func set_camera_ground_basis(camera_basis: Basis) -> void:
	# Invert the camera projection on the XZ ground plane so screen-relative
	# controls stay aligned with what the player sees in the isometric view.
	var camera_right := Vector2(camera_basis.x.x, camera_basis.x.z)
	var camera_up := Vector2(camera_basis.y.x, camera_basis.y.z)
	var determinant := camera_right.cross(camera_up)
	if absf(determinant) < 0.001:
		push_error("Câmera sem projeção invertível no plano do chão para mapear o movimento.")
		return
	_screen_right_in_world = Vector2(camera_up.y, -camera_up.x) / determinant
	_screen_down_in_world = Vector2(camera_right.y, -camera_right.x) / determinant


func set_input_enabled(enabled: bool) -> void:
	input_enabled = enabled
	if not enabled:
		joystick_vector = Vector2.ZERO
		velocity = Vector2.ZERO


func _physics_process(delta: float) -> void:
	if not input_enabled:
		velocity = Vector2.ZERO
		move_and_slide()
		_play("idle_" + facing)
		return
	var screen_direction := _keyboard_vector()
	if screen_direction.length_squared() < 0.001:
		screen_direction = joystick_vector
	var direction := _screen_direction_to_world(screen_direction)
	velocity = direction * SPEED
	velocity = COMBAT_GEOMETRY.constrain_velocity_to_visual_contact(
		self, get_tree().get_nodes_in_group("combat_creatures"), velocity, delta
	)
	move_and_slide()
	if screen_direction.length_squared() > 0.001:
		facing = _direction_name(screen_direction)
		_play("walk_" + facing)
	else:
		_play("idle_" + facing)


func melee_visual_alpha_extents_px() -> Vector4:
	return COMBAT_GEOMETRY.player_visual_alpha_extents(selected_character_id, facing)


func _keyboard_vector() -> Vector2:
	var result := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		result.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		result.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		result.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		result.y += 1.0
	return result.normalized() if result.length_squared() > 1.0 else result


func _screen_direction_to_world(screen_direction: Vector2) -> Vector2:
	var strength := minf(screen_direction.length(), 1.0)
	if strength < 0.001:
		return Vector2.ZERO
	var world_direction := (
		_screen_right_in_world * screen_direction.x
		+ _screen_down_in_world * screen_direction.y
	)
	return world_direction.normalized() * strength


func _direction_name(direction: Vector2) -> String:
	var x := direction.x
	var y := direction.y
	if absf(x) <= 0.414 * absf(y):
		return "N" if y < 0.0 else "S"
	if absf(y) <= 0.414 * absf(x):
		return "E" if x > 0.0 else "W"
	if x > 0.0:
		return "SE" if y > 0.0 else "NE"
	return "SW" if y > 0.0 else "NW"


func _play(animation_name: String) -> void:
	if (
		_sprite.sprite_frames != null
		and _sprite.sprite_frames.has_animation(animation_name)
		and _sprite.animation != animation_name
	):
		_sprite.play(animation_name)


func _build_animations() -> void:
	var profile: Dictionary = APPEARANCE_DATA.profile_for_id(selected_character_id)
	if profile.is_empty():
		push_error("Aparência não encontrada: %s" % selected_character_id)
		return
	var sprite_frames := SpriteFrames.new()
	if sprite_frames.has_animation("default"):
		sprite_frames.remove_animation("default")
	var metadata_paths := [
		str(profile.get("idle_metadata", "")), str(profile.get("walk_metadata", ""))
	]
	var atlas_textures: Dictionary = {}
	var pivot := Vector2(48.0, 80.0)
	var cell_size := Vector2i(96, 96)
	var direction_rows := DIRECTIONS.duplicate()
	for metadata_path in metadata_paths:
		var metadata: Dictionary = APPEARANCE_DATA.metadata(metadata_path)
		if metadata.is_empty():
			continue
		var atlas_path := APPEARANCE_DATA.atlas_path(metadata_path, metadata)
		if not ResourceLoader.exists(atlas_path):
			push_error("Atlas de personagem não encontrado: %s" % atlas_path)
			continue
		var atlas := load(atlas_path) as Texture2D
		if atlas == null:
			push_error("Falha ao importar atlas de personagem: %s" % atlas_path)
			continue
		atlas_textures[metadata_path] = atlas
		var cell: Array = metadata.get("cell", [96, 96])
		cell_size = Vector2i(int(cell[0]), int(cell[1]))
		var pivot_data: Array = metadata.get("pivot", [48, 80])
		pivot = Vector2(float(pivot_data[0]), float(pivot_data[1]))
		var listed_directions: Array = metadata.get("directions", DIRECTIONS)
		if listed_directions.size() == DIRECTIONS.size():
			direction_rows = listed_directions
	for metadata_path in metadata_paths:
		var metadata: Dictionary = APPEARANCE_DATA.metadata(metadata_path)
		var atlas: Texture2D = atlas_textures.get(metadata_path)
		if metadata.is_empty() or atlas == null:
			continue
		var animation := str(metadata.get("animation", ""))
		var animation_settings: Dictionary = metadata.get("animations", {})
		if animation.is_empty():
			for candidate in ["idle", "walk", "attack", "hit", "death", "cast"]:
				if animation_settings.has(candidate):
					animation = candidate
					break
		if animation.is_empty():
			push_error("Metadata sem nome de animação: %s" % metadata_path)
			continue
		var animation_data: Dictionary = animation_settings.get(animation, {})
		var frame_count := int(metadata.get("frames", animation_data.get("frames", 1)))
		var fps := float(metadata.get("fps", animation_data.get("fps", 6)))
		var loop := bool(metadata.get("loop", animation_data.get("loop", true)))
		for row in range(DIRECTIONS.size()):
			var direction := str(direction_rows[row])
			var animation_name := "%s_%s" % [animation, direction]
			sprite_frames.add_animation(animation_name)
			sprite_frames.set_animation_speed(animation_name, fps)
			sprite_frames.set_animation_loop(animation_name, loop)
			var row_index := DIRECTIONS.find(direction)
			for frame_index in range(frame_count):
				var frame := AtlasTexture.new()
				frame.atlas = atlas
				frame.region = Rect2(
					Vector2(frame_index * cell_size.x, row_index * cell_size.y),
					Vector2(cell_size.x, cell_size.y)
				)
				sprite_frames.add_frame(animation_name, frame)
	_sprite_frames = sprite_frames
	_sprite.sprite_frames = _sprite_frames
	_sprite.offset = Vector2(cell_size.x * 0.5 - pivot.x, cell_size.y * 0.5 - pivot.y)
	_sprite.play("idle_S")
