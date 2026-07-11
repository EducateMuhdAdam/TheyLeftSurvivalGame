extends StaticBody2D
class_name Building

# All your stats are now neatly contained inside this single variable
@export var data: BuildingData
@export var landlocked: bool = true

var building_space: BuildingSpace

var building_data: BuildingData = null

var interact: Callable = func():
	pass

func get_building_space() -> Variant:
	if building_space:
		return building_space
	for child in get_children():
		if child is BuildingSpace:
			building_space = child
			return child
	print("Can't find Building Space")
	return null

func activate_interaction(active: bool) -> void:
	for child in get_children():
		if child is InteractionArea:
			child.active = active
			return
	print("InteractionArea not set")

func get_placement_requirement() -> Callable:
	if landlocked:
		return is_land
	else:
		return is_water

func is_water(data: TileData) -> bool:
	return data != null && data.get_custom_data("water")

func is_land(data: TileData) -> bool:
	return data != null && !data.get_custom_data("water")

func save() -> Dictionary:
	print("Save Not Set Up For Building")
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y
	}
	return save_dict
