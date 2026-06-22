extends Resource
class_name BuildingData

@export var building_id: int = 0
@export var building_name: String = ""
@export var image: Texture2D
@export var x_size: int = 2
@export var y_size: int = 1
@export var building_level: int = 0
	
# Link the physical scene directly to this data

@export_file("*.tscn")
var build_scene_path: String
@export_file("*.tscn")
var ui_scene_path: String
