extends Building

@onready var interaction_area: InteractionArea = $InteractionArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")
	


func _on_interact():
	var panel = load(self.data.ui_scene_path).instantiate()
	panel.building = self
	panel.output.controller = self
	panel.input.controller = self
	EventBus.shared_ui.emit(panel, self)

func building_action(panel: PanelContainer) -> void:
	if panel.input.item && panel.input.item.itemID == 4:
		panel.input.update_slot(Catalogue.item_catalogue[1], 1)
	
	if panel.output.item && panel.output.item.itemID == 1:
		panel.output.update_slot(Catalogue.item_catalogue[3], 1)
