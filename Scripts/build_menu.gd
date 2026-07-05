extends Control

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var building_button_container: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/BuildingButtonContainer
@onready var panel_container: PanelContainer = $PanelContainer
@onready var cost_container: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/CostContainer
@onready var confirm: Button = $PanelContainer/MarginContainer/VBoxContainer/ActionButtonContainer/Confirm
@onready var warning: Label = $PanelContainer/MarginContainer/VBoxContainer/Warning

var highlighted: BuildingData = null
var slot_scene: Resource = preload("res://Scenes/inventory_slot.tscn")
var BUTTON_TEMPLATE = preload("res://Scenes/build_button.tscn")
const PATH: String = "res://Data/buildings/"
var building_resources: Array[Resource]

func _ready() -> void:
	confirm.pressed.connect(confirm_pressed)
	EventBus.toggle_build_mode.connect(toggle_build_menu)
	var building_menu_group = ButtonGroup.new()
	building_resources = get_building_resources()
	for resource in building_resources:
		var button: Button = BUTTON_TEMPLATE.instantiate()
		button.set_building(resource)
		button.button_group = building_menu_group
		button.pressed.connect(highlight_building.bind(resource))
		
		building_button_container.add_child(button)

func highlight_building(buildingData: BuildingData) -> void:
	highlighted = buildingData
	for child in cost_container.get_children():
		child.queue_free()
	for itemID in buildingData.requirement.keys():
			var newSlot: Slot = slot_scene.instantiate()
			newSlot.can_interact = false
			newSlot.mouse_filter = Control.MOUSE_FILTER_IGNORE
			cost_container.add_child(newSlot)
			newSlot.update_slot(Catalogue.item_catalogue[itemID], buildingData.requirement[itemID])
	if buildingData.requirement.keys().size() == 0:
		var newSlot: Slot = slot_scene.instantiate()
		newSlot.can_interact = false
		newSlot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cost_container.add_child(newSlot)

func get_building_resources() -> Array[Resource]:
	var resources: Array[Resource] = []
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
					resources.append(scene_resource)
					print("Successfully loaded: ", scene_path)
			file_name = dir.get_next()
			
		dir.list_dir_end()
	else:
		print("An error occurred when trying to access the path.")
		
	return resources

func toggle_build_menu(build_on: bool) -> void:
	if build_on:
		self.show()
	else:
		self.hide()

func confirm_pressed() -> void:
	if !highlighted:
		return
	var found_slots: Array[int]
	for itemID in highlighted.requirement.keys():
		var slot = player.find_item_quantity(itemID, highlighted.requirement[itemID])
		if slot:
			found_slots.append(slot)
	if found_slots.size() == highlighted.requirement.size():
		EventBus.toggle_placement_mode.emit(true)
		EventBus.toggle_build_mode.emit(false)
		warning.hide()
	else:
		warning.show()
	
