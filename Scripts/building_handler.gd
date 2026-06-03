extends Node2D

@onready var buildings: Node2D = $Buildings
@onready var guides: Node2D = $Guides


var reference: BuildingData = preload("res://Data/buildings/farm_lv1.tres") #Default
var guide: Sprite2D = Sprite2D.new()
var is_build_mode: bool = true
var anchor: Vector2 = Vector2(0,0)
var building_list: Array[Building] = []
const tilesize: int = 32

func _ready() -> void:
	EventBus.change_building.connect(set_reference)
	setup_guide(reference)
	
	guide.scale = Vector2(2, 2)
	guides.add_child(guide)
	

func _process(delta: float) -> void:
	if is_build_mode:
		guide.global_position = (get_global_mouse_position() / tilesize).snapped(Vector2.ONE) * tilesize

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			create_building(reference)

func set_reference(building: BuildingData) -> void:
	reference = building
	setup_guide(building)

func setup_guide(building: BuildingData) -> void:
	guide.texture = building.image
	
func create_building(building: BuildingData) -> void:
	var new = building.physical_scene.instantiate()
	new.global_position = guide.global_position
	building_list.append(new)
	buildings.add_child(new)
