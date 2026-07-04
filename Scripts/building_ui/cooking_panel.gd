extends BuildingPanel

@onready var fuel: Slot = $VBoxContainer/TextureRect/Fuel
@onready var food: Slot = $VBoxContainer/TextureRect/Food
@onready var label: Label = $VBoxContainer/Label

func _ready() -> void:
	fuel.controller = building
	food.controller = building
	
	fuel.requirement = Callable(self, "check_fuel")
	food.requirement = Callable(self, "check_food")
	fuel.building_action =  Callable(self, "building_action")
	food.building_action =  Callable(self, "building_action")
	label.text = panel_name

func check_fuel(data: Variant) -> bool:
	if data && (!data.item || "Fuel" in data.item.tags):
		return true
	return false

func check_food(data: Variant) -> bool:
	if data && (!data.item || "Uncooked" in data.item.tags):
		return true
	return false

func building_action() -> void:
	building.building_action(self)

func close_panel() -> void:
	queue_free()
