extends Node

const DEFAULT_IP = "127.0.0.1"
const DEFAULT_PORT = 28041

export var reconnect_delay = 3

var current_icon = ""
var current_icon_text = ""
var current_small_icon = ""
var current_small_icon_text = ""
var current_start_timer = 0
var current_end_timer = 0
var current_state = ""
var current_details = ""

var loaded = false
var scene = ""

func loader_changed(how):
	if loaded:
		scene = how
		yield(get_tree(),"idle_frame")
		
		
		
		match scene:
			"enceladus":
				pass
			"title_screen":
				pass
			"ring":
				pass
		
		
		
		


func _ready():
	print("DiscordRPC: loaded")
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
	Tool.deferCallInPhysics(self,"set",["loaded",true])

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
		print("DiscordRPC: not connected, rechecking")
		start_timer()

func connect_to_server():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(DEFAULT_IP,DEFAULT_PORT)
	print("DiscordRPC: connecting to server")
	get_tree().set_network_peer(peer)

func _connected_to_server():
	Debug.l("DiscordRPC: connected")
	print("DiscordRPC: connected")
	connected = true
	if current_icon == "":
		current_icon = "empty"
	if current_details == "":
		current_details = "Connected to game"
	
	
	
	set_icon(current_icon)
	set_details(current_details)
	set_state(current_state)
	set_start_timer(current_start_timer)
	update_rpc()

func _disconnected():
	Debug.l("DiscordRPC: disconnected")
	print("DiscordRPC: disconnected")
	connected = false
	start_timer()

func set_icon(ship:String,force_this_icon = false,do_update = false):
	if connected:
		rpc("set_icon",ship,force_this_icon,do_update)

func set_icon_text(text:String,do_update = false):
	if connected:
		rpc("set_icon_text",TranslationServer.translate(text),do_update)

func set_small_icon_text(text:String,do_update = false):
	if connected:
		rpc("set_small_icon_text",TranslationServer.translate(text),do_update)

func set_small_icon(how:bool,do_update = false):
	if connected:
		rpc("set_small_icon",how,do_update)

func set_start_timer(time:int = OS.get_unix_time(),do_update = false):
	if connected:
		rpc("set_start_timer",time,do_update)

func set_end_timer(time:int = 0,do_update = false):
	if connected:
		rpc("set_end_timer",time,do_update)

func set_state(text:String,do_update = false):
	if connected:
		rpc("set_state",TranslationServer.translate(text),do_update)

func set_details(text:String,do_update = false):
	if connected:
		rpc("set_details",TranslationServer.translate(text),do_update)

func update_rpc():
	if connected:
		rpc("update_rpc")

