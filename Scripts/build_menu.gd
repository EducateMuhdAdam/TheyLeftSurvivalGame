extends Control

@onready var v_box_container: VBoxContainer = $MarginContainer/PanelContainer/ScrollContainer/VBoxContainer
@onready var panel_container: PanelContainer = $MarginContainer/PanelContainer

var BUTTON_TEMPLATE = preload("res://Scenes/build_button.tscn")
const PATH: String = "res://Data/buildings/"
var building_resources: Array[Resource]

func _ready() -> void:
	EventBus.toggle_build_mode.connect(toggle_build_menu)
	var building_menu_group = ButtonGroup.new()
	building_resources = get_building_resources()
	for resource in building_resources:
		var button = BUTTON_TEMPLATE.instantiate()
		button.set_building(resource)
		button.button_group = building_menu_group
		
		v_box_container.add_child(button)

func get_building_resources() -> Array[Resource]:
	var resources: Array[Resource] = []
	var dir = DirAccess.open(PATH)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			# Ignore directories and only grab scene files
			if !dir.current_is_dir() and file_name.ends_with(".tres"):
				var scene_path = PATH + "/" + file_name
				var scene_resource = load(scene_path)
					
				if scene_resource:
					resources.append(scene_resource)
					print("Successfully loaded: ", scene_path)
			file_name = dir.get_next()
			
		dir.list_dir_end()
	else:
		print("An error occurred when trying to access the path.")
		
	return resources

func toggle_build_menu(build_on: bool) -> void:
	if build_on:
		self.show()
	else:
		self.hide()
