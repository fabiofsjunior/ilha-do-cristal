extends Node
## LAN movement preview. Combat, inventory and saves remain local.
signal connected
signal disconnected(reason: String)
signal status_changed(message: String)
signal rooms_changed
const PORT := 27840
const DISCOVERY_PORT := 27841
const PROTOCOL := "crystal-movement-v1"
const PLAYER := preload("res://game/scenes/player.tscn")
var room_code := ""
var rooms: Dictionary = {}
var peers: Dictionary = {}
var world
var udp := PacketPeerUDP.new()
var elapsed := 0.0
var tick := 0.0
var character_id := "melissa"
var layout_hash := ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layout_hash = FileAccess.get_sha256("res://game/data/first_island_layout.json")
	multiplayer.connected_to_server.connect(func(): connected.emit())
	multiplayer.connection_failed.connect(func(): status_changed.emit("Falha ao conectar. Confira IP e Wi-Fi."); close())
	multiplayer.server_disconnected.connect(func():
		close()
		disconnected.emit("O anfitrião encerrou a sala. Seus itens e saves permanecem locais.")
	)
	multiplayer.peer_disconnected.connect(_remove_peer)
	start_discovery()

func start_discovery() -> void:
	udp.close()
	var error := udp.bind(DISCOVERY_PORT, "0.0.0.0")
	if error != OK:
		status_changed.emit("Descoberta indisponível (%s); use o IP local." % error)
	udp.set_broadcast_enabled(true)

func host(id: String) -> Error:
	close()
	character_id = id
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(PORT, 1)
	if error != OK:
		status_changed.emit("Não foi possível hospedar (%s)." % error)
		return error
	multiplayer.multiplayer_peer = peer
	var alphabet := "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
	room_code = ""
	for i in 6: room_code += alphabet[randi() % alphabet.length()]
	status_changed.emit(room_description())
	return OK

func join(address: String, id: String) -> Error:
	var target := address.strip_edges()
	if rooms.has(target.to_upper()): target = rooms[target.to_upper()].ip
	if not target.is_valid_ip_address():
		status_changed.emit("Sala não encontrada. Atualize a busca ou informe o IP do anfitrião.")
		return ERR_INVALID_PARAMETER
	close()
	character_id = id
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client(target, PORT)
	if error == OK: multiplayer.multiplayer_peer = peer
	else: status_changed.emit("Erro ao conectar (%s)." % error)
	return error

func attach_world(value: Node) -> void:
	world = value
	if multiplayer.has_multiplayer_peer() and not multiplayer.is_server():
		register.rpc_id(1, character_id, layout_hash)

@rpc("any_peer", "call_remote", "reliable")
func register(id: String, fingerprint: String) -> void:
	if not multiplayer.is_server(): return
	var sender := multiplayer.get_remote_sender_id()
	if fingerprint != layout_hash or id not in ["melissa", "helena", "maira", "fabio"]:
		multiplayer.multiplayer_peer.disconnect_peer(sender)
		status_changed.emit("Cliente recusado: versão do mapa ou aparência incompatível.")
		return
	var spawn: Vector2 = world._player.global_position + Vector2(36, 0)
	_spawn(sender, id, spawn)
	welcome.rpc_id(sender, character_id, world._player.global_position, spawn, room_code)

@rpc("authority", "call_remote", "reliable")
func welcome(id: String, host_position: Vector2, spawn: Vector2, code: String) -> void:
	room_code = code
	world._player.global_position = spawn
	_spawn(1, id, host_position)
	status_changed.emit("Sala %s · movimento LAN · combate e saves locais" % code)

func _spawn(peer_id: int, id: String, position: Vector2) -> void:
	if peers.has(peer_id) or not is_instance_valid(world): return
	var body = PLAYER.instantiate()
	body.selected_character_id = id
	body.position = position
	body.name = "LanPlayer_%s" % peer_id
	world.get_node("Actors").add_child(body)
	body.set_physics_process(false)
	body.remove_from_group("combat_player")
	var sprite = world._iso_view._make_sprite(world._iso_view._actor_texture(body), body.name)
	peers[peer_id] = {"body": body, "sprite": sprite, "last": Time.get_ticks_msec()}

func _process(delta: float) -> void:
	elapsed += delta
	while udp.get_available_packet_count() > 0:
		var packet := udp.get_packet()
		var ip := udp.get_packet_ip()
		var data = JSON.parse_string(packet.get_string_from_utf8())
		if data is Dictionary and data.get("protocol") == PROTOCOL and str(data.get("code", "")).length() == 6:
			rooms[data.code] = {"ip": ip, "seen": Time.get_ticks_msec()}
			rooms_changed.emit()
	if elapsed >= 1.0:
		elapsed = 0.0
		for code in rooms.keys():
			if Time.get_ticks_msec() - int(rooms[code].seen) > 4000:
				rooms.erase(code)
				rooms_changed.emit()
		if multiplayer.has_multiplayer_peer() and multiplayer.is_server():
			udp.set_dest_address("255.255.255.255", DISCOVERY_PORT)
			udp.put_packet(JSON.stringify({"protocol": PROTOCOL, "code": room_code}).to_utf8_buffer())
	if not is_instance_valid(world): return
	for data in peers.values():
		var body = data.body
		var pose: AnimatedSprite2D = body.get_node("AnimatedSprite2D")
		data.sprite.texture = world._iso_view._actor_texture(body)
		data.sprite.offset = Vector2(pose.offset.x, -pose.offset.y)
		data.sprite.position = Vector3(body.position.x / 32.0, 0.04, body.position.y / 32.0)
	tick += delta
	if tick < 0.05 or not multiplayer.has_multiplayer_peer(): return
	tick = 0.0
	if multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED: return
	if multiplayer.is_server():
		for peer_id in peers:
			state.rpc_id(peer_id, world._player.position, world._player.facing, peers[peer_id].body.position, peers[peer_id].body.facing)
	elif peers.has(1):
		proposal.rpc_id(1, world._player.position, world._player.facing)

@rpc("any_peer", "call_remote", "unreliable_ordered")
func proposal(position: Vector2, facing: String) -> void:
	if not multiplayer.is_server() or not position.is_finite(): return
	var sender := multiplayer.get_remote_sender_id()
	if not peers.has(sender): return
	var data: Dictionary = peers[sender]
	var now := Time.get_ticks_msec()
	var seconds := clampf((now - int(data.last)) / 1000.0, 0.0, 0.25)
	data.last = now
	var body = data.body
	var displacement: Vector2 = (position - body.position).limit_length(165.0 * seconds + 2.0)
	body.move_and_collide(displacement)
	_update_pose(body, facing, displacement.length() > 0.1)

@rpc("authority", "call_remote", "unreliable_ordered")
func state(host_position: Vector2, host_facing: String, accepted_position: Vector2, client_facing: String) -> void:
	if not peers.has(1): return
	var body = peers[1].body
	_update_pose(body, host_facing, body.position.distance_to(host_position) > 0.1)
	body.position = host_position
	if world._player.position.distance_to(accepted_position) > 40.0:
		world._player.position = accepted_position

func _update_pose(body, facing: String, moving: bool) -> void:
	if facing not in body.DIRECTIONS: return
	body.facing = facing
	body._play(("walk_" if moving else "idle_") + facing)

func _remove_peer(id: int) -> void:
	if not peers.has(id): return
	for key in ["body", "sprite"]:
		if is_instance_valid(peers[id][key]): peers[id][key].queue_free()
	peers.erase(id)
	status_changed.emit("Jogador desconectado da sala %s." % room_code)

func close() -> void:
	for id in peers.keys(): _remove_peer(id)
	world = null
	room_code = ""
	if multiplayer.has_multiplayer_peer(): multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null

func room_description() -> String:
	var addresses: Array[String] = []
	if multiplayer.has_multiplayer_peer() and multiplayer.is_server():
		for address in IP.get_local_addresses():
			if address.is_valid_ip_address() and not address.contains(":") and not address.begins_with("127."):
				addresses.append(address)
	var ip_text := " · IP " + ", ".join(addresses) if not addresses.is_empty() else ""
	return "Sala %s%s · movimento LAN · combate e saves locais" % [room_code, ip_text]
