extends Node2D

export (Array, PackedScene) var levels
export (PackedScene) var player

var currentLevelIndex = 0


func start_current_level():
	var level = levels[currentLevelIndex].instance()
	level.player_scene = player
	add_child(level, true)
	level.connect("on_finish_level", self, "_on_current_level_finish")


func start_next_level():
	var finishedLevel = get_child(0)
	remove_child(finishedLevel)
	print(get_children())
	currentLevelIndex += 1
	start_current_level()


func _on_current_level_finish():
	call_deferred('start_next_level')


func _ready():
	start_current_level()
