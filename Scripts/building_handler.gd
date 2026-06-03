extends Node2D

@export var default: Resource = preload("res://Scenes/farm_lv1.tscn")

var guide: Building = null
var is_build_mode: bool = true
var anchor: Vector2 = Vector2(0,0)
var building_list: Array[Building] = []
const tilesize: int = 32

func _ready() -> void:
	setup_guide(default)
	add_child(guide)
	

func _process(delta: float) -> void:
	if is_build_mode:
		guide.global_position = (get_global_mouse_position() / tilesize).snapped(Vector2.ONE) * tilesize

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			create_building(default)

func setup_guide(building: Resource) -> void:
	guide = building.instantiate()
	
func create_building(building: Resource) -> void:
	var new = building.instantiate()
	new.global_position = guide.global_position
	building_list.append(new)
	add_child(new)
	
