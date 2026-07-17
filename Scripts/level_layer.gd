extends TileMapLayer
class_name LevelLayer

var _changed_tiles: Dictionary[Vector2i, Dictionary] = {}

@export var layer_name: StringName
var changed_tiles: Dictionary[Vector2i, Dictionary] = {}:
	get:
		return _changed_tiles
	set(value):
		_changed_tiles = value
		for cell_pos in _changed_tiles.keys():
			var tile = _changed_tiles[cell_pos]
			set_cell(
				tile["cell_pos"],
				0,
				tile["atlas_coords"],
				0
			)
func _ready() -> void:
	var level_root = await Game.get_level_root()
	level_root.set(layer_name, self)
	

func log_change(dict: Dictionary) -> void:
	if !dict.has("cell_pos") or !dict.has("atlas_coords"):
		print("Failed to log tile change: Key mismatch")
		return
	_changed_tiles[dict["cell_pos"]] = dict

func parse_vector2i(s: String) -> Vector2i:
	s = s.trim_prefix("(").trim_suffix(")")
	var parts = s.split(",")
	return Vector2i(parts[0].strip_edges().to_int(), parts[1].strip_edges().to_int())

func fix_dict(dict: Dictionary) -> Dictionary[Vector2i, Dictionary]:
	var fixed: Dictionary[Vector2i, Dictionary]
	var new_key
	for key in dict.keys():
		#For Each Log
		if key is String:
			new_key = parse_vector2i(key)
		else:
			new_key = key
		#For each key in Log
		var log = dict[key]
		for key2 in log.keys():
			if log[key2] is String:
				log[key2] = parse_vector2i(log[key2])
		fixed[new_key] = log
	return fixed
	
func save() -> Dictionary:
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x,
		"pos_y" : position.y,
		"child_index": get_index(),
		"changed_tiles": _changed_tiles
	}
	return save_dict
