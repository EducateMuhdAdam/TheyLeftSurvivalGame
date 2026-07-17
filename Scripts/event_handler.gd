extends Node2D


var level_root: LevelRoot
var player: CharacterBody2D

func _ready() -> void:
	level_root = await Game.get_level_root()
	player = await Game.get_player()
	EventBus.execute_event.connect(handle_event)
	
func handle_event(eventID: int) -> void:
	match eventID:
		1:
			#Turn off pollution
			var area: AreaData = load("res://Data/areas/1_empty_lot.tres")
			EventBus.fade_out.emit(true)
			await EventBus.fade_out_finished
			EventBus.set_camera_limit.emit(area.limit_ltrb)
			EventBus.fade_out.emit(false)
			await EventBus.fade_out_finished
			await get_tree().create_timer(2.0).timeout
			level_root.change_tile(level_root.decoration_layer, Vector2i(35,2), Vector2i(11, 12))
			level_root.change_tile(level_root.decoration_layer, Vector2i(36,2), Vector2i(12, 12))
			await get_tree().create_timer(2.0).timeout
			EventBus.fade_out.emit(true)
			await EventBus.fade_out_finished
			EventBus.set_camera_limit.emit(player.areaData.limit_ltrb)
			EventBus.fade_out.emit(false)
		2:	
			#Open Door to Town
			var dict: Dictionary[Vector2i, Vector2i] = {
				Vector2i(14, -1): Vector2i(6, 11), 
				Vector2i(15, -1): Vector2i(7, 11), 
				Vector2i(14, 0): Vector2i(6,12), 
				Vector2i(15, 0): Vector2i(7, 12)
				}
			level_root.change_tile_from_dict(level_root.decoration_layer, dict)
		_:
			print("Event ID ", eventID, " not found")
