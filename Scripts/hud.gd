extends CanvasLayer

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var hunger_label: Label = $MarginContainer/VBoxContainer/Hunger
@onready var thirst_label: Label = $MarginContainer/VBoxContainer/Thirst

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if player:
		player.hunger_changed.connect(_on_hunger_update)
		player.thirst_changed.connect(_on_thirst_update)

func _on_hunger_update(new_value: float) -> void:
	hunger_label.text = "Hunger: %.0f%%" % new_value
	
func _on_thirst_update(new_value: float) -> void:
	thirst_label.text = "Thirst: %.0f%%" % new_value
