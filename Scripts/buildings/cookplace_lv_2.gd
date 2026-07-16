extends Building

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var cooktime: Timer = $Cooktime
@onready var sprite: Sprite2D = $Sprite2D

var cp_off = preload("res://Assets/Images/Buildings/CookplaceLv2.png")
var cp_on = preload("res://Assets/Images/Buildings/CookplaceLv2_on.png")

var food: Dictionary = {"data": null, "qty": 0}
var fuel: Dictionary = {"data": null, "qty": 0}
var panel: Node = null
var progress: int

const TIMETOCOOK: int = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")
	cooktime.timeout.connect(_on_timer_timeout)
	cooktime.one_shot = false

func _on_interact():
	panel = load(self.building_data.ui_scene_path).instantiate()
	panel.building = self
	EventBus.shared_ui.emit(panel, self)
	setup_panel()

func setup_panel() -> void:
	if !panel:
		return
	if food["data"]:
		panel.food.update_slot(food["data"], 1)
	if fuel["data"]:
		panel.fuel.update_slot(fuel["data"], fuel["qty"])
	panel.building_texture.texture = sprite.texture
	

func building_action(panel: BuildingPanel) -> void:
	food = {"data": panel.food.item, "qty": panel.food.quantity}
	fuel = {"data": panel.fuel.item, "qty": panel.fuel.quantity}
	if panel.food.item and panel.fuel.item:
		sprite.texture = cp_on
		panel.building_texture.texture = sprite.texture
		panel.fuel.set_quantity(panel.fuel.quantity - 1)
		fuel["qty"] -= 1
		progress = TIMETOCOOK
		cooktime.start(1)
	else:
		sprite.texture = cp_off
		panel.building_texture.texture = sprite.texture
		cooktime.stop()

func _on_timer_timeout() -> void:
	progress -= 1
	if progress > 0:
		return
	sprite.texture = cp_off
	food["data"] = Catalogue.cooking_reference[food["data"].itemID]
	if panel:
		panel.building_texture.texture = sprite.texture
		panel.food.update_slot(Catalogue.cooking_reference[food["data"].itemID], 1)
	cooktime.stop()

func save() -> Dictionary:
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"food" : {"data" : unpack_itemID(food), "qty" : food["qty"]},
		"fuel" : {"data" : unpack_itemID(fuel), "qty" : fuel["qty"]},
		"progress": progress,
		"data_path" : data_path
	}
	return save_dict

func destroy_building() -> void:
	if fuel["data"]:
		EventBus.add_multiple_item.emit(fuel["data"], fuel["qty"])
	if food["data"]:
		EventBus.add_multiple_item.emit(food["data"], food["qty"])
	queue_free()

func load_trigger() -> void:
	fuel = itemID_to_data_in_dict(fuel)
	food = itemID_to_data_in_dict(food)
	if progress:
		sprite.texture = cp_on
		cooktime.start(1)
