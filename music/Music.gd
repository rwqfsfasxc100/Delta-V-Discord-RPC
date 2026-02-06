extends "res://Music.gd"

onready var rpc = get_tree().get_root().get_node("DiscordRPC_Network")

var current_state = ""

func _ready():
	rpc.connect("rpc_timer_complete",self,"calc")

func calc():
	var highest_prio = 0
	var state = ""
	for i in targetMood:
		var prio = targetMood[i]
		if prio > highest_prio:
			state = i
			highest_prio = prio
	var priority = priorities[state]
	if priority > 0:
		rpc.loader_changed("ring",1,state)
