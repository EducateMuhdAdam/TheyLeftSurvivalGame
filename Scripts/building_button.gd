extends Button

var building_reference: BuildingData

func set_building(buildingData: BuildingData) -> void:
	building_reference = buildingData
	setup_button()

func setup_button() -> void:
	icon = building_reference.image
	var msg = "%s" % building_reference.building_name
	if building_reference.building_level != 0:
		msg = msg + " Lv%d" % building_reference.building_level
	text = msg
	



func _on_pressed() -> void:
	pass # Replace with function body.
