extends Building

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var growtime: Timer = $Growtime
@onready var item: Sprite2D = $Sprite2D/Item

var plant: Dictionary = {"data": null, "qty": 0}
var progress: int
var panel: Node = null

const TIMETOGROW: int = 300

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")
	growtime.timeout.connect(_on_timer_timeout)
	if progress:
		growtime.start(1)

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
		progress = TIMETOGROW
		growtime.start()
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
	progress -= 1
	if progress > 0 || !plant["data"]:
		return
	plant["data"] = Catalogue.plant_reference[plant["data"].itemID]
	set_item(plant["data"])
	if panel:
		panel.plant.update_slot(plant["data"], 1)

func save() -> Dictionary:
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"data_path" : data_path,
		"plant": {"data": unpack_itemID(plant), "qty": plant["qty"]},
		"progress": progress
	}
	return save_dict

func load_trigger() -> void:
	plant = itemID_to_data_in_dict(plant)
	if progress:
		growtime.start()
		set_item(plant["data"])

func destroy_building() -> void:
	if plant["data"]:
		EventBus.add_multiple_item.emit(plant["data"], plant["qty"])
	queue_free()
