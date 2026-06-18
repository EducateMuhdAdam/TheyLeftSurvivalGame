extends Node2D

@export var ObjectContainer: Node2D 
var itemList: Array[DroppedItem] = []
var itemTemplate: Resource = preload("res://Scenes/droped_item.tscn")

func _ready() -> void:
	for child in ObjectContainer.get_children():
		if child is DroppedItem:
			itemList.append(child)

func create_item(data: ItemData, pos: Vector2) -> void:
	var newItem = itemTemplate.instantiate()
	newItem.set_itemData(data)
	itemList.append(itemList)
	newItem.global_position = pos
	ObjectContainer.add_child(newItem)
