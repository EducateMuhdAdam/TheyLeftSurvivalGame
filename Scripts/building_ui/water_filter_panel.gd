extends PanelContainer

@export var output: Slot
@export var input: Slot

var building = null

func _ready() -> void:
	input.requirement = Callable(self, "check_dirty_water")
	output.requirement = Callable(self, "check_empty_water")
	input.building_action =  Callable(self, "building_action")
	output.building_action =  Callable(self, "building_action")

func check_dirty_water(data: Variant) -> bool:
	if data && (!data.item || data.item.itemID == 4):
		return true
	return false

func check_empty_water(data: Variant) -> bool:
	if data && (!data.item || data.item.itemID == 1):
		return true
	return false
	
func building_action() -> void:
	building.building_action(self)
