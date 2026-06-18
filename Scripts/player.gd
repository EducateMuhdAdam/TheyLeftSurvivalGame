extends CharacterBody2D

#TODO: Create Default Error File For Item Not Found
#TODO: Make The buildings Function
#TODO: Make the Crafting Menu
#TODO: Make The Farming Menu
#TODO: Make Player Sprite
#TODO: Make Fishing

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

signal hunger_changed(value)
signal thirst_changed(value)
signal update_inventory(inventory)

const MOVE_SPEED: float = 200
const INVENTORY_NUM: int = 30

var hunger_rate = 0.05
var thirst_rate = 0.2
var hunger = 100
var thirst = 100
var inventory = {1: {"id": 1, "qty": 2}, 0: {"id": 2, "qty": 1}}
var item_lookup: Array[int] = []

var facing_direction: String = "S"
var input_direction: Vector2 = Vector2(0,0)

func _ready() -> void:
	update_lookout()
	EventBus.add_item.connect(add_inventory)
	hunger_changed.emit(hunger)
	thirst_changed.emit(thirst)

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

func decrease_hunger(delta: float) -> void:
	hunger = max(hunger - (hunger_rate * delta), 0) 
	hunger_changed.emit(hunger)
	
func decrease_thirst(delta: float) -> void:
	thirst = max(thirst - (thirst_rate * delta), 0) 
	thirst_changed.emit(thirst)

func add_inventory(data: ItemData) -> void:
	if data.itemID in item_lookup:
		for slotkey in inventory.keys():
			if inventory[slotkey]["id"] == data.itemID:
				inventory[slotkey]["qty"] += 1
	else:
		for i in range(0, INVENTORY_NUM):
			if i not in inventory.keys():
				inventory[i] = {"id": data.itemID, "qty": 1}
				item_lookup.append(data.itemID)
				break
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
	
func update_lookout() -> void:
	for slotkey in inventory.keys():
		item_lookup.append(inventory[slotkey]["id"])
