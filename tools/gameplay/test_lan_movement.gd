extends SceneTree
const LAN = preload("res://game/scripts/network/lan_session.gd")
const PLAYER = preload("res://game/scenes/player.tscn")
class TestView extends Node3D:
	func _actor_texture(_actor): return GradientTexture2D.new()
	func _make_sprite(texture, key):
		var sprite := Sprite3D.new()
		sprite.name = key
		sprite.texture = texture
		add_child(sprite)
		return sprite
class TestWorld extends Node2D:
	var _player
	var _iso_view
var lan
var world
var role := "host"
var scenario := "movement"
var rejected := false
var lost_host := false
var host_closed := false
var age := 0.0
var saw_peer := false
var saw_movement := false
var ready_client := false
var attacked_speed := false
var sent_nan := false
var previous_remote := Vector2.ZERO
var invalid_step := false
func _initialize() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument == "client": role = "client"
		if argument in ["mismatch", "hostloss"]: scenario = argument
	call_deferred("start")
func start() -> void:
	var holder := Node.new()
	holder.name = "Test"
	root.add_child(holder)
	world = TestWorld.new()
	world.name = "World"
	holder.add_child(world)
	var actors := Node2D.new()
	actors.name = "Actors"
	world.add_child(actors)
	world._player = PLAYER.instantiate()
	world._player.position = Vector2(1000, 1000)
	actors.add_child(world._player)
	world._player.set_physics_process(false)
	world._iso_view = TestView.new()
	world.add_child(world._iso_view)
	lan = LAN.new()
	lan.name = "LanSession"
	holder.add_child(lan)
	lan.status_changed.connect(func(message):
		if message.contains("recusado"): rejected = true
	)
	lan.disconnected.connect(func(_reason): lost_host = true)
	if role == "host":
		assert(lan.host("melissa") == OK)
		lan.attach_world(world)
	else:
		lan.connected.connect(func():
			if scenario == "mismatch": lan.layout_hash = "incompatible"
			lan.attach_world(world)
		)
		assert(lan.join("127.0.0.1", "helena") == OK)
func _process(delta: float) -> bool:
	if lan == null: return false
	age += delta
	if not lan.peers.is_empty():
		saw_peer = true
		if role == "client":
			ready_client = true
			world._player.position.x += 90.0 * delta
			if age > 1.0 and not sent_nan:
				lan.proposal.rpc_id(1, Vector2(NAN, NAN), "S")
				sent_nan = true
			if age > 1.5 and not attacked_speed:
				world._player.position.x += 10000.0
				attacked_speed = true
		else:
			for data in lan.peers.values():
				if data.body.position.x > 1050.0: saw_movement = true
				if not data.body.position.is_finite(): invalid_step = true
				if previous_remote != Vector2.ZERO and previous_remote.distance_to(data.body.position) > 60.0: invalid_step = true
				previous_remote = data.body.position
	if scenario == "hostloss" and role == "host" and age > 1.5 and not host_closed:
		lan.close()
		host_closed = true
	if scenario != "movement" and age > 4.0:
		var success: bool = (rejected if role == "host" else lost_host) if scenario == "mismatch" else (saw_peer if role == "host" else lost_host)
		print("LAN ", scenario, " ", role, " success=", success)
		lan.close()
		quit(0 if success else 1)
		return false
	if scenario != "movement": return false
	if role == "client" and age > 3.0:
		if not ready_client:
			push_error("LAN client handshake failed")
			quit(1)
		else:
			print("PASS LAN client handshake and movement")
			lan.close()
			quit(0)
	if role == "host" and age > 6.0:
		if not saw_peer or not saw_movement or invalid_step or not lan.peers.is_empty():
			push_error("LAN host movement/disconnection failed: %s %s %s" % [saw_peer, saw_movement, lan.peers.size()])
			quit(1)
		else:
			print("PASS LAN host movement clamp and disconnection")
			lan.close()
			quit(0)
	return false
