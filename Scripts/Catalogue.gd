extends Node

var item_catalogue: Dictionary
var cooking_reference: Dictionary = {
	2: 5
}


func _ready() -> void:
	item_catalogue = get_item_resources()
	cooking_reference = get_cooking_reference()

func get_cooking_reference() -> Dictionary:
	var reference = {}
	for key in cooking_reference.keys():
		reference[key] = item_catalogue[cooking_reference[key]]
	return reference

func get_item_resources() -> Dictionary:
	const PATH: String = "res://Data/items/"
	var resources: Dictionary = {}
	var dir = DirAccess.open(PATH)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			# Ignore directories and only grab scene files
			if !dir.current_is_dir() and file_name.ends_with(".tres"):
				var scene_path = PATH + "/" + file_name
				var scene_resource = load(scene_path)
					
				if scene_resource:
					var key = scene_resource.itemID
					resources[key] = scene_resource
					print("Successfully loaded: ", scene_path)
			file_name = dir.get_next()
			
		dir.list_dir_end()
	else:
		print("An error occurred when trying to access the path.")
		
	return resources
