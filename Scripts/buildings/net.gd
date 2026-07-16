extends Storage

@onready var timer: Timer = $Timer
const percent_chance: float = 50

var item_pool: Dictionary[int, float] = {
	2: 20,
	9: 80
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

		add_inventory(Catalogue.item_catalogue[selected_index], 1)
		if panel:
			panel.update_storage()
