extends Control

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var h_box_container: HBoxContainer = $MarginContainer/HBoxContainer
@export var slot_scene = preload("res://Scenes/inventory_slot.tscn")
@export var inventory_scene: Control

var normal_style: StyleBoxFlat = slot_scene.instantiate().get_theme_stylebox("panel")
var highlighted_style = StyleBoxFlat.new()


const HOTBAR_SIZE: int = 10
var slots: Dictionary = {}
var highlighted_id: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	highlighted_style.bg_color = Color(0.4, 0.4, 0.2, 0.6)
	await inventory_scene.ready
	setup_hotbar()
	highlight_slot(highlighted_id)

func _unhandled_input(event):
	if event.is_action_pressed("hotbar_next"):
		highlight_slot((highlighted_id + 1) % HOTBAR_SIZE)
	elif event.is_action_pressed("hotbar_prev"):
		highlight_slot((highlighted_id - 1 + HOTBAR_SIZE) % HOTBAR_SIZE)


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
		
func update_hotbar(slot: Slot) -> void:
	var hotbar_slot: Slot = slots[slot.slotID]
	hotbar_slot.update_slot(slot.item, slot.quantity)
	
func highlight_slot(slotID: int) -> void:
	slots[highlighted_id].add_theme_stylebox_override("panel", normal_style)
	slots[slotID].add_theme_stylebox_override("panel", highlighted_style)
	highlighted_id = slotID
