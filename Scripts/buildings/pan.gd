extends Storage

@onready var timer: Timer = $Timer
const percent_chance: float = 10

var i: int = 0
var item_pool: Dictionary[int, float] = {
	30: 30.0,
	14: 80.0,
	29: 20.0,
	34: 60.0
}

func _on_timer_timeout() -> void:
	#Check if item get
	if randf() < percent_chance/ 100:
		var full_weight: float
		for key in item_pool.keys():
			full_weight += item_pool[key]
		var random_weight = randf_range(0, full_weight)
		var selected_index: int
		for key in item_pool.keys():
			random_weight -= item_pool[key]
			selected_index = key
			if random_weight <= 0:
				break
		if i == 5:
			var player: Player = await Game.get_player()
			if not 5 in player.unlocked_buildings:
				add_inventory(Catalogue.item_catalogue[106], 1)
		add_inventory(Catalogue.item_catalogue[selected_index], 1)
		i += 1
		if panel:
			panel.update_storage()

func save() -> Dictionary:
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"data_path" : data_path,
		"inventory" : inventory,
		"NumberOfSlots" : NumberOfSlots,
		"i" : i
	}
	return save_dict
