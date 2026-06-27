extends CharacterBody2D
@onready var animated_sprite = $AnimatedSprite2D
@export var speed: float = 300.0
@export var acceleration: float = 10.0
@export var friction: float = 15.0

var maplabel: Label 
var bubble_text: String = ""
var last_direction: String = "front"

func _ready() -> void:
	add_to_group("player")
	load_scene_scaling_settings()

@onready var parent_node = get_parent()
@onready var sprite : Sprite2D = get_node("Sprite2D")

#for scaling the character
var character_scale : float 
var scaling_ratio : float
var floor_upper_limit : int
var floor_bottom_limit : int
var floor_size : float
var min_scale : float
var max_scale : float

func _physics_process(delta: float) -> void:
	if State.player == State.player_state.WALKING:
		move_character(delta)
	_refresh_bubble()
	apply_perspective_scaling()
#So the character's body scales according to its Y position, giving it depth
#region character_scaling
func apply_perspective_scaling():
	var t = (global_position.y - floor_upper_limit) / floor_size
	t = clamp(t, 0.0, 1.0)
	character_scale = lerp(min_scale, max_scale, t)
	scale = Vector2(character_scale, character_scale)

func load_scene_scaling_settings():
	if parent_node:
		scaling_ratio = parent_node.get("character_scaling_ratio")
		floor_upper_limit = parent_node.get("floor_upper_limit")
		floor_bottom_limit = parent_node.get("floor_bottom_limit")
		min_scale = parent_node.get("min_scale")
		max_scale = parent_node.get("max_scale")
		floor_size = floor_bottom_limit - floor_upper_limit	
	else:
		print("Your scaling settings are not available. Current scene:",name)
#endregion
#Functions that handle character movement
#region Movement
func get_input_direction() -> Vector2:
	var input_vector = Vector2.ZERO
	if Input.is_action_pressed("walk_up"):
		input_vector.y -= 1
		animated_sprite.play("walk_back")
		last_direction = "back"
	if Input.is_action_pressed("walk_down"):
		input_vector.y += 1
		animated_sprite.play("walk_front")
		last_direction = "front"
	if Input.is_action_pressed("walk_left"):
		input_vector.x -= 1
		animated_sprite.play("walk_left")
		last_direction = "left"
	if Input.is_action_pressed("walk_right"):
		input_vector.x += 1
		animated_sprite.play("walk_right")
		last_direction = "right"
	return input_vector.normalized()

func move_character(delta:float) -> void:
	var input_direction = get_input_direction()
	if input_direction != Vector2.ZERO:
		velocity = velocity.lerp(input_direction * speed, acceleration * delta)
	else:
		match last_direction:
			"right":
				animated_sprite.play("idle_right")
			"left":
				animated_sprite.play("idle_left")
			"front":
				animated_sprite.play("idle_front")
			"back":
				animated_sprite.play("idle_back")

		velocity = velocity.lerp(Vector2.ZERO, friction * delta)
		
	move_and_slide()
#endregion

func _refresh_bubble() -> void:
	if maplabel == null:
		maplabel = get_parent().get_node_or_null("MapMention")
	if bubble_text == "":
		if maplabel != null:
			maplabel.visible = false
		return
	if maplabel != null:
		maplabel.text = bubble_text
		maplabel.visible = true
	
