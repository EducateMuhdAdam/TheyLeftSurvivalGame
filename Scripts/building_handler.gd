extends Node2D

@export var ObjectContainer: Node2D 
@onready var guides: Node2D = $Guides


var reference: BuildingData = preload("res://Data/buildings/farm_lv1.tres") #Default
var guide: Building
var is_placement_mode: bool = false
var anchor: Vector2 = Vector2(0,0)
var building_list: Array[Building] = []
const tilesize: int = 32

func _ready() -> void:
	EventBus.change_building.connect(set_reference)
	EventBus.toggle_placement_mode.connect(toggle_placement_mode)
	
	

func _process(delta: float) -> void:
	if is_placement_mode:
		guide.global_position = (get_global_mouse_position() / tilesize).snapped(Vector2.ONE) * tilesize

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and is_placement_mode:
		if event.button_index == MOUSE_BUTTON_LEFT and check_blocking():
			create_building(reference)

func set_reference(building: BuildingData) -> void:
	reference = building

func check_blocking() -> bool:
	if !guide.building_space:
		print("Building Space Not Setup")
		return true
	for area in guide.building_space.get_overlapping_areas():
		if area is BuildingSpace:
			print("Area Occupied")
			return false
	return true

func setup_guide() -> void:
	if guide:
		guide.queue_free()
	guide = load(reference.build_scene_path).instantiate()
	add_child(guide)
	guide.activate_interaction(false)
	
func create_building(building_data: BuildingData) -> void:
	var new = load(building_data.build_scene_path).instantiate()
	ObjectContainer.add_child(new)
	new.global_position = guide.global_position
	new.building_data = building_data
	building_list.append(new)
	toggle_placement_mode(false)

func toggle_placement_mode(mode_on: bool) -> void:
	if mode_on:
		is_placement_mode = true
		setup_guide()
		guide.show()
	else:
		guide.hide()
		is_placement_mode = false
