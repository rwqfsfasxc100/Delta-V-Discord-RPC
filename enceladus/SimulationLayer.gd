extends "res://enceladus/Simulator/SimulationLayer.gd"

onready var rpc = get_tree().get_root().get_node("DiscordRPC_Network")

func clearSimulation():
	if visible:
		rpc.loader_changed("enceladus",1)
	.clearSimulation()

func startSimulation(sim):
	if sim and not visible:
		rpc.loader_changed("enceladus",2,"simulator")
	.startSimulation(sim)
	
