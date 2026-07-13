extends Building

@onready var interaction_area: InteractionArea = $InteractionArea
var tiles: Array[Dictionary]
var player: CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = await Game.get_player()
	interaction_area.active = false
	var lr: LevelRoot = await Game.get_level_root()
	tiles = get_building_space().get_tiles_under_building(lr.collision_layer)
	lr.remove_collision(tiles[0]["cell_pos"])
	
func save() -> Dictionary:
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"data_path" : data_path
	}
	return save_dict

func destroy_building() -> void:
	if player in building_space.get_overlapping_bodies():
		print("Can't Delete, Player is too close!")
		return
	var lr: LevelRoot = await Game.get_level_root()
	if tiles.size() > 0:
		lr.add_collision(tiles[0]["cell_pos"], tiles[0]["source_id"], tiles[0]["atlas_coords"], tiles[0]["alternative"])
	else:
		print("Error: deleted tile not logged, collision is not restored")
	queue_free()

func load_trigger() -> void:
	var lr: LevelRoot = await Game.get_level_root()
	tiles = get_building_space().get_tiles_under_building(lr.collision_layer)
	lr.remove_collision(tiles[0]["cell_pos"])
