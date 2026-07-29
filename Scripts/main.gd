extends Node2D
@onready var camera: Camera2D = $Camera2D
@onready var title_screen: CanvasLayer = $"Title Screen"

var ui_manager: CanvasLayer
var level_scene = preload("res://Scenes/level_1.tscn")
var ui_manager_scene = preload("res://Scenes/ui_manager.tscn")
var paused: bool = true
var level_root: LevelRoot

func _ready() -> void:
	title_screen.quit_button.pressed.connect(handle_quit)
	title_screen.continue_button.pressed.connect(setup_level)
	title_screen.new_game_button.pressed.connect(setup_level)
	EventBus.link_camera.connect(link_camera)
	EventBus.set_camera_limit.connect(set_camera_limit)
	EventBus.position_camera.connect(position_camera)
	EventBus.fade_out.connect(fade_out)
	

	
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

func setup_level() -> void:
	level_root = level_scene.instantiate()
	ui_manager = ui_manager_scene.instantiate()
	ui_manager.main = self
	add_child(level_root)
	add_child(ui_manager)
	title_screen.hide()
	load_game()
	if !Game.player:
		var player = get_tree().get_first_node_in_group("Player")
		Game.set_player(player)
		EventBus.link_camera.emit(player.rt2d)
	level_root.building_handler.log_buildings()

func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		for node in level_root.building_handler.ObjectContainer.get_children():
			if node is Building && !node.preplaced:
				level_root.building_handler.building_list.append(node)
		
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
		
		print("Loading Object ", new_object.name, ", InstanceID: ", new_object.get_instance_id())
		
		# Now we set the remaining variables.
		for i in node_data.keys():
			if i == "child_index":
				new_object.get_parent().move_child(new_object, node_data["child_index"])
			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
				continue
			new_object.set(i, node_data[i])
			if i == "inventory":
				new_object.set(i, convert_keys_to_int(node_data[i]))
			if i == "areaData":
				new_object.set(i, load(node_data[i]))
			if i == "layer_saves":
				new_object.layer_saves = node_data[i]
				new_object.set_layer()
			if i == "itemData" and new_object is DroppedItem:
				new_object.set_itemData(load(node_data[i]))
			if i == "unlocked_buildings":
				new_object.unlocked_buildings = new_object.array_to_arrayint(node_data[i]) 
			if i == "unlocked_recipes":
				new_object.unlocked_recipes = new_object.array_to_arrayint(node_data[i]) 
				
				
		if new_object.is_in_group("Player"):
			Game.set_player(new_object)
			EventBus.link_camera.emit(new_object.rt2d)
			EventBus.set_camera_limit.emit(new_object.areaData.limit_ltrb)
			EventBus.position_camera.emit(new_object.global_position)
		
		if new_object is Building && !new_object.preplaced:
			level_root.building_handler.building_list.append(new_object)
			new_object.setup_data(null) #building data already set
			new_object.load_trigger()

func convert_keys_to_int(dict: Dictionary) -> Dictionary:
	var new_dict := {}

	for key in dict.keys():
		new_dict[int(key)] = dict[key]

	return new_dict

func link_camera(target: RemoteTransform2D) -> void:
	target.remote_path = camera.get_path()

func set_camera_limit(limit_ltrb: Vector4i) -> void:
	print("Camera Limit: ", limit_ltrb)
	camera.limit_left = limit_ltrb.x
	camera.limit_top = limit_ltrb.y
	camera.limit_right = limit_ltrb.z
	camera.limit_bottom = limit_ltrb.w

func position_camera(pos: Vector2) -> void:
	camera.global_position = pos

func fade_out(enter: bool) -> void:
	if enter:
		var tween = create_tween()
		tween.tween_property(ui_manager.color_rect, "modulate:a", 1.0, 0.5) # Fades over 0.5 seconds
		await tween.finished
		EventBus.fade_out_finished.emit()
	else:
		var tween = create_tween()
		tween.tween_property(ui_manager.color_rect, "modulate:a", 0.0, 0.5) # Fades over 0.5 seconds
		await tween.finished
		EventBus.fade_out_finished.emit()
