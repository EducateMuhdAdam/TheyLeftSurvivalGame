extends Control

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var inventory_grid: GridContainer = $PanelContainer/MarginContainer/VBoxContainer/GridContainer
@onready var panel_container: PanelContainer = $PanelContainer

@export var grid_scene = preload("res://Scenes/inventory_slot.tscn")
@export var ui_container: HBoxContainer


var slots: Dictionary = {}
var item_library: Dictionary = {}

func _ready() -> void:
	EventBus.toggle_inventory.connect(toggle_inventory)
	
	item_library = Catalogue.item_catalogue
	player.update_inventory.connect(update_inventory)
	setup_inventory_grid()
	update_inventory(player.inventory)
	visible = false
	

func get_panel() -> PanelContainer:
	return $PanelContainer

func setup_inventory_grid() -> void:
	for i in range(0, player.INVENTORY_NUM):
		var newGrid = grid_scene.instantiate()
		newGrid.slotID = i
		newGrid.controller = player
		slots[i] = newGrid
		inventory_grid.add_child(newGrid)

func update_inventory(updated_inventory: Dictionary) -> void:
	for i in updated_inventory.keys():
		var itemID = updated_inventory[i]["id"]
		var itemQty = updated_inventory[i]["qty"]
		slots[i].set_item(item_library[itemID])
		slots[i].set_quantity(itemQty)

func toggle_inventory(inventory_on: bool) -> void:
	visible = inventory_on

func toggle_shared_mode(shared_mode: bool) -> void:
	if shared_mode:
		change_column_num(5)
	else:
		change_column_num(10)

func change_column_num(num: int) -> void:
	inventory_grid.columns = num
