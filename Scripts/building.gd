extends StaticBody2D
class_name Building

# All your stats are now neatly contained inside this single variable
@export var building_data: BuildingData
@export var landlocked: bool = true
@export var preplaced: bool = false

var building_space: BuildingSpace

var active: bool = true
var data_path: String

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

func setup_data(data: Variant) -> void:
	if data is BuildingData:
		building_data = data
	if data is String:
		data_path = data
	if building_data:
		data_path = building_data.resource_path
	elif data_path:
		building_data = load(data_path)
	else:
		print("building_data not set")

func itemID_to_data_in_dict(dict) -> Dictionary:
	var switched = {"data": null, "qty" : 0}
	if dict["data"] != null:
		switched["data"] = Catalogue.item_catalogue[int(dict["data"])]
		switched["qty"] = int(dict["qty"])
	return switched

func unpack_itemID(dict: Dictionary) -> Variant:
	if dict.has("data") && dict["data"]:
		return dict["data"].itemID
	else:
		return null

func destroy_building() -> void:
	queue_free()

func load_trigger() -> void:
	pass
