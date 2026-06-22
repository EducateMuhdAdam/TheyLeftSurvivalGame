extends HBoxContainer

@export var inventory: Control
var shared_node: Node
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	EventBus.toggle_inventory.connect(toggle_inventory)
	

func toggle_inventory(inventory_on: bool) -> void:
	if not inventory_on:
		inventory.change_column_num(10)
		#for children in get_children():
		#	if children != inventory.get_panel():
		#		children.queue_free()
	visible = inventory_on
