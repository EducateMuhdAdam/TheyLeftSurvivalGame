extends Node2D

@export var ObjectContainer: Node2D 
@export var tilemap: TileMapLayer
@onready var guides: Node2D = $Guides
@onready var player = get_tree().get_first_node_in_group("Player")

var reference: BuildingData = preload("res://Data/buildings/farm_lv1.tres") #Default
var guide: Building
var is_placement_mode: bool = false
var anchor: Vector2 = Vector2(0,0)
var building_list: Array[Building] = []
var last_pos: Vector2 = Vector2.INF
const tilesize: int = 32

func _ready() -> void:
	EventBus.change_building.connect(set_reference)
	EventBus.toggle_placement_mode.connect(toggle_placement_mode)
	

func _process(delta: float) -> void:
	if !is_placement_mode:
		return
	
	var new_pos = (get_global_mouse_position() / tilesize).snapped(Vector2.ONE) * tilesize
	#guide.global_position = (get_global_mouse_position() / tilesize).snapped(Vector2.ONE) * tilesize
	if new_pos != last_pos:
		last_pos = new_pos
		guide.global_position = new_pos
		update_guide()
	

func remove_ingredients() -> void:
	if !reference:
		print("Reference not set")
		return
	var requirement = reference.requirement
	var found_slots: Array[int]
	for itemID in requirement.keys():
		var slot = player.find_item_quantity(itemID, requirement[itemID])
		if slot:
			found_slots.append(slot)
	if found_slots.size() == requirement.size():
		remove_items_from_player(found_slots)
	else:
		print("Error: Incorrect ammount of ingredients during placement")

func remove_items_from_player(slotIDs: Array[int]) -> void:
	for i in range(0, slotIDs.size()):
		var slotID = slotIDs[i]
		var itemID = reference.requirement.keys()[i]
		var qty = reference.requirement[itemID]
		player.remove_ammount_inventory(slotID, qty)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and is_placement_mode:
		if event.button_index == MOUSE_BUTTON_LEFT and check_can_place():
			create_building(reference)
			remove_ingredients()

func set_reference(building: BuildingData) -> void:
	reference = building

func update_guide() -> void:
	if check_can_place():
		guide.modulate = Color(1, 1, 1, 0.5)
	else:
		guide.modulate = Color(1, 0.3, 0.3, 0.8)

func check_can_place() -> bool:
	if !guide.building_space:
		print("Building Space Not Setup")
		return true
	var is_unblocked = guide.building_space.check_blocking()
	var is_terrain = guide.building_space.check_all_tiles(tilemap, guide.get_placement_requirement())
	return is_unblocked and is_terrain

func setup_guide() -> void:
	if guide:
		guide.queue_free()
	guide = load(reference.build_scene_path).instantiate()
	guides.add_child(guide)
	if guide.get_building_space():
		guide.building_space.area_detected.connect(update_guide)
	update_guide()
	guide.activate_interaction(false)



func create_building(building_data: BuildingData) -> void:
	var new = load(building_data.build_scene_path).instantiate()
	ObjectContainer.add_child(new)
	new.global_position = guide.global_position
	new.building_data = building_data
	building_list.append(new)
	toggle_placement_mode(false)

func show_guide(show: bool) -> void:
	if !guide:
		return
	if show:
		guide.show()
	else:
		guide.hide()

func toggle_placement_mode(mode_on: bool) -> void:
	if mode_on:
		is_placement_mode = true
		setup_guide()
		show_guide(true)
	else:
		show_guide(false)
		is_placement_mode = false
