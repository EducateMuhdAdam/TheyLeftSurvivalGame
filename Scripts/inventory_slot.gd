extends PanelContainer
class_name Slot

signal swap_item(id1: int, id2: int)

@onready var icon: TextureRect = $Icon
@onready var label: Label = $MarginContainer/Label

var slotID: int = -1
var item: ItemData = null
var quantity: int = 0

func set_item(newItem: Resource) -> void:
	item = newItem
	icon.texture = newItem.image
	
func set_quantity(qty: int) -> void:
	if qty == 1 or qty == 0:
		label.text = ""
	else:
		label.text = str(qty)
		
func _get_drag_data(at_position: Vector2) -> Variant:
	if not item:
		return null
	
	var preview = TextureRect.new()
	preview.texture = icon.texture # Copy your current slot's item icon
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.custom_minimum_size = Vector2(64, 64)
	preview.position += -preview.custom_minimum_size / 2
	
	set_drag_preview(preview)
	
	return self 

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is Slot and data != self
	
func _drop_data(at_position: Vector2, data: Variant) -> void:
	var origin_slot = data
	origin_slot.empty_slot()
	self.empty_slot()
	swap_item.emit(origin_slot.slotID, self.slotID)
	
func empty_slot() -> void:
	icon.texture = null
	set_quantity(0)
	item = null
	
	
