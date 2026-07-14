extends Node2D
class_name WarpGate

@export var warpData: WarpData


func warp_requirement() -> bool:
	return true

func warp(target) -> void:
	target.global_position = Catalogue.warp_catalogue[warpData.destination_gate].origin

func _on_interact() -> void:
	warp(await Game.get_player())
