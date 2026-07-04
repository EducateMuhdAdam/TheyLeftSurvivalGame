extends StaticBody2D
class_name Building

# All your stats are now neatly contained inside this single variable
@export var data: BuildingData

var building_space: BuildingSpace

var building_data: BuildingData = null
func _ready() -> void:
	y_sort_enabled = true

var interact: Callable = func():
	pass

func activate_interaction(active: bool) -> void:
	print("Interaction not set up for ", self.name)
