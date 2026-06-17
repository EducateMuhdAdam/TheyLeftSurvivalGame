extends Area2D
class_name InteractionArea

@export var action_name: String = "Interact"

func _ready():
	# Example for an Area2D or Area3D
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
var interact: Callable = func():
	print("Interacted")

var on_indicator: Callable = func():
	pass

var off_indicator: Callable = func():
	pass

func _on_body_entered(body: Node2D) -> void:
	# Check the group on the body itself instead of pre-saving a reference
	if body.is_in_group("Player"):
		on_indicator.call()
		InteractionManager.register_area(self)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		on_indicator.call()
		InteractionManager.unregister_area(self)
