extends WarpGate

@onready var interaction_area: InteractionArea = $InteractionArea

func _ready() -> void:
		interaction_area.interact = Callable(self, "_on_interact")
