extends WarpGate

@onready var interaction_area: InteractionArea = $InteractionArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")

func warp_requirement() -> bool:
	return true
	
func unlock_event() -> void:
	pass
