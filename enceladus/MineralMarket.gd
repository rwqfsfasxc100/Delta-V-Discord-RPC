extends "res://enceladus/MineralMarket.gd"

onready var rpc = get_tree().get_root().get_node("DiscordRPC_Network")

func show():
	if visible or $Shower.is_playing():
		return
	.show()
	rpc.call_deferred("loader_changed","enceladus_prime",1,"mineral_market")

func hide():
	if not visible or $Shower.current_animation == "hide":
		return
	.hide()
	rpc.loader_changed("enceladus",0,"")
#	print("%s hidden" % self.name)
