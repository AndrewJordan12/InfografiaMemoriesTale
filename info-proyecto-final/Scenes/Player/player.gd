extends CharacterBody2D

@export var speed: float = 300.0
@export var acceleration: float = 10.0
@export var friction: float = 15.0

func _physics_process(delta: float) -> void:
	move_character(delta)

#region Movement
func get_input_direction() -> Vector2:
	
	var input_vector = Vector2.ZERO
	if Input.is_action_pressed("walk_up"):
		input_vector.y -= 1
	if Input.is_action_pressed("walk_down"):
		input_vector.y += 1
	if Input.is_action_pressed("walk_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("walk_right"):
		input_vector.x += 1

	return input_vector.normalized()
	
func move_character(delta:float) -> void:
	var input_direction = get_input_direction()
	if input_direction != Vector2.ZERO:
		velocity = velocity.lerp(input_direction * speed, acceleration * delta)
	else:
		velocity = velocity.lerp(Vector2.ZERO, friction * delta)
	move_and_slide()
