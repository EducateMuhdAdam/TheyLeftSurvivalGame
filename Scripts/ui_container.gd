extends HBoxContainer

@export var inventory: Control
var shared_node: Node
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	EventBus.toggle_inventory.connect(toggle_inventory)
	

func toggle_inventory(inventory_on: bool) -> void:
	if not inventory_on:
		inventory.toggle_shared_mode(false)
		var inv_panel = inventory.panel_container
		for children in get_children():
			if children != inv_panel:
				handle_close_panel(children)
	visible = inventory_on
	
func handle_close_panel(node: Node) -> void:
	if node.has_method("close_panel"):
		node.close_panel()
	else:
		print("Close Panel Not Found For ", node)
		node.queue_free()
