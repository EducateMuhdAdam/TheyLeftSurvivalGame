extends StaticBody2D
class_name DroppedItem

@onready var image: Sprite2D = $Image
@onready var interaction_area: InteractionArea = $InteractionArea

var itemData: ItemData = null
var interact: Callable = func():
	pass

const MAX_SIZE: int = 64

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.on_indicator = self.highlight_object()
	interaction_area.off_indicator = self.remove_highlight()

func set_itemData(data: ItemData) -> void:
	itemData = data
	image.texture = itemData.image.texture
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
	image.scale = new_scale
