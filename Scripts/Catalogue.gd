extends Node

var item_catalogue: Dictionary[int, ItemData]
var crafting_catalogue: Dictionary[int, CraftingData]
var warp_catalogue: Dictionary[int, WarpData]
var cooking_reference: Dictionary = {
	2: 5
}
var plant_reference: Dictionary = {
	7: 8
}
var eating_reference: Dictionary = {
	2: 15.0,
	5: 60.0,
	8: 25.0
}
var drinking_reference: Dictionary = {
	3: 60.0
}

func _ready() -> void:
	item_catalogue = get_item_resources()
	crafting_catalogue = get_crafting_resources()
	cooking_reference = get_cooking_reference()
	plant_reference = get_plant_reference()
	warp_catalogue = get_warp_resources()

func get_cooking_reference() -> Dictionary:
	var reference = {}
	for key in cooking_reference.keys():
		reference[key] = item_catalogue[cooking_reference[key]]
	return reference

func get_plant_reference() -> Dictionary:
	var reference = {}
	for key in plant_reference.keys():
		reference[key] = item_catalogue[plant_reference[key]]
	return reference

func get_item_resources() -> Dictionary[int, ItemData]:
	const PATH: String = "res://Data/items/"
	var resources: Dictionary[int, ItemData] = {}
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

func get_crafting_resources() -> Dictionary[int, CraftingData]:
	const PATH: String = "res://Data/recipes/"
	var resources: Dictionary[int, CraftingData] = {}
	var dir = DirAccess.open(PATH)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			# Ignore directories and only grab scene files
			if !dir.current_is_dir() and file_name.ends_with(".tres"):
				var scene_path = PATH + "/" + file_name
				var scene_resource: CraftingData = load(scene_path)
					
				if scene_resource:
					var key = scene_resource.craftingID
					resources[key] = scene_resource
					print("Successfully loaded: ", scene_path)
			file_name = dir.get_next()
			
		dir.list_dir_end()
	else:
		print("An error occurred when trying to access the path.")
		
	return resources

func get_warp_resources() -> Dictionary[int, WarpData]:
	const PATH: String = "res://Data/warpgates/"
	var resources: Dictionary[int, WarpData] = {}
	var dir = DirAccess.open(PATH)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			# Ignore directories and only grab scene files
			if !dir.current_is_dir() and file_name.ends_with(".tres"):
				var scene_path = PATH + "/" + file_name
				var scene_resource: WarpData = load(scene_path)
					
				if scene_resource:
					var key = scene_resource.warpID
					resources[key] = scene_resource
					print("Successfully loaded: ", scene_path)
			file_name = dir.get_next()
			
		dir.list_dir_end()
	else:
		print("An error occurred when trying to access the path.")
		
	return resources
