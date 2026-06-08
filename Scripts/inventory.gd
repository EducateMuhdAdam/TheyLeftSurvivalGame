extends CanvasLayer

@onready var inventory_grid: GridContainer = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/GridContainer
@export var grid_scene = preload("res://Scenes/inventory_slot.tscn")

const INVENTORY_NUM: int = 30

func _ready() -> void:
	setup_inventory_grid()
	visible = false

#TODO: Change Each Canvas Layer to Control and make Root Canvas Layer node
#TODO: Add items to the game

#To be changed later when root CanvasLayer is implemented	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		toggle_inventory()

func setup_inventory_grid() -> void:
	for i in range(0, INVENTORY_NUM):
		var newGrid = grid_scene.instantiate()
		newGrid.slotID = i
		inventory_grid.add_child(newGrid)

func toggle_inventory() -> void:
	visible = !visible
