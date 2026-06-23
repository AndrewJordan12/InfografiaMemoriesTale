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
	print("Current scene:",name)
	digit = main.get_digit(receiver_id)
	if digit != -1:
		assign_digit(digit)

func _process(_delta: float) -> void:
	pass

func assign_digit(value: int):
	digit = value
	print(str(digit))
	on_digit_received()

func on_digit_received():
	pass
	
