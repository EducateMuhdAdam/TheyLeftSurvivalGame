extends Control


@onready var h_box_container: HBoxContainer = $MarginContainer/HBoxContainer
@export var slot_scene = preload("res://Scenes/inventory_slot.tscn")
@export var inventory_scene: Control

var normal_style: StyleBoxFlat = slot_scene.instantiate().get_theme_stylebox("panel")
var highlighted_style = StyleBoxFlat.new()


const HOTBAR_SIZE: int = 10
var slots: Dictionary = {}
var highlighted_id: int = 0

@onready var player = await Game.get_player()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	highlighted_style.bg_color = Color(0.4, 0.4, 0.2, 0.6)
	inventory_scene.slots_created.connect(setup_hotbar)

func _unhandled_input(event):
	if event.is_action_pressed("hotbar_next"):
		highlight_slot((highlighted_id + 1) % HOTBAR_SIZE)
	elif event.is_action_pressed("hotbar_prev"):
		highlight_slot((highlighted_id - 1 + HOTBAR_SIZE) % HOTBAR_SIZE)
	elif event.is_action_pressed("use_item"):
		interact_item(slots[highlighted_id].item)
	for i in range(0, HOTBAR_SIZE):
		if event.is_action_pressed(str((i + 1) % HOTBAR_SIZE)):
			highlight_slot(i)


func setup_hotbar() -> void:
	for i in range(0, HOTBAR_SIZE):
		var new_slot = slot_scene.instantiate()
		new_slot.slotID = i
		new_slot.controller = self
		new_slot.can_interact = false
		new_slot.notation = str((i + 1) % HOTBAR_SIZE)
		slots[i] = new_slot
		h_box_container.add_child(new_slot)
		inventory_scene.slots[i].slot_updated.connect(update_hotbar)
		update_hotbar(inventory_scene.slots[i])
	highlight_slot(highlighted_id)
		
func update_hotbar(slot: Slot) -> void:
	var hotbar_slot: Slot = slots[slot.slotID]
	hotbar_slot.update_slot(slot.item, slot.quantity)
	
func highlight_slot(slotID: int) -> void:
	slots[highlighted_id].add_theme_stylebox_override("panel", normal_style)
	slots[slotID].add_theme_stylebox_override("panel", highlighted_style)
	highlighted_id = slotID

func interact_item(itemData: Variant) -> void:
	if not (itemData is ItemData):
		return
	if "Food" in itemData.tags:
		player.increase_hunger(Catalogue.eating_reference[itemData.itemID])
		player.remove_one_inventory(highlighted_id)
	if "Drink" in itemData.tags:
		player.increase_thirst(Catalogue.drinking_reference[itemData.itemID])
		player.remove_one_inventory(highlighted_id)
	if "Message" in itemData.tags:
		var messageData: MessageData = Catalogue.item_to_message_reference[itemData.itemID]
		EventBus.open_message.emit(messageData)
	if "Scrap" in itemData.tags:
		EventBus.add_item.emit(Catalogue.scrap_reference[itemData.itemID])
	if itemData.itemID == 1:
		var level_root = await Game.get_level_root()
		var tileData: TileData = player.get_tile_data_infront(level_root.main_layer)
		if tileData != null && tileData.get_custom_data("water"):
			player.remove_one_inventory(highlighted_id)
			EventBus.add_item.emit(Catalogue.item_catalogue[4])
