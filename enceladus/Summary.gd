extends "res://enceladus/Summary.gd"

onready var rpc = get_tree().get_root().get_node("DiscordRPC_Network")

func loadOutput(outputData, processed = {}, rem = {}) -> bool:
	var val = .loadOutput(outputData,processed,rem)
	if val:
		rpc.call_deferred("loader_changed","enceladus_prime",1,"dive_summary")
	else:
		rpc.loader_changed("enceladus",0,"")
	return val
