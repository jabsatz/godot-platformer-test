extends Control
signal on_start_game


func _on_Start_button_down(_body):
	emit_signal("on_start_game")
