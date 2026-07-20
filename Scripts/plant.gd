extends Building
class_name Plant

@export var textures: Dictionary[Stage, Texture2D]
@export var time_to_grow: int
@export var harvest: Dictionary[int, int]
@export var grown: bool = false

var progress: int
var interaction_area: InteractionArea
var current_stage: Stage

enum Stage{CHILD, TEEN, ADULT}
var timer: Timer = Timer.new()

func _ready() -> void:
	if grown:
		progress = 1
	if !progress:
		progress = time_to_grow
	if active:
		add_to_group("Persist")
		add_to_group("Buildings")
		timer.autostart = true
	activate_collision(active)	
	interaction_area = get_interaction_area()
	timer.wait_time = 1
	timer.timeout.connect(_on_timeout)
	interaction_area.active = false
	interaction_area.action_name = "Harvest"
	interaction_area.interact = Callable(self, "_on_interact")
	is_stage_different() # Set The Stage on init
	add_child(timer)

func get_interaction_area() -> Variant:
	for node in get_children():
		if node is InteractionArea:
			return node
	print("InteractionArea not Set")
	return null

func get_sprite2d() -> Variant:
	for node in get_children():
		if node is Sprite2D:
			return node
	print("Sprite2D not Set")
	return null

func is_stage_different() -> bool:
	var new_stage: Stage
	if progress > time_to_grow / 2 :
		new_stage = Stage.CHILD
	elif progress > 0:
		new_stage = Stage.TEEN
	else:
		new_stage = Stage.ADULT
	
	if current_stage != new_stage:
		current_stage = new_stage
		return true
	return false
	
func _on_timeout() -> void:
	progress -= 1
	if is_stage_different():
		get_sprite2d().texture = textures[current_stage]
	if progress > 0:
		return
	interaction_area.active = true
	timer.stop()

func get_placement_requirement() -> Callable:
	return is_soil

func _on_interact() -> void:
	for key in harvest:
			EventBus.add_multiple_item.emit(Catalogue.item_catalogue[key], harvest[key])
	destroy_building()

func save() -> Dictionary:
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"progress": progress
	}
	return save_dict
