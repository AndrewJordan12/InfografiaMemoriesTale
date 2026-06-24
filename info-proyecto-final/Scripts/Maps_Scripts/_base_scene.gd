extends Node2D
class_name BaseMap

@onready var main = get_node("/root/State")
@export var receiver_id := ""
#Variables for making the character sprite scale up or down according to vertical movement
@export var character_scaling_ratio : float = 1
@export var floor_bottom_limit : int = 650
@export var floor_upper_limit : int
@export var min_scale: float = 0.5
@export var max_scale: float = 1.5

var digit := -1

func _ready() -> void:
	_position_player()
	print("Current scene:",name)
	digit = main.get_digit(receiver_id)
	if digit != -1:
		assign_digit(digit)

func _position_player() -> void:
	var player = get_node_or_null("Player")
	if player == null:
		return
	if SceneTransition.spawn_trigger == "":
		return
	var trigger = get_node_or_null(SceneTransition.spawn_trigger)
	if trigger == null:
		return
	var vp: Vector2 = get_viewport_rect().size
	var pos: Vector2 = trigger.position + Vector2(60, 0)
	pos.x = clampf(pos.x, 50, vp.x - 50)
	pos.y = clampf(pos.y, 50, vp.y - 50)
	player.position = pos
	SceneTransition.spawn_trigger = ""

func _process(_delta: float) -> void:
	pass

func assign_digit(value: int):
	digit = value
	print(str(digit))
	on_digit_received()

func on_digit_received():
	pass
	
