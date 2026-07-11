extends Node2D

@export var ObjectContainer: Node2D 
@export var tilemap: TileMapLayer
@onready var guides: Node2D = $Guides
@onready var player: CharacterBody2D = await Game.get_player()

enum BuildMode {PLACE, DESTROY, OFF}

var reference: BuildingData = preload("res://Data/buildings/farm_lv1.tres") #Default
var guide: Building
var highlighted: Building
var mode: BuildMode = BuildMode.OFF
var anchor: Vector2 = Vector2(0,0)
var building_list: Array[Building] = []
var last_pos: Vector2 = Vector2.INF
const tilesize: int = 32

func _ready() -> void:
	EventBus.change_building.connect(set_reference)
	EventBus.toggle_placement_mode.connect(toggle_placement_mode)
	EventBus.toggle_destroy_mode.connect(toggle_destroy_mode)
	log_buildings()

func _process(delta: float) -> void:
	if mode == BuildMode.OFF:
		return
	match mode:
		BuildMode.PLACE:
			var new_pos = (get_global_mouse_position() / tilesize).snapped(Vector2.ONE) * tilesize
			#guide.global_position = (get_global_mouse_position() / tilesize).snapped(Vector2.ONE) * tilesize
			if new_pos != last_pos:
				last_pos = new_pos
				guide.global_position = new_pos
				update_guide()
		BuildMode.DESTROY:
			var building = get_building_under_mouse()
			if building != highlighted:
				if highlighted:
					highlight_destroy(highlighted, false)
	
				highlighted = building
				
				if highlighted:
					highlight_destroy(highlighted, true)

#REDUNDANT
func log_buildings() -> void:
	print(building_list.size(), " buildings logged", building_list)

func remove_ingredients() -> void:
	if !reference:
		print("Reference not set")
		return
	var requirement = reference.requirement
	var found_slots: Array[int] = player.find_item_from_dict(requirement)
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
	if event is not InputEventMouseButton or !event.pressed:
		return
	match mode:
		BuildMode.PLACE:
			if event.button_index == MOUSE_BUTTON_LEFT and check_can_place():
				create_building(reference)
				remove_ingredients()
		BuildMode.DESTROY:
			destroy_building(highlighted)

func set_reference(building: BuildingData) -> void:
	reference = building

func update_guide() -> void:
	if check_can_place():
		guide.modulate = Color(1, 1, 1, 0.5)
	else:
		guide.modulate = Color(1, 0.3, 0.3, 0.8)

func highlight_destroy(building: Building, highlighted: bool) -> void:
	if highlighted:
		building.modulate = Color(1, 0.3, 0.3, 0.8)
	else:
		building.modulate = Color(1, 1, 1, 1)

func destroy_building(building: Variant) -> void:
	if !building:
		return
	var ingredients: Dictionary = building.building_data.requirement
	for itemID in ingredients.keys():
		player.add_inventory(Catalogue.item_catalogue[itemID], ingredients[itemID])
	building.destroy_building()

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
	guide.remove_from_group("Persist")
	guide.collision_mask = 2
	if guide.get_building_space():
		guide.building_space.area_detected.connect(update_guide)
		guide.building_space.collision_layer = 1 << 1
		guide.building_space.collision_mask = 1 << 0
	update_guide()
	guide.activate_interaction(false)

func get_building_under_mouse() -> Building:
	var query = PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = 1 << 0
	var results = get_world_2d().direct_space_state.intersect_point(query)
	for result in results:
		var area = result.collider
		if area is BuildingSpace && area.get_parent() in building_list:
			return area.get_parent() as Building
	return null


func create_building(building_data: BuildingData) -> void:
	var new: Building = load(building_data.build_scene_path).instantiate()
	ObjectContainer.add_child(new)
	new.global_position = guide.global_position
	new.setup_data(building_data)
	building_list.append(new)
	toggle_placement_mode(false)
	EventBus.mode_display.emit(GlobalEnum.BuildMode.OFF)

func show_guide(show: bool) -> void:
	if !guide:
		return
	if show:
		guide.show()
	else:
		guide.hide()

func toggle_placement_mode(mode_on: bool) -> void:
	if mode_on:
		mode = BuildMode.PLACE
		setup_guide()
		show_guide(true)
	elif mode == BuildMode.PLACE:
		mode = BuildMode.OFF
	if !mode_on:
		show_guide(false)
		
		
func toggle_destroy_mode(mode_on: bool) -> void:
	if mode_on:
		mode = BuildMode.DESTROY
	elif mode == BuildMode.DESTROY:
		mode = BuildMode.OFF
	if !mode_on:
		if highlighted:
			highlight_destroy(highlighted, false)
