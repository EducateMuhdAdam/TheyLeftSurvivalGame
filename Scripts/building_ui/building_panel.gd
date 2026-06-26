extends PanelContainer
class_name BuildingPanel

@export var panel_name: String

var building = null

func building_action() -> void:
	building.building_action(self)
	

func close_panel() -> void:
	queue_free()
