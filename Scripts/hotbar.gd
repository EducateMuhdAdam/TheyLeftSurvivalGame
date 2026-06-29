extends Control

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var h_box_container: HBoxContainer = $MarginContainer/HBoxContainer
@export var slot_scene = preload("res://Scenes/inventory_slot.tscn")
@export var inventory_scene: Control

const HOTBAR_SIZE: int = 10
var slots: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await inventory_scene.ready
	setup_hotbar()


func setup_hotbar() -> void:
	for i in range(0, HOTBAR_SIZE):
		var new_slot = slot_scene.instantiate()
		new_slot.slotID = i
		new_slot.controller = self
		new_slot.can_interact = false
		new_slot.notation = str(i)
		slots[i] = new_slot
		h_box_container.add_child(new_slot)
		inventory_scene.slots[i].slot_updated.connect(update_hotbar)
		update_hotbar(inventory_scene.slots[i])
		
func update_hotbar(slot: PanelContainer) -> void:
	var hotbar_slot = slots[slot.slotID]
	hotbar_slot.update_slot(slot.item, slot.quantity)
