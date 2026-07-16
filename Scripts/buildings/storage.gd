extends Building
class_name Storage

@export var NumberOfSlots: int
@export var preplaced_inv: Dictionary[int, int]
var inventory: Dictionary

var storage_panel = load("res://Scenes/building_ui/storage_panel.tscn")
var panel
func _ready() -> void:
	if preplaced and !inventory:
		for key in preplaced_inv.keys():
			add_inventory(Catalogue.item_catalogue[key], preplaced_inv[key])
	else:
		inventory = {}
	add_to_group("Buildings")
	add_to_group("Persist")
	for child in get_children():
		if child is InteractionArea:
			child.interact = Callable(self, "open_panel")

func open_panel() -> void:
	panel = storage_panel.instantiate()
	panel.building = self
	EventBus.shared_ui.emit(panel, self)

func set_inventory_slot(slotID: int, itemID: int, qty: int):
	if !itemID || qty == 0:
		inventory.erase(slotID)
		return
	if !inventory.has(slotID):
		inventory[slotID] = {"id": itemID, "qty": qty}
		return
	inventory[slotID]["qty"] = qty
	inventory[slotID]["id"] = itemID

func remove_inventory(slotID: int) -> void:
	inventory.erase(slotID)

func add_inventory(itemData: ItemData, qty: int) -> void:
	#Check Duplicate
	for key in inventory.keys():
		if inventory[key]["id"] == itemData.itemID:
			inventory[key]["qty"] += 1
			return
	for key in range(0, NumberOfSlots):
		if not (key in inventory.keys()):
			inventory[key] = {"id": itemData.itemID, "qty": qty}
			return
	print("Storage Inventory Full!")

func building_action(slot: Variant) -> void:
	if slot.item:
		set_inventory_slot(slot.slotID, slot.item.itemID, slot.quantity)
	else:
		remove_inventory(slot.slotID)

func destroy_building() -> void:
	for key in inventory.keys():
		EventBus.add_multiple_item.emit(Catalogue.item_catalogue[inventory[key]["id"]], inventory[key]["qty"])
	queue_free()

func save() -> Dictionary:
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"data_path" : data_path,
		"inventory" : inventory,
		"NumberOfSlots" : NumberOfSlots
	}
	return save_dict
