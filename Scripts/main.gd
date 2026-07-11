extends Node2D
@onready var ui_manager: CanvasLayer = $UIManager

var paused: bool = true

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
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
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
