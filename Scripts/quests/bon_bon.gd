extends StaticBody2D

@onready var rt2d: RemoteTransform2D = $RemoteTransform2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var lr: LevelRoot = await Game.get_level_root()
	lr.register_object("BonBon", self)

func save() -> Dictionary:
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x,
		"pos_y" : position.y
	}
	return save_dict
