extends Control

var player: Player
@onready var building_button_container: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/BuildingButtonContainer
@onready var panel_container: PanelContainer = $PanelContainer
@onready var cost_container: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/CostContainer
@onready var confirm: Button = $PanelContainer/MarginContainer/VBoxContainer/ActionButtonContainer/Confirm
@onready var warning: Label = $PanelContainer/MarginContainer/VBoxContainer/Warning

var highlighted: BuildingData = null
var slot_scene: Resource = preload("res://Scenes/inventory_slot.tscn")
var BUTTON_TEMPLATE = preload("res://Scenes/build_button.tscn")
var building_resources: Dictionary[int, BuildingData]

func _ready() -> void:
	player = await Game.get_player()
	warning.hide()
	self.hide()
	confirm.pressed.connect(confirm_pressed)
	EventBus.toggle_build_mode.connect(toggle_build_menu)
	recall_buildings()

func wipe_buildings() -> void:
	for child in building_button_container.get_children():
		child.queue_free()

func recall_buildings() -> void:
	wipe_buildings()
	var building_menu_group = ButtonGroup.new()
	for buildingID in player.unlocked_buildings:
		var buildingData: BuildingData = Catalogue.building_catalogue[buildingID]
		var button: Button = BUTTON_TEMPLATE.instantiate()
		button.set_building(buildingData)
		button.button_group = building_menu_group
		button.pressed.connect(highlight_building.bind(buildingData))
		
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


func toggle_build_menu(build_on: bool) -> void:
	if build_on:
		recall_buildings()
		self.show()
	else:
		self.hide()
		warning.hide()

func confirm_pressed() -> void:
	if !highlighted:
		return
	if player.find_item_from_dict(highlighted.requirement).size() == highlighted.requirement.size():
		EventBus.toggle_placement_mode.emit(true)
		EventBus.toggle_build_mode.emit(false)
		warning.hide()
	else:
		warning.show()
	
