extends HBoxContainer


var shared_node: Node
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	EventBus.toggle_inventory.connect(toggle_inventory)
	


func toggle_inventory(inventory_on: bool) -> void:
	visible = inventory_on
