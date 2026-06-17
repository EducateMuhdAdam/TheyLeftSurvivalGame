extends Node2D

@export var ObjectContainer: Node2D 
var itemList: Array[DroppedItem] = []
var itemTemplate: Resource = preload("res://Scenes/droped_item.tscn")


func create_item(data: ItemData, pos: Vector2) -> void:
	var newItem = itemTemplate.instantiate()
	newItem.set_itemData(data)
	itemList.append(itemList)
	newItem.global_position = pos
	ObjectContainer.add_child(newItem)
