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
	setup_inventory_grid()
	update_inventory()
	visible = false

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

func update_inventory() -> void:
	for i in player.inventory:
		var itemID = player.inventory[i]["id"]
		var itemQty = player.inventory[i]["qty"]
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
