extends Control

@onready var water_filter_panel: PanelContainer = $WaterFilterPanel

func get_panel() -> PanelContainer:
	return $WaterFilterPanel
