extends "res://Loader.gd"

signal gone_to(where)

func goNow(where):
	.goNow(where)
	emit_signal("gone_to",where)
