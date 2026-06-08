extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

signal hunger_changed(value)
signal thirst_changed(value)

const MOVE_SPEED: float = 200

var hunger_rate = 0.05
var thirst_rate = 0.2
var hunger = 100
var thirst = 100

var facing_direction: String = "S"
var input_direction: Vector2 = Vector2(0,0)

func _ready() -> void:
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
