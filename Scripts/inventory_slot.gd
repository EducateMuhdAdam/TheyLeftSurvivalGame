extends PanelContainer
class_name Slot

signal slot_updated(slot: PanelContainer)

@onready var icon: TextureRect = $Icon
@onready var quantity_label: Label = $MarginContainer/QuantityLabel
@onready var notation_label: Label = $MarginContainer2/NotationLabel


@export var one_item: bool = false

var notation: String = ""
var can_interact: bool = true
var controller: Node
var slotID: int = -1
var item: ItemData = null
var quantity: int = 0

var requirement:Callable = func(data: Variant) -> bool:
	return true

var building_action: Callable = func() -> void:
	pass

func _ready() -> void:
	notation_label.text = notation

func update_slot(newItem: Resource, qty: int) -> void:
	set_item(newItem)
	set_quantity(qty)

func update_player() -> void:
	if item:
		controller.set_inventory_slot(slotID, item.itemID, quantity)
	else:
		controller.remove_inventory(slotID)

#Used to set Item while pinging player/etc
func set_item(newItem: Resource) -> void:
	if newItem:
		item = newItem
		icon.texture = newItem.image
	else:
		empty_slot()
	if controller.is_in_group("Player"):
		update_player()
	slot_updated.emit(self)

#Used to set Quantity while pinging player/etc
func set_quantity(qty: int) -> void:
	quantity = qty
	if qty == 0:
		set_item(null)
	if qty == 1 or qty == 0:
		quantity_label.text = ""
	else:
		quantity_label.text = str(qty)
	if controller.is_in_group("Player"):
		update_player()
	slot_updated.emit(self)


func _get_drag_data(at_position: Vector2) -> Variant:
	if not item or not can_interact:
		return null
	
	var preview = TextureRect.new()
	preview.texture = icon.texture # Copy your current slot's item icon
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.custom_minimum_size = Vector2(64, 64)
	preview.position += -preview.custom_minimum_size / 2
	
	set_drag_preview(preview)
	
	return self 

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is Slot and data != self and requirement.call(data)
	
func _drop_data(at_position: Vector2, origin_slot: Variant) -> void:
	if one_item:
		one_item_seq(origin_slot)
	else:
		swap_item_seq(origin_slot)
	

func swap_item_seq(origin_slot: Variant) -> void:
	var temp_slot = clone()
	if origin_slot.item == item and not one_item:
		set_quantity(origin_slot.quantity + quantity)
		origin_slot.set_quantity(0)
	elif origin_slot.one_item and item and origin_slot.requirement.call(self):
		origin_slot.one_item_seq(self)
	elif origin_slot.requirement.call(self):
		update_slot(origin_slot.item, origin_slot.quantity)
		origin_slot.update_slot(temp_slot.item, temp_slot.quantity)
	else:
		print("Requirement Not Met")
		return
	
	if controller is Building:
		EventBus.erase_item.emit(origin_slot.slotID)
		building_action.call()
	if origin_slot.controller is Building:
		origin_slot.building_action.call()

func one_item_seq(origin_slot: Variant) -> void:
	if item:
		EventBus.add_item.emit(item)
	
	set_item(origin_slot.item)
	origin_slot.set_quantity(origin_slot.quantity - 1)
	set_quantity(1)
	
	if controller is Building:
		building_action.call()
	if origin_slot.controller is Building:
		origin_slot.building_action.call()

func empty_slot() -> void:
	icon.texture = null
	quantity_label.text = ""
	quantity = 0
	item = null
	
func clone() -> PanelContainer:
	var new_slot = duplicate()
	new_slot.item = item
	new_slot.quantity = quantity
	return new_slot
