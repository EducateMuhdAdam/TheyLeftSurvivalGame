@tool
extends EditorScript


func _run():

	create_json(
		"res://Data/items/",
		"res://Data/items.json",
		"itemID"
	)

	create_json(
		"res://Data/recipes/",
		"res://Data/recipes.json",
		"craftingID"
	)

	create_json(
		"res://Data/warpgates/",
		"res://Data/warpgates.json",
		"warpID"
	)

	create_json(
		"res://Data/messages/",
		"res://Data/messages.json",
		"messageID"
	)

	create_json(
		"res://Data/buildings/",
		"res://Data/buildings.json",
		"building_id"
	)

	print("Finished creating all JSON catalogues.")



func create_json(folder_path:String, output_path:String, id_property:String):

	var catalogue := {}

	var dir = DirAccess.open(folder_path)

	if dir == null:
		push_error("Cannot open folder: " + folder_path)
		return


	dir.list_dir_begin()

	var file_name = dir.get_next()


	while file_name != "":

		if !dir.current_is_dir() and file_name.ends_with(".tres"):

			var resource_path = folder_path + file_name
			var resource = load(resource_path)


			if resource:

				var id = resource.get(id_property)

				if id != null:

					catalogue[str(id)] = {
						"path": resource_path
					}

					print(
						"Added ",
						id,
						": ",
						resource_path
					)


		file_name = dir.get_next()


	dir.list_dir_end()


	var file = FileAccess.open(
		output_path,
		FileAccess.WRITE
	)


	file.store_string(
		JSON.stringify(catalogue, "\t")
	)


	print("Created: ", output_path)
