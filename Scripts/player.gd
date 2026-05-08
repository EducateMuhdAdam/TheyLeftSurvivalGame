extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

const MOVE_SPEED: float = 200

var input_direction: Vector2 = Vector2(0,0)

func _process(delta: float) -> void:
	if abs(velocity.x) == 0 and abs(velocity.y) == 0:
		sprite.animation = "idle-S"
		return
		
	if abs(input_direction.x) > 0:
		if input_direction.y > 0:
			sprite.animation = "walk-SE"
		elif input_direction.y < 0:
			sprite.animation = "walk-NE"
		else:
			sprite.animation = "walk-E"
	else:
		if input_direction.y > 0:
			sprite.animation = "walk-S"
		else:
			sprite.animation = "walk-N"
		
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
