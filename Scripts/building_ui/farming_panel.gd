extends PanelContainer

@export var plant: Slot

var building = null

func _ready() -> void:
	plant.controller = building
	plant.requirement = Callable(self, "check_seed")
	plant.building_action =  Callable(self, "building_action")

func check_seed(data: Variant) -> bool:
	print("seed:", data)
	if data && (!data.item || data.item.itemID == 7):
		return true
	return false
	
func building_action() -> void:
	building.building_action(self)
	

func close_panel() -> void:
	queue_free()
