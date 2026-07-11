extends Building

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer

const FILTERTIME: float = 3

var dirty: float = 0
var clean: float = 0
var panel: BuildingPanel

var input: Dictionary = {"data": null, "qty": 0}
var output: Dictionary = {"data": null, "qty": 0}

var wf_empty = preload("res://Assets/Images/Buildings/WaterFilterLv1.png")
var wf_input = preload("res://Assets/Images/Buildings/WaterFilterLv1_input.png")
var wf_output = preload("res://Assets/Images/Buildings/WaterFilterLv1_output.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")
	timer.timeout.connect(_on_timeout)
	if timer.is_stopped() and dirty > 0 and clean < 100:
		timer.start(FILTERTIME)


func _on_interact():
	panel = load(self.data.ui_scene_path).instantiate()
	panel.building = self
	EventBus.shared_ui.emit(panel, self)
	panel.building_texture.texture = sprite.texture
	setup_panel()

func activate_interaction(active: bool) -> void:
	interaction_area.active = active

func setup_panel() -> void:
	if !panel:
		return
	if input["data"]:
		panel.input.update_slot(input["data"], input["qty"])
	if output["data"]:
		panel.output.update_slot(output["data"], output["qty"])
	panel.input.position = Vector2(238, 263)
	panel.output.position = Vector2(86, 289)

func building_action(panel: PanelContainer) -> void:
	input["data"] = panel.input.item
	input["qty"] = panel.input.quantity
	output["data"] = panel.output.item
	output["qty"] = panel.output.quantity
	fill_clean()
	empty_dirty()
	update_sprite()
	if timer.is_stopped() and dirty > 0 and clean < 100:
		timer.start(FILTERTIME)

func fill_clean() -> void:
	if clean >= 20 and output["data"] == Catalogue.item_catalogue[1]:
		if panel:
			panel.output.update_slot(Catalogue.item_catalogue[3], 1)
		output["data"] = Catalogue.item_catalogue[3]
		output["qty"] = 1
		clean = max(0, clean - 20)
	

func empty_dirty() -> void:
	if dirty < 100 and input["data"] == Catalogue.item_catalogue[4]:
		if panel:
			panel.input.update_slot(Catalogue.item_catalogue[1], 1)
		dirty = min(100 - clean, dirty + 20)
		input["data"] = Catalogue.item_catalogue[1]
		input["qty"] = 1

func update_sprite() -> void:
	if clean >= 20:
		sprite.texture = wf_output
	elif dirty + clean >= 20:
		sprite.texture = wf_input
	else:
		sprite.texture = wf_empty

func _on_timeout() -> void:
	print("Dirty: ", dirty, ", Clean: ", clean)
	if dirty > 0 and clean < 100:
		dirty -= 1
		clean += 1
	else:
		timer.stop()
	empty_dirty()
	fill_clean()
	update_sprite()
	
func save() -> Dictionary:
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"input" : input,
		"output" : output,
		"dirty" : dirty,
		"clean" : clean
	}
	return save_dict
