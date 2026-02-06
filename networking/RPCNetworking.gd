extends Node

const DEFAULT_IP = "127.0.0.1"
const DEFAULT_PORT = 28041

export var reconnect_delay = 3

export var update_delay = 4.5

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

func loader_changed(area,how_specific = ""):
	if loaded:
		print("DiscordRPC: changing RPC load to [%s], specific section? [%s]" % [area,how_specific])
		scene = area
		yield(get_tree(),"idle_frame")
		match scene:
			"enceladus":
				pass
				
				
				
				
				
			"title_screen":
				var current_subsection = ""
				match how_specific:
					"simulator":
						current_subsection = "simulator"
				
				if not current_icon == "enceladus":
					current_icon = "enceladus"
				
				
				
				
			"ring":
				if (not current_icon in validShipIcons) or (not current_icon == "empty"):
					var shipIcon = "empty"
					var playership = CurrentGame.getPlayerShip()
					var thisShip = ""
					if "baseShipName" in playership and playership.baseShipName in validShips:
						thisShip = playership.baseShipName
					if "shipName" in playership and playership.shipName in validShips:
						thisShip = playership.shipName
					if thisShip in validShips:
						shipIcon = validShips[thisShip]
					current_icon = shipIcon
				
var update_timer = Timer.new()

func update_timer_finished():
	update_rpc()
	update_timer.start(update_delay/Engine.get_time_scale())

export var validShips = {
	"SHIP_TRTL":"k37",
	"SHIP_AT225":"k225",
	"SHIP_COTHON":"cothon",
	"SHIP_PROSPECTOR_BALD":"bald_eagle",
	"SHIP_PROSPECTOR":"prospector",
	"SHIP_EIME":"model_e",
	"SHIP_KITSUNE":"kitsune",
	"SHIP_OCP209":"ocp",
}

var validShipIcons = [
	"k37",
	"k225",
	"cothon",
	"bald_eagle",
	"prospector",
	"model_e",
	"kitsune",
	"ocp",
]

func _ready():
	print("DiscordRPC: loaded")
	var timer = Timer.new()
	timer.wait_time = reconnect_delay
	timer.one_shot = true
	timer.name = "HUDTIMER"
	timer.connect("ready",self,"start_timer")
	timer.connect("timeout",self,"recheck")
	
	update_timer.wait_time = reconnect_delay
	update_timer.one_shot = true
	update_timer.name = "UPDATE_TIMER"
	update_timer.connect("timeout",self,"update_timer_finished")
	
	
	call_deferred("add_child",timer)
	call_deferred("add_child",update_timer)
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
	update_timer.start(update_delay/Engine.get_time_scale())

func _disconnected():
	Debug.l("DiscordRPC: disconnected")
	print("DiscordRPC: disconnected")
	connected = false
	start_timer()
	update_timer.stop()

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

