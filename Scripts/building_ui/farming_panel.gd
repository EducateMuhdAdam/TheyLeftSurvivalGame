extends BuildingPanel

@export var plant: Slot
@onready var label: Label = $VBoxContainer/Label

func _ready() -> void:
	plant.controller = building
	plant.requirement = Callable(self, "check_seed")
	plant.building_action =  Callable(self, "building_action")
	label.text = panel_name
	
func check_seed(data: Variant) -> bool:
	if data && (!data.item || data.item.itemID == 7):
		return true
	return false
	
func building_action() -> void:
	building.building_action(self)
	

func close_panel() -> void:
	queue_free()
