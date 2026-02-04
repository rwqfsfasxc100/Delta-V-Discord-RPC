extends "res://Game.gd"

onready var rpc = get_tree().get_root().get_node("DiscordRPC_Network")

func _ready():
	rpc.loader_changed("ring")
