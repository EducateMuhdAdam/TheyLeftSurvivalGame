extends PanelContainer

var building = null

@onready var fuel: Slot = $VBoxContainer/TextureRect/Fuel
@onready var food: Slot = $VBoxContainer/TextureRect/Food

func _ready() -> void:
	fuel.controller = building
	food.controller = building
	
	fuel.requirement = Callable(self, "check_fuel")
	food.requirement = Callable(self, "check_food")
	fuel.building_action =  Callable(self, "building_action")
	food.building_action =  Callable(self, "building_action")

func check_fuel(data: Variant) -> bool:
	if data && (!data.item || data.item.itemID == 6):
		return true
	return false

func check_food(data: Variant) -> bool:
	if data && (!data.item || data.item.itemID == 2):
		return true
	return false

func building_action() -> void:
	building.building_action(self)

func close_panel() -> void:
	queue_free()
