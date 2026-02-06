extends "res://enceladus/Simulator/SimulationLayer.gd"

onready var rpc = get_tree().get_root().get_node("DiscordRPC_Network")

signal simulationEnd(scene)

func _ready():
	connect("simulation",rpc,"loader_changed",["enceladus","simulator"])
	connect("simulationEnd",rpc,"loader_changed")
func clearSimulation():
	.clearSimulation()
	emit_signal("simulationEnd","enceladus")
