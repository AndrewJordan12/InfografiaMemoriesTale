extends Node2D
class_name BaseMap

@onready var main = get_node("/root/State")
@export var receiver_id := ""

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
	
