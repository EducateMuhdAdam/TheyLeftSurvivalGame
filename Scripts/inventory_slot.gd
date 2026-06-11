extends PanelContainer

@onready var icon: TextureRect = $Icon
@onready var label: Label = $MarginContainer/Label

var slotID: int = -1
var item: ItemData = null
var quantity: int = 0

func set_item(newItem: Resource) -> void:
	item = newItem
	icon.texture = newItem.image
	
func set_quantity(qty: int) -> void:
	if qty == 1:
		label.text = ""
	else:
		label.text = str(qty)
