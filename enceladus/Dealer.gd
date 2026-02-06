extends "res://enceladus/Dealer.gd"

onready var rpc = get_tree().get_root().get_node("DiscordRPC_Network")

func show():
	if visible or $Shower.is_playing():
		return
	.show()
	if showOwned:
		rpc.call_deferred("loader_changed","enceladus_prime",1,"fleet")
	else:
		rpc.call_deferred("loader_changed","enceladus_prime",1,"dealer")

func hide():
	if not visible or $Shower.current_animation == "hide":
		return
	.hide()
	rpc.loader_changed("enceladus",0,"")
#	print("%s hidden" % self.name)
