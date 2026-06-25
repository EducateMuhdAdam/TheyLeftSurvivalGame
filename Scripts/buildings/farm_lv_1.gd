extends Building

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var growtime: Timer = $Growtime

var plant: Dictionary = {"data": null, "qty": 0}
var panel: Node = null

const TIMETOGROW: int = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")
	growtime.timeout.connect(_on_timer_timeout)
	growtime.one_shot = true

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

func building_action(panel: PanelContainer) -> void:
	plant = {"data": panel.plant.item, "qty": panel.plant.quantity}
	if panel.plant.item && panel.check_seed(panel.plant):
		growtime.start(TIMETOGROW)
	else:
		growtime.stop()

func _on_timer_timeout() -> void:
	if !plant["data"]:
		return
	plant["data"] = Catalogue.plant_reference[plant["data"].itemID]
	if panel:
		panel.plant.update_slot(plant["data"], 1)
