extends Node

var item_catalogue: Dictionary[int, ItemData]
var crafting_catalogue: Dictionary[int, CraftingData]
var warp_catalogue: Dictionary[int, WarpData]
var message_catalogue: Dictionary[int, MessageData]
var building_catalogue: Dictionary[int, BuildingData]
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
var item_to_message_reference: Dictionary = {
	101: 1,
	102: 4,
	103: 3,
	104: 5,
	105: 6,
	106: 7
}

var building_recipe_reference: Dictionary = {
	102: 3,
	104: 10,
	105: [12, 13],
	106: 5
}

var crafting_recipe_reference: Dictionary = {
}

var scrap_reference: Dictionary = {
	3: 1
}

func _ready() -> void:
	item_catalogue = get_item_resources()
	crafting_catalogue = get_crafting_resources()
	cooking_reference = get_cooking_reference()
	plant_reference = get_plant_reference()
	warp_catalogue = get_warp_resources()
	message_catalogue = get_message_resources()
	item_to_message_reference = get_item_to_message_reference()
	scrap_reference = get_scrap_reference()
	building_catalogue = get_building_resources()

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

func get_scrap_reference() -> Dictionary:
	var reference = {}
	for key in scrap_reference.keys():
		reference[key] = item_catalogue[scrap_reference[key]]
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

func get_message_resources() -> Dictionary[int, MessageData]:
	const PATH: String = "res://Data/messages/"
	var resources: Dictionary[int, MessageData] = {}
	var dir = DirAccess.open(PATH)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			# Ignore directories and only grab scene files
			if !dir.current_is_dir() and file_name.ends_with(".tres"):
				var scene_path = PATH + "/" + file_name
				var scene_resource: MessageData = load(scene_path)
					
				if scene_resource:
					var key = scene_resource.messageID
					resources[key] = scene_resource
					print("Successfully loaded: ", scene_path)
			file_name = dir.get_next()
			
		dir.list_dir_end()
	else:
		print("An error occurred when trying to access the path.")
		
	return resources

func get_building_resources() -> Dictionary[int, BuildingData]:
	const PATH: String = "res://Data/buildings/"
	var resources: Dictionary[int, BuildingData] = {}
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
					var key = scene_resource.building_id
					resources[key] = scene_resource
					print("Successfully loaded: ", scene_path)
			file_name = dir.get_next()
			
		dir.list_dir_end()
	else:
		print("An error occurred when trying to access the path.")
		
	return resources

func get_item_to_message_reference() -> Dictionary:
	var reference = {}
	for key in item_to_message_reference.keys():
		reference[key] = message_catalogue[item_to_message_reference[key]]
	return reference
