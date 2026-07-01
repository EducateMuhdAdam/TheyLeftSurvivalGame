extends Button

var crafting_reference: CraftingData
@onready var margin_container: MarginContainer = $MarginContainer
@onready var h_box_container: HBoxContainer = $MarginContainer/HBoxContainer
@onready var recipebox: HBoxContainer = $MarginContainer/HBoxContainer/Recipe
@onready var productbox: HBoxContainer = $MarginContainer/HBoxContainer/Product
@export var slot_scene = preload("res://Scenes/inventory_slot.tscn")

func _ready() -> void:
	margin_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	setup_button()

func set_recipe(crafting_data: CraftingData) -> void:
	crafting_reference = crafting_data
	
func setup_button() -> void:
	for prodkey in crafting_reference.product.keys():
		var newSlot: Slot = slot_scene.instantiate()
		newSlot.can_interact = false
		newSlot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		productbox.add_child(newSlot)
		newSlot.update_slot(Catalogue.item_catalogue[prodkey], crafting_reference.product[prodkey])
		
	#await get_tree().process_frame
	
	for recipekey in crafting_reference.recipe.keys():
		var newSlot: Slot = slot_scene.instantiate()
		newSlot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		newSlot.can_interact = false
		recipebox.add_child(newSlot)
		newSlot.update_slot(Catalogue.item_catalogue[recipekey], crafting_reference.recipe[recipekey])
	
	custom_minimum_size = margin_container.get_combined_minimum_size()
	minimum_size_changed.emit()
