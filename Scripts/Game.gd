extends Node

var player: CharacterBody2D = null
var level_root: LevelRoot = null
signal load_player
signal load_level_root

func get_player() -> CharacterBody2D:
	if !player:
		await load_player
		
	return player

func set_player(p: CharacterBody2D) -> void:
	print("Setting Player")
	player = p
	load_player.emit()
	
func get_level_root() -> LevelRoot:
	if !level_root:
		await load_level_root
		
	return level_root

func set_level_root(lr: LevelRoot) -> void:
	print("Setting Level Root")
	level_root = lr
	load_level_root.emit()
