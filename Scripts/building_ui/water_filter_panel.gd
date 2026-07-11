extends BuildingPanel

@export var output: Slot
@export var input: Slot
@onready var label: Label = $VBoxContainer/Label
@onready var texture_rect: TextureRect = $VBoxContainer/TextureRect

func _ready() -> void:
	building_texture = texture_rect
	output.controller = building
	input.controller = building
	input.requirement = Callable(self, "check_dirty_water")
	output.requirement = Callable(self, "check_empty_water")
	input.building_action =  Callable(self, "building_action")
	output.building_action =  Callable(self, "building_action")
	label.text = panel_name

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
	

func close_panel() -> void:
	queue_free()
