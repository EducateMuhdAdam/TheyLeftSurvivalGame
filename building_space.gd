extends Area2D
class_name BuildingSpace

@export var sizeX: int
@export var sizeY: int

const grid: Vector2 = Vector2(32,32)

signal area_detected

var shape := RectangleShape2D.new()
var blockers = []
var footprint: Array[Vector2i] = []

func _ready() -> void:
	self.area_entered.connect(_on_area_entered)
	self.area_exited.connect(_on_area_exited)
	shape.size = Vector2(20, 20)
	setup_collisions()

func _on_area_entered(area: Area2D):
	blockers.append(area)
	area_detected.emit()

func _on_area_exited(area: Area2D):
	blockers.erase(area)
	area_detected.emit()

func check_all_tiles(tilemap: TileMapLayer, requirement: Callable) -> bool:
	var origin = tilemap.local_to_map(tilemap.to_local(global_position))
	for offset in footprint:
		var cell = origin + offset
		var data: TileData = tilemap.get_cell_tile_data(cell)
		if !requirement.call(data):
			return false
		
	return true

func check_blocking() -> bool:
	for area in blockers:
		if area is BuildingSpace:
			return false
	return true

func setup_collisions() -> void:
	if !sizeX or ! sizeY or sizeX <= 0 or sizeY <= 0:
		return
	for i in range(-floori((sizeX - 1) / 2.0), ceili((sizeX - 1) / 2.0) + 1):
		for j in range(1 - floori(sizeY / 2.0), sizeY + 1 - floori(sizeY / 2.0)):
			footprint.append(Vector2i(i - 1, j - 1))
			var pos = Vector2(i * grid.x, j * grid.y) - grid/2
			var col = CollisionShape2D.new()
			col.shape = shape
			col.position = pos
			add_child(col)
