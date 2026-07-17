extends WarpGate

@onready var interaction_area: InteractionArea = $InteractionArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")

func warp_requirement() -> bool:
	var player: Player = await Game.get_player()
	var slotID = player.find_item_quantity(201, 1)
	if slotID != null:
		EventBus.remove_item.emit(slotID)
		return true
	else:
		return false

func fail_event() -> void:
	EventBus.show_fadeaway.emit("I need a key for this gate...")

func unlock_event() -> void:
	EventBus.execute_event.emit(2)
	unlocked = true
