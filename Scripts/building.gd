extends StaticBody2D
class_name Building

# All your stats are now neatly contained inside this single variable
@export var data: BuildingData

func _ready() -> void:
	y_sort_enabled = true

var interact: Callable = func():
	pass
