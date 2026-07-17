extends Area2D
class_name EventArea

@export var eventID: int
@export var interactable: bool


var interaction_area: InteractionArea

func _ready() -> void:
	if interactable:
		interaction_area = InteractionArea.new()
		body_entered.connect(interaction_area._on_body_entered)
		body_exited.connect(interaction_area._on_body_exited)
		interaction_area.interact = Callable(self, "trigger_event")
		interaction_area.action_name = "Turn Off Production"
		add_child(interaction_area)
		

func reparent_collisions(area: Area2D) -> void:
	for child in get_children():
		if child is CollisionShape2D:
			child.reparent(area)

func trigger_event() -> void:
	print("Event ", eventID, " Signaled")
	EventBus.execute_event.emit(eventID)
