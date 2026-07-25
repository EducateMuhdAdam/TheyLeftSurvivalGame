extends InteractionArea
class_name QuestArea

var quest_panel: Resource = preload("res://Scenes/building_ui/quest_panel.tscn")
@export var eventID: int
@export var itemQuestData: ItemQuestData


func _ready():
	super()
	interact = func():
		var panel: BuildingPanel = quest_panel.instantiate()
		panel.eventID = eventID
		panel.building = self
		panel.itemQuestData = itemQuestData
		EventBus.shared_ui.emit(panel, self)

func set_active(actv: bool) -> void:
	if !actv:
		active = false
		InteractionManager.unregister_area(self)
	else:
		active = true
	

func save() -> Dictionary:
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
		"active": active
	}
	return save_dict
