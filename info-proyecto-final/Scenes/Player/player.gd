extends CharacterBody2D

@export var speed: float = 300.0
@export var acceleration: float = 10.0
@export var friction: float = 15.0

var bubble_text: String = ""
var _bubble_label: Label

func _ready() -> void:
	add_to_group("player")
	_bubble_label = Label.new()
	_bubble_label.name = "BubbleLabel"
	_bubble_label.position = Vector2(-120, -110)
	_bubble_label.size = Vector2(240, 50)
	_bubble_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_bubble_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_bubble_label.visible = false
	_bubble_label.add_theme_font_size_override("font_size", 42)
	add_child(_bubble_label)

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

func _ready() -> void:
	load_scene_scaling_settings()

func _physics_process(delta: float) -> void:
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

func _refresh_bubble() -> void:
	if _bubble_label == null:
		return
	if bubble_text == "":
		_bubble_label.visible = false
		return
	_bubble_label.text = bubble_text
	_bubble_label.add_theme_color_override("font_color", Color.BLACK)
	var bg = StyleBoxFlat.new()
	bg.bg_color = Color.WHITE
	bg.set_corner_radius_all(8)
	bg.set_content_margin_all(6)
	_bubble_label.add_theme_stylebox_override("normal", bg)
	_bubble_label.visible = true

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
#endregion
