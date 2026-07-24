extends BuildingPanel

@export var slot_scene = preload("res://Scenes/inventory_slot.tscn")
@onready var requirement: HBoxContainer = $MarginContainer/VBoxContainer/Requirement
@onready var tribute: HBoxContainer = $MarginContainer/VBoxContainer/Tribute

var eventID = 0
var itemQuestData: ItemQuestData
var tribute_slots: Dictionary[int, Slot]
var requiremet_slots: Dictionary[int, Slot]

func _ready() -> void:
	setup_requiremnets()
	setup_tribite()

func setup_requiremnets() -> void:
	for i in range(0, itemQuestData.requirements.keys().size()):
		var newGrid: Slot = slot_scene.instantiate()
		newGrid.slotID = i
		newGrid.controller = building
		newGrid.building_action =  func():
			self.check_success()
		newGrid.can_interact = false
		var itemID = itemQuestData.requirements.keys()[i]
		var itemData = Catalogue.item_catalogue[itemID]
		requiremet_slots[i] = newGrid
		requirement.add_child(newGrid)
		newGrid.update_slot(itemData, itemQuestData.requirements[itemID])

func setup_tribite() -> void:
	for i in range(0, itemQuestData.requirements.keys().size()):
		var newGrid: Slot = slot_scene.instantiate()
		newGrid.slotID = i
		newGrid.controller = building
		newGrid.building_action =  func():
			self.check_quest()
		tribute_slots[i] = newGrid
		tribute.add_child(newGrid)

func check_slot(slot: Slot) -> bool:
	return slot.item != null && slot.item.itemID in itemQuestData.requirements.keys() && slot.quantity >= itemQuestData.requirements[slot.item.itemID]

func check_success() -> bool:
	var i = 0
	for slotID in tribute_slots.keys():
		var slot:Slot = tribute_slots[slotID]
		if !check_slot(slot):
			return false
		i += 1
	if i < itemQuestData.requirements.size():
		return false
	return true

func check_quest() -> void:
	if check_success():
		EventBus.execute_event.emit(eventID)
		for slotID: int in tribute_slots.keys():
			var slot: Slot = tribute_slots[slotID]
			var qty_consumed: int = itemQuestData.requirements[slot.item.itemID]
			slot.set_quantity(slot.quantity - qty_consumed)
		EventBus.toggle_inventory.emit(false)
		building.active = false
		queue_free()

func close_panel() -> void:
	for slotID: int in tribute_slots.keys():
		var slot: Slot = tribute_slots[slotID]
		if slot.item:
			EventBus.add_multiple_item.emit(slot.item, slot.quantity)
	queue_free()
