extends Node2D
class_name WarpGate

@export var warpData: WarpData

@export var unlocked: bool = true


func warp_requirement() -> bool:
	return true

func warp(target: Node2D) -> void:
	var destination_gate: WarpData = Catalogue.warp_catalogue[warpData.destination_gate]
	
	EventBus.fade_out.emit(true)
	await EventBus.fade_out_finished
	target.global_position = destination_gate.origin
	EventBus.change_area.emit(destination_gate.area_data)
	EventBus.set_camera_limit.emit(destination_gate.area_data.limit_ltrb)
	EventBus.position_camera.emit(target.global_position)
	EventBus.fade_out.emit(false)

func unlock_event() -> void:
	pass

func _on_interact() -> void:
	if unlocked:
		warp(await Game.get_player())
	elif warp_requirement():
		unlock_event()
	else:
		print("Requirement Not Met")
