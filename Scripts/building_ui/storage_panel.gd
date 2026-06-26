extends BuildingPanel

@export var grid_scene = preload("res://Scenes/inventory_slot.tscn")
@onready var label: Label = $MarginContainer/VBoxContainer/Label
@onready var storage_grid: GridContainer = $MarginContainer/VBoxContainer/StorageGrid

var slots: Dictionary = {}

func _ready() -> void:
	setup_inventory_grid()
	label.text = building.building_data.building_name
	update_storage()

func setup_inventory_grid() -> void:
	for i in range(0, building.NumberOfSlots):
		var newGrid = grid_scene.instantiate()
		newGrid.slotID = i
		newGrid.controller = building
		newGrid.building_action =  func():
			building.building_action(newGrid)
		slots[i] = newGrid
		storage_grid.add_child(newGrid)

func update_storage() -> void:
	for slotID in building.inventory.keys():
		var itemID = building.inventory[slotID]["id"]
		slots[slotID].update_slot(Catalogue.item_catalogue[itemID], building.inventory[slotID]["qty"])
