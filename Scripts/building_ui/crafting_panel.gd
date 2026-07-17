extends BuildingPanel

var player: CharacterBody2D
@onready var recipe_container: VBoxContainer = $MarginContainer/VBoxContainer/ScrollContainer/RecipeContainer
@onready var scroll_container: ScrollContainer = $MarginContainer/VBoxContainer/ScrollContainer
@onready var confirm: Button = $MarginContainer/VBoxContainer/HBoxContainer/Confirm
@onready var label: Label = $MarginContainer/VBoxContainer/Label
@onready var recipe_button_template = preload("res://Scenes/crafting_button.tscn")
@onready var warning: Label = $MarginContainer/VBoxContainer/HBoxContainer/Warning

const PANEL_HEIGHT: float = 400

var crafting_menu_group = ButtonGroup.new()
var max_width: float = 0
var crafting_buttons = []
var highlighted: CraftingData

func _ready() -> void:
	player = await Game.get_player()
	warning.hide()
	populate_scrollbar()
	scroll_container.custom_minimum_size.x = max_width
	scroll_container.custom_minimum_size.y = PANEL_HEIGHT - label.size.y - confirm.size.y
	

func close_panel() -> void:
	queue_free()

func populate_scrollbar() -> void:
	for craftingID in player.unlocked_recipes:
		var newButton = recipe_button_template.instantiate()
		crafting_buttons.append(newButton)
		newButton.set_recipe(Catalogue.crafting_catalogue[craftingID])
		newButton.button_group = crafting_menu_group
		newButton.pressed.connect(set_highlight.bind(newButton))
		recipe_container.add_child(newButton)
		max_width = max(newButton.get_combined_minimum_size().x, max_width)

func set_highlight(button) -> void:
	highlighted = button.crafting_reference

func _on_confirm_pressed() -> void:
	if !highlighted:
		return
	var found_slots: Array[int]
	for itemID in highlighted.recipe.keys():
		var slot = player.find_item_quantity(itemID, highlighted.recipe[itemID])
		if slot != null:
			found_slots.append(slot)
	if found_slots.size() == highlighted.recipe.size():
		get_product()
		remove_ingredients(found_slots)
		warning.hide()
	else:
		warning.show()

func get_product() -> void:
	for itemID in highlighted.product.keys():
		player.add_inventory(Catalogue.item_catalogue[itemID], highlighted.product[itemID])
		
func remove_ingredients(slotIDs: Array[int]) -> void:
	for i in range(0, slotIDs.size()):
		var slotID = slotIDs[i]
		var itemID = highlighted.recipe.keys()[i]
		var qty = highlighted.recipe[itemID]
		player.remove_ammount_inventory(slotID, qty)
