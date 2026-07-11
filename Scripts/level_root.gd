extends Node2D
class_name LevelRoot

func _ready():
	Main.level_root = self

@export var building_handler: Node2D = get_node_or_null("BuildingHandler")
@export var item_handler: Node2D = get_node_or_null("ItemHandler")
