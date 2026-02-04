extends Node

const DEFAULT_IP = "127.0.0.1"
const DEFAULT_PORT = 28041

export var reconnect_delay = 3

func _ready():
	var timer = Timer.new()
	timer.wait_time = reconnect_delay
	timer.one_shot = true
	timer.name = "HUDTIMER"
	timer.connect("ready",self,"start_timer")
	timer.connect("timeout",self,"recheck")
	call_deferred("add_child",timer)
	get_tree().connect("server_disconnected",self,"_disconnected")
	get_tree().connect("connection_failed",self,"_disconnected")
	get_tree().connect("connected_to_server",self,"_connected_to_server")
	connect_to_server()

var connected = false

var hudTimer

func start_timer():
	if not hudTimer:
		hudTimer = get_node_or_null("HUDTIMER")
	if hudTimer:
		hudTimer.start()

func recheck():
	if not connected:
		connect_to_server()
		start_timer()

func connect_to_server():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(DEFAULT_IP,DEFAULT_PORT)
	get_tree().set_network_peer(peer)

func _connected_to_server():
	Debug.l("DiscordRPC: connected")
	connected = true

func _disconnected():
	Debug.l("DiscordRPC: disconnected")
	connected = false
	start_timer()

func set_icon(ship):
	if connected:
		rpc("set_icon",ship)
