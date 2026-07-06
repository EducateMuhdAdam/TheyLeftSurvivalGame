extends Building

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var cooktime: Timer = $Cooktime

var food: Dictionary = {"data": null, "qty": 0}
var fuel: Dictionary = {"data": null, "qty": 0}
var cooked: bool = false
var panel: Node = null

const TIMETOCOOK: int = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")
	cooktime.timeout.connect(_on_timer_timeout)
	cooktime.one_shot = true

func _on_interact():
	panel = load(self.data.ui_scene_path).instantiate()
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

func building_action(panel: PanelContainer) -> void:
	food = {"data": panel.food.item, "qty": panel.food.quantity}
	fuel = {"data": panel.fuel.item, "qty": panel.fuel.quantity}
	if panel.food.item and panel.fuel.item:
		panel.fuel.set_quantity(panel.fuel.quantity - 1)
		fuel["qty"] -= 1
		cooktime.start(TIMETOCOOK)
	else:
		cooktime.stop()

func _on_timer_timeout() -> void:
	food["data"] = Catalogue.cooking_reference[food["data"].itemID]
	if panel:
		panel.food.update_slot(food["data"], 1)
