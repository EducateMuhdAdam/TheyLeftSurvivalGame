extends CharacterBody2D
class_name Player

#TODO: Create Default Error File For Item Not Found
#TODO: Make The buildings Function
#TODO: Make the Crafting Menu
#TODO: Make The Farming Menu
#TODO: Make Player Sprite
#TODO: Make Fishing

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var rt2d: RemoteTransform2D = $RemoteTransform2D
@onready var message_label: Label = $MessageLabel

signal hunger_changed(value)
signal thirst_changed(value)
signal update_inventory(inventory)

const MOVE_SPEED: float = 200
const INVENTORY_NUM: int = 30

var unlocked_recipes: Array[int] = Catalogue.get_crafting_resources().keys()
var unlocked_buildings: Array[int] = [8, 9]

var areaData: AreaData
var hunger_rate = 0.05
var thirst_rate = 0.2
var hunger = 40
var thirst = 40
var inventory = {0: {"id": 9, "qty": 1}}

var facing_direction: String = "S"
var input_direction: Vector2 = Vector2(0,0)
const direction_offset: Dictionary = {
	"N" : Vector2i(0, -1),
	"S" : Vector2i(0, 1),
	"W" : Vector2i(-1, 0),
	"E" : Vector2i(1, 0),
	"NE": Vector2i(1, -1),
	"NW": Vector2i(-1, -1),
	"SE": Vector2i(1, 1),
	"SW": Vector2i(-1, 1)
}

func _ready() -> void:
	if !areaData:
		areaData = load("res://Data/areas/4_tutorial.tres") #SetDefaultHere
	EventBus.change_area.connect(set_area_data)
	EventBus.add_item.connect(add_one_inventory)
	EventBus.add_multiple_item.connect(add_inventory)
	EventBus.swap_item.connect(swap_inventory)
	EventBus.erase_item.connect(remove_inventory)
	EventBus.remove_item.connect(remove_one_inventory)
	EventBus.show_fadeaway.connect(show_message)
	EventBus.unlock_building.connect(unlock_building)
	EventBus.unlock_crafting.connect(unlock_crafting)
	hunger_changed.emit(hunger)
	thirst_changed.emit(thirst)
	update_inventory.emit(inventory)
	

func _process(delta: float) -> void:
	
	decrease_hunger(delta)
	decrease_thirst(delta)
	
	if abs(velocity.x) == 0 and abs(velocity.y) == 0:
		sprite.animation = "idle-" + facing_direction
		return
		
	if abs(input_direction.x) > 0:
		if input_direction.y > 0:
			facing_direction = "SE"
		elif input_direction.y < 0:
			facing_direction = "NE"
		else:
			facing_direction = "E"
	else:
		if input_direction.y > 0:
			facing_direction = "S"
		else:
			facing_direction = "N"
		
	sprite.animation = "walk-" + facing_direction
	
	if velocity.x > 0:
		sprite.flip_h = false
	elif velocity.x < 0:
		sprite.flip_h = true

func _physics_process(delta: float) -> void:
	input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"), 
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	velocity = input_direction * MOVE_SPEED
	
	move_and_slide()

func array_to_arrayint(arr: Array) -> Array[int]:
	var new: Array[int] = []
	for id in arr:
		new.append(int(id))
	return new

func unlock_building(bID: Variant) -> void:
	if bID is Array:
		for ID in bID:
			if not ID in unlocked_buildings:
				unlocked_buildings.append(ID)
	else:
		if not bID in unlocked_buildings:
			unlocked_buildings.append(bID)

func unlock_crafting(cID: Variant) -> void:
	if cID is Array[int]:
		for ID in cID:
			if not ID in unlocked_recipes:
				unlocked_recipes.append(ID)
	else:
		if not cID in unlocked_recipes:
			unlocked_recipes.append(cID)

func decrease_hunger(delta: float) -> void:
	hunger = max(hunger - (hunger_rate * delta), 0) 
	hunger_changed.emit(hunger)
	
func increase_hunger(ammount: float) -> void:
	hunger = min(hunger + ammount, 100)
	hunger_changed.emit(hunger)
	
func decrease_thirst(delta: float) -> void:
	thirst = max(thirst - (thirst_rate * delta), 0) 
	thirst_changed.emit(thirst)

func increase_thirst(ammount: float) -> void:
	thirst = min(thirst + ammount, 100) 
	thirst_changed.emit(thirst)

func find_item_quantity(itemID: int, qty: int) -> Variant:
	for slotID in inventory.keys():
		if inventory[slotID]["id"] == itemID and inventory[slotID]["qty"] >= qty:
			return int(slotID)
	return null

func set_inventory_slot(slotID: int, itemID: int, qty: int):
	if !itemID || qty == 0:
		inventory.erase(slotID)
		return
	if !inventory.has(slotID):
		inventory[slotID] = {"id": itemID, "qty": qty}
		return
	inventory[slotID]["qty"] = qty
	inventory[slotID]["id"] = itemID

func set_inventory_quantity(slotID: int, qty: int) -> void:
	inventory[slotID]["qty"] = qty
	update_inventory.emit(inventory)

func add_inventory(data: ItemData, quantity: int) -> void:
	var item_lookup: Array[int] = []
	for slotkey in inventory.keys():
		item_lookup.append(inventory[slotkey]["id"])
	if data.itemID in item_lookup:
		for slotkey in inventory.keys():
			if inventory[slotkey]["id"] == data.itemID:
				inventory[slotkey]["qty"] += quantity
	else:
		for i in range(0, INVENTORY_NUM):
			if i not in inventory.keys():
				inventory[i] = {"id": data.itemID, "qty": quantity}
				break
	update_inventory.emit(inventory)

func find_item_from_dict(checkDict: Dictionary[int, int]) -> Array[int]:
	var found_slots: Array[int]
	for itemID in checkDict.keys():
		var slot = find_item_quantity(itemID, checkDict[itemID])
		if slot != null:
			found_slots.append(slot)
	return found_slots

func add_one_inventory(data: ItemData) -> void:
	add_inventory(data, 1)

func remove_inventory(slotID: int) -> void:
	inventory.erase(slotID)
	update_inventory.emit(inventory)

func remove_one_inventory(slotID: int) -> void:
	remove_ammount_inventory(slotID, 1)

func remove_ammount_inventory(slotID: int, qty: int) -> void:
	var slot = inventory[slotID]
	if slot["qty"] > qty:
		inventory[slotID]["qty"] -= qty
	else:
		inventory[slotID]["qty"] = 0
	update_inventory.emit(inventory)

func swap_inventory(ID1: int, ID2: int) -> void:
	if not inventory.has(ID1) and not inventory.has(ID2):
		return
	elif inventory.has(ID1) and inventory.has(ID2):
		var temp = inventory[ID1]
		inventory[ID1] = inventory[ID2]
		inventory[ID2] = temp
	elif inventory.has(ID1):
		inventory[ID2] = inventory[ID1]
		inventory.erase(ID1)
	else:
		inventory[ID1] = inventory[ID2]
		inventory.erase(ID2)
	update_inventory.emit(inventory)

func set_area_data(ad: AreaData) -> void:
	print("Set Player Area: ", ad)
	areaData = ad

func get_tile_data_infront(tilemap: TileMapLayer) -> TileData:
	var origin = tilemap.local_to_map(tilemap.to_local(global_position))
	var offset = direction_offset[facing_direction]
	var cell = origin + offset
	return tilemap.get_cell_tile_data(cell)

#MESSAGE POPUP
func show_message(text: String):
	message_label.text = text
	message_label.visible = true

	# Reset appearance
	message_label.position = Vector2(0, -54)
	message_label.position.x -= message_label.size.x / 2
	message_label.modulate = Color.WHITE

	var tween = create_tween()
	tween.set_parallel(true)
	# Float upward
	tween.tween_property(
		message_label,
		"position",
		message_label.position + Vector2(0, -30),
		2
	)
	# Fade out
	tween.tween_property(
		message_label,
		"modulate:a",
		0.0,
		2
	)
	await tween.finished
	message_label.visible = false

func save() -> Dictionary:
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x,
		"pos_y" : position.y,
		"areaData" : areaData.resource_path,
		"inventory" : inventory,
		"unlocked_recipes": unlocked_recipes,
		"unlocked_buildings": unlocked_buildings,
		"hunger_rate": hunger_rate,
		"thirst_rate": thirst_rate,
		"hunger": hunger,
		"thirst": thirst
	}
	return save_dict
