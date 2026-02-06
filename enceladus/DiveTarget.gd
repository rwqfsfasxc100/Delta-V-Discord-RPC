extends "res://enceladus/DiveTarget.gd"

onready var rpc = get_tree().get_root().get_node("DiscordRPC_Network")

func show():
	if visible or $Player.is_playing():
		return
	.show()
	rpc.call_deferred("loader_changed","enceladus_prime",1,"dive_target")

func hide():
	if not visible or $Player.current_animation == "hide":
		return
	.hide()
	rpc.loader_changed("enceladus",0,"")
#	print("%s hidden" % self.name)
