extends Node2D

export (PackedScene) var player_scene
signal on_finish_level


func _ready():
	var player = player_scene.instance()
	add_child(player, true)
	player.transform = $Start.transform


func _on_End_body_entered(_body):
	emit_signal("on_finish_level")
