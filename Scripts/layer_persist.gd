extends Node2D
class_name LayerPersist

var layer_saves: Dictionary = {}

func _ready() -> void:
	EventBus.log_layer.connect(save_layer)

func save_layer(layer: LevelLayer) -> void:
	layer_saves[layer.get_path()] = layer._changed_tiles

func set_layer() -> void:
	print(layer_saves)
	for path in layer_saves.keys():
		var layer: LevelLayer = get_node(path)
		layer.changed_tiles = layer.fix_dict(layer_saves[path])

func save() -> Dictionary:
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x,
		"pos_y" : position.y,
		"layer_saves": layer_saves
	}
	return save_dict
