extends Area2D
class_name BuildingSpace

@export var sizeX: int
@export var sizeY: int
const grid: Vector2 = Vector2(32,32)

var shape := RectangleShape2D.new()

func _ready() -> void:
	shape.size = Vector2(20, 20)
	setup_collisions()
	
func setup_collisions() -> void:
	if !sizeX or ! sizeY or sizeX <= 0 or sizeY <= 0:
		return
	for i in range(-floori((sizeX - 1) / 2.0), ceili((sizeX - 1) / 2.0) + 1):
		for j in range(-floori((sizeY - 1) / 2.0), ceili((sizeY - 1) / 2.0) + 1):
			var pos = Vector2(i * grid.x, j * grid.y) - grid/2
			var col = CollisionShape2D.new()
			col.shape = shape
			col.position = pos
			add_child(col)
