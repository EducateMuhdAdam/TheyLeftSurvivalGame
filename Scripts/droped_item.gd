extends StaticBody2D
class_name DroppedItem

@onready var image: Sprite2D = $Image
@onready var interaction_area: InteractionArea = $InteractionArea

@export var itemData: ItemData
@export var quantity: int = 1
@export var persisting: bool = true
var interact: Callable = func():
	pass

const MAX_SIZE: int = 32

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if persisting:
		add_to_group("Persist")
	print(itemData)
	if itemData:
		set_itemData(itemData)
	interaction_area.interact = self.item_picked_up
	interaction_area.show_interaction = false
	interaction_area.on_indicator = self.highlight_object
	interaction_area.off_indicator = self.remove_highlight

func set_itemData(data: ItemData) -> void:
	itemData = data
	image.texture = itemData.image
	set_image_scale()

func highlight_object():
	# Turns the object bright yellow
	image.modulate = Color(1, 1, 0, 1) 

func remove_highlight():
	# Resets to normal
	image.modulate = Color(1, 1, 1, 1) 

func set_image_scale() -> void:
	var max_image_size = max(image.texture.get_size().x, image.texture.get_size().y)
	var new_scale = MAX_SIZE / max_image_size
	image.scale = Vector2(new_scale, new_scale)

func item_picked_up() -> void:
	EventBus.add_multiple_item.emit(itemData, quantity)
	queue_free()

func save() -> Dictionary:
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"itemData": itemData.resource_path,
		"quantity": quantity
		}
	return save_dict
