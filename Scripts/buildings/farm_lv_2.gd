extends Building

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var growtime: Timer = $Growtime
@onready var item: Sprite2D = $Sprite2D/Item

var plant: Dictionary = {"data": null, "qty": 0}
var panel: Node = null

const TIMETOGROW: int = 120

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")
	growtime.timeout.connect(_on_timer_timeout)
	growtime.one_shot = true

func activate_interaction(active: bool) -> void:
	interaction_area.active = active

func _on_interact():
	panel = load(self.data.ui_scene_path).instantiate()
	panel.building = self
	EventBus.shared_ui.emit(panel, self)
	setup_panel()

func setup_panel() -> void:
	if !panel:
		return
	if plant["data"]:
		panel.plant.update_slot(plant["data"], plant["qty"])

func set_item(new_item: Variant) -> void:
	if new_item is ItemData:
		item.texture = new_item.image
	else:
		item.texture = null
	fit_to_size(item, Vector2(16, 16))

func building_action(panel: PanelContainer) -> void:
	plant = {"data": panel.plant.item, "qty": panel.plant.quantity}
	if panel.plant.item && panel.check_seed(panel.plant):
		set_item(panel.plant.item)
		growtime.start(TIMETOGROW)
	else:
		set_item(null)
		growtime.stop()

func fit_to_size(sprite: Sprite2D, max_size: Vector2) -> void:
	if sprite.texture == null:
		return
	var tex_size = sprite.texture.get_size()
	var scale_factor = min(max_size.x / tex_size.x,max_size.y / tex_size.y)
	scale_factor = min(scale_factor, 1.0)
	sprite.scale = Vector2.ONE * scale_factor

func _on_timer_timeout() -> void:
	if !plant["data"]:
		return
	plant["data"] = Catalogue.plant_reference[plant["data"].itemID]
	set_item(plant["data"])
	if panel:
		panel.plant.update_slot(plant["data"], 1)
