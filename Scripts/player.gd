extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

const MOVE_SPEED: float = 200

var facing_direction: String = "S"
var input_direction: Vector2 = Vector2(0,0)

func _process(delta: float) -> void:
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
