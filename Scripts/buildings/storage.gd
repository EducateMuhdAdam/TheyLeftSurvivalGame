extends Building
class_name Storage

@export var NumberOfSlots: int
var inventory: Dictionary = {}

var storage_panel = load("res://Scenes/building_ui/storage_panel.tscn")

func _ready() -> void:
	for child in get_children():
		if child is InteractionArea:
			child.interact = Callable(self, "open_panel")

func open_panel() -> void:
	var panel = storage_panel.instantiate()
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

func building_action(slot: Variant) -> void:
	if slot.item:
		set_inventory_slot(slot.slotID, slot.item.itemID, slot.quantity)
	else:
		remove_inventory(slot.slotID)
