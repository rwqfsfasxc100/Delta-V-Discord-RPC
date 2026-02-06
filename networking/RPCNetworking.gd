extends Node

const DEFAULT_IP = "127.0.0.1"
const DEFAULT_PORT = 28041

export var reconnect_delay = 3

export var update_delay = 4.5

var current_icon = ""
var current_icon_text = ""
var current_small_icon = "icon"
var current_small_icon_text = ""
onready var current_start_timer = OS.get_unix_time()
var current_end_timer = 0
var current_state = ""
var current_details = ""

var loaded = false

signal rpc_timer_complete()

var stack = ["","","",""]
var currentStack = 0
func loader_changed(area,level = 0,how_specific = "",custom_data = {}):
	if custom_data.keys().size() > 0:
		pass
	elif loaded:
		if area != stack[0]:
			current_start_timer = OS.get_unix_time()
			currentStack = 0
			stack[0] = area
		var prev = currentStack
		currentStack = level
#		print("stack change: from [%s] to [%s]" % [prev,currentStack])
		if how_specific != "":
			stack[currentStack] = how_specific
#		print("(%s)" % str(stack))
		var playership = CurrentGame.getPlayerShip()
		
		match stack[0]:
			"enceladus","enceladus_prime":
				current_icon = "enceladus_prime"
				current_details = "DISCORD_AT_ENCELADUS"
				current_state = "DISCORD_AT_ENCELADUS"
				var sn = playership.getShipName()
				match stack[currentStack]:
					"simulator":
						current_details = TranslationServer.translate("DISCORD_IN_MVFS") % sn
					"dive_summary":
						current_details = "DISCORD_IN_DIVE_SUMMARY"
					"dive_target":
						current_details = "DISCORD_IN_DIVE_TARGET"
					"mineral_market":
						current_details = "DISCORD_IN_MINERAL_MARKET"
					"repairs":
						current_details = TranslationServer.translate("DISCORD_IN_REPAIRS") % sn
					"inspection":
						current_details = TranslationServer.translate("DISCORD_IN_INSPECTIONS") % sn
					"equipment":
						current_details = TranslationServer.translate("DISCORD_IN_EQUIPMENT") % sn
					"tuning":
						current_details = TranslationServer.translate("DISCORD_IN_TUNING") % sn
					"ship_logs":
						current_details = "DISCORD_IN_SHIP_LOGS"
					"crew":
						current_details = "DISCORD_IN_CREW"
					"fleet":
						current_details = "DISCORD_IN_FLEET"
					"dealer":
						current_details = "DISCORD_IN_DEALER"
					"services":
						current_details = "DISCORD_IN_SERVICES"
				
			"title_screen":
				current_icon = "empty"
				current_details = "DISCORD_TITLE_SCREEN"
				current_state = "DISCORD_TITLE_SCREEN"
				
				
			"ring":
				current_details = "DISCORD_IN_RING"
				current_state = "DISCORD_IN_RING"
				
				match how_specific:
					"western","western2":
						current_details = "DISCORD_HIGH_DENSITY"
					"mystery","mystery2":
						current_details = "DISCORD_ODDITIES"
					"spooky":
						current_details = "DISCORD_SPOOKY"
					"dare":
						current_details = "DISCORD_DARE"
					"battle":
						current_details = "DISCORD_BATTLE"
					"boss":
						current_details = "DISCORD_BOSS"
					"peril":
						current_details = "DISCORD_PERIL"
					"l:G4A":
						pass
					"l:locust":
						current_details = "DISCORD_LOCUSTS"
				
				var shipIcon = "empty"
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
	emit_signal("rpc_timer_complete")
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
		current_details = "DISCORD_TITLE_SCREEN"
	
	
	
	set_icon(current_icon)
	set_details(current_details)
	set_state(current_state)
	set_start_timer(current_start_timer)
	update_rpc()
	update_timer.start(update_delay/Engine.get_time_scale())

func _disconnected(how = ""):
	Debug.l("DiscordRPC: disconnected")
	print("DiscordRPC: disconnected")
	connected = false
	start_timer()
	update_timer.stop()

func set_icon(ship:String,force_this_icon = true,do_update = false):
	if connected:
		rpc("set_icon",ship,force_this_icon,do_update)

func set_icon_text(text:String,do_update = false):
	if connected:
		rpc("set_icon_text",TranslationServer.translate(text),do_update)

func set_small_icon_text(text:String,do_update = false):
	if connected:
		rpc("set_small_icon_text",TranslationServer.translate(text),do_update)

func set_small_icon(how,force_this_icon = true,do_update = false):
	if connected:
		rpc("set_small_icon",how,force_this_icon,do_update)

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
		set_icon(current_icon)
		set_icon_text(current_icon_text)
		set_small_icon(current_small_icon)
		set_small_icon_text(current_small_icon_text)
		set_start_timer(current_start_timer)
		set_end_timer(current_end_timer)
		set_state(current_state)
		set_details(current_details)
		
		rpc("update_rpc")
#		print("DiscordRPC: sending changes")

