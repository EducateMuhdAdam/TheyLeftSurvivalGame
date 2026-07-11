extends Building

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var cooktime: Timer = $Cooktime
@onready var sprite: Sprite2D = $Sprite2D

var cp_off = preload("res://Assets/Images/Buildings/CookplaceLv1.png")
var cp_on = preload("res://Assets/Images/Buildings/CookplaceLv1_on.png")

var food: Dictionary = {"data": null, "qty": 0}
var fuel: Dictionary = {"data": null, "qty": 0}
var panel: Node = null
var progress: int

const TIMETOCOOK: int = 30

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")
	cooktime.timeout.connect(_on_timer_timeout)
	cooktime.one_shot = false
	if progress:
		cooktime.start(1)

func _on_interact():
	panel = load(self.data.ui_scene_path).instantiate()
	panel.building = self
	EventBus.shared_ui.emit(panel, self)
	setup_panel()

func setup_panel() -> void:
	if !panel:
		return
	if food["data"]:
		panel.food.update_slot(load(food["data"]), 1)
	if fuel["data"]:
		panel.fuel.update_slot(load(fuel["data"]), fuel["qty"])
	panel.building_texture.texture = sprite.texture
	

func building_action(panel: BuildingPanel) -> void:
	food = {"data": panel.food.get_item_path(), "qty": panel.food.quantity}
	fuel = {"data": panel.fuel.get_item_path(), "qty": panel.fuel.quantity}
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
		panel.food.update_slot(load(food["data"]), 1)

func save() -> Dictionary:
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"food" : food,
		"fuel" : fuel,
		"progress": progress
	}
	return save_dict
