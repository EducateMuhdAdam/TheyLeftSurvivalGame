extends Control

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var inventory_grid: GridContainer = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/GridContainer
@export var grid_scene = preload("res://Scenes/inventory_slot.tscn")

var slots: Dictionary = {}
var item_library: Dictionary = {}

const PATH: String = "res://Data/items/"
const INVENTORY_NUM: int = 30

func _ready() -> void:
	item_library = get_item_resources()
	player.update_inventory.connect(update_inventory)
	setup_inventory_grid()
	update_inventory(player.inventory)
	visible = false

#TODO: Create Default Error File For Item Not Found
#TODO: Have the item be able to move around in the inventory

#To be changed later when root CanvasLayer is implemented	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		toggle_inventory()

func setup_inventory_grid() -> void:
	for i in range(0, INVENTORY_NUM):
		var newGrid = grid_scene.instantiate()
		newGrid.slotID = i
		slots[i] = newGrid
		inventory_grid.add_child(newGrid)
		newGrid.swap_item.connect(player.swap_inventory)

func update_inventory(updated_inventory: Dictionary) -> void:
	for i in player.inventory:
		var itemID = updated_inventory[i]["id"]
		var itemQty = updated_inventory[i]["qty"]
		slots[i].set_item(item_library[itemID])
		slots[i].set_quantity(itemQty)

func toggle_inventory() -> void:
	visible = !visible

func get_item_resources() -> Dictionary:
	var resources: Dictionary = {}
	var dir = DirAccess.open(PATH)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			# Ignore directories and only grab scene files
			if !dir.current_is_dir() and file_name.ends_with(".tres"):
				var scene_path = PATH + "/" + file_name
				var scene_resource = load(scene_path)
					
				if scene_resource:
					var key = scene_resource.itemID
					resources[key] = scene_resource
					print("Successfully loaded: ", scene_path)
			file_name = dir.get_next()
			
		dir.list_dir_end()
	else:
		print("An error occurred when trying to access the path.")
		
	return resources
