extends Node2D
@onready var ui_manager: CanvasLayer = $UIManager

signal save_loaded

var paused: bool = true
var level_root: LevelRoot
var loaded: bool = false

func _ready() -> void:
	level_root = get_tree().current_scene.get_node("LevelRoot")
	load_game()
	loaded = true
	save_loaded.emit()
	level_root.building_handler.log_buildings()

func get_player() -> CharacterBody2D:
	if !loaded:
		await save_loaded
	
	await get_tree().process_frame
	
	var p = get_tree().get_first_node_in_group("Player")
	return p
	
func get_root() -> Variant:
	for child in get_children():
		if child is LevelRoot:
			return child
	print("Level root not found")
	return null

func handle_pause() -> void:
	if !paused:
		ui_manager.show_pause_menu(false)
		get_tree().paused = false
		Engine.time_scale = 1
	else:
		ui_manager.show_pause_menu(true)
		get_tree().paused = true
		Engine.time_scale = 0
	
	paused = !paused

func handle_save():
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.get_path())
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")

		# JSON provides a static method to serialized JSON string.
		var json_string = JSON.stringify(node_data)

		# Store the save dictionary as a new line in the save file.
		save_file.store_line(json_string)

func handle_quit() -> void:
	get_tree().quit()

func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.

	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	print("Deleting Persists")
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		print("Deleting Persist Node ", i.name, "ID: ", i.get_instance_id())
		i.queue_free()

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()

		# Creates the helper class to interact with JSON.
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object.
		var node_data = json.data

		# Firstly, we need to create the object and add it to the tree and set its position.
		var new_object = load(node_data["filename"]).instantiate()
		get_node(node_data["parent"]).add_child(new_object)
		new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])

		# Now we set the remaining variables.
		for i in node_data.keys():
			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
				continue
			new_object.set(i, node_data[i])
			if i == "inventory":
				new_object.set(i, convert_keys_to_int(node_data[i]))
		
		if new_object is Building && !new_object.preplaced:
			level_root.building_handler.building_list.append(new_object)

func convert_keys_to_int(dict: Dictionary) -> Dictionary:
	var new_dict := {}

	for key in dict.keys():
		new_dict[int(key)] = dict[key]

	return new_dict
