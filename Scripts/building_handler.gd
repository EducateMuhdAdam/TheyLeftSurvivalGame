extends Node2D

@export var ObjectContainer: Node2D 
@onready var guides: Node2D = $Guides


var reference: BuildingData = preload("res://Data/buildings/farm_lv1.tres") #Default
var guide: Sprite2D = Sprite2D.new()
var is_build_mode: bool = true
var anchor: Vector2 = Vector2(0,0)
var building_list: Array[Building] = []
const tilesize: int = 32

func _ready() -> void:
	EventBus.change_building.connect(set_reference)
	EventBus.toggle_build_mode.connect(toggle_build_mode)
	setup_guide(reference)
	
	guide.scale = Vector2(2, 2)
	guides.add_child(guide)
	

func _process(delta: float) -> void:
	if is_build_mode:
		guide.global_position = (get_global_mouse_position() / tilesize).snapped(Vector2.ONE) * tilesize

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and is_build_mode:
		if event.button_index == MOUSE_BUTTON_LEFT:
			create_building(reference)

func set_reference(building: BuildingData) -> void:
	reference = building
	setup_guide(building)

func setup_guide(building: BuildingData) -> void:
	guide.texture = building.image
	
func create_building(building_data: BuildingData) -> void:
	var new = load(building_data.build_scene_path).instantiate()
	ObjectContainer.add_child(new)
	new.global_position = guide.global_position
	new.building_data = building_data
	building_list.append(new)

func toggle_build_mode(build_on: bool) -> void:
	if build_on:
		guide.show()
		is_build_mode = true
	else:
		guide.hide()
		is_build_mode = false
