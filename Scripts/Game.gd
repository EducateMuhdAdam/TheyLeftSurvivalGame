extends Node

var player: CharacterBody2D = null
signal load_player

func get_player() -> CharacterBody2D:
	if !player:
		await load_player
		
	return player

func set_player(p: CharacterBody2D) -> void:
	print("Setting Player")
	player = p
	load_player.emit()
