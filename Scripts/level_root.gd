extends Node2D
class_name LevelRoot

@export var building_handler: Node2D = get_node_or_null("BuildingHandler")
@export var item_handler: Node2D = get_node_or_null("ItemHandler")
@export var collision_layer: TileMapLayer
@export var main_layer: TileMapLayer
@export var decoration_layer: TileMapLayer

func _ready() -> void:
	Game.set_level_root(self)

func remove_collision(cell_pos: Vector2i) -> void:
	#print("Erasing Collision on ", cell_pos)
	collision_layer.erase_cell(cell_pos)

func add_collision(cell_pos, source_id, atlas_coords, alternative) -> void:
	#print("Adding Collision on ", cell_pos)
	collision_layer.set_cell(cell_pos, source_id, atlas_coords, alternative)
	
func change_tile(tilemap: TileMapLayer, cell_pos: Vector2i, atlas_coords: Vector2i):
	tilemap.set_cell(
		cell_pos,
		0,
		atlas_coords,
		0
	)
	if tilemap.has_method("log_change"):
		tilemap.log_change({"cell_pos": cell_pos, "atlas_coords": atlas_coords})
