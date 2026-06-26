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
	if SceneTransition.minigame_won and SceneTransition.return_trigger_name != "":
		_disable_minigame_trigger()
		SceneTransition.minigame_won = false
		SceneTransition.return_trigger_name = ""

func _disable_minigame_trigger() -> void:
	var trigger = get_node_or_null(SceneTransition.return_trigger_name)
	if trigger and trigger.has_method("disable_trigger"):
		trigger.disable_trigger()

func _position_player() -> void:
	var player = get_node_or_null("Player")
	if player == null:
		return
	if SceneTransition.spawn_trigger == "":
		return
	var trigger = get_node_or_null(SceneTransition.spawn_trigger)
	if trigger == null:
		return
	var spawn_pos: Vector2
	if SceneTransition.spawn_marker != "":
		var marker = trigger.get_node_or_null(SceneTransition.spawn_marker)
		if marker:
			spawn_pos = marker.global_position
		else:
			spawn_pos = trigger.position + Vector2(60, 0)
	else:
		spawn_pos = trigger.position + Vector2(60, 0)
	var vp: Vector2 = get_viewport_rect().size
	spawn_pos.x = clampf(spawn_pos.x, 50, vp.x - 50)
	spawn_pos.y = clampf(spawn_pos.y, 50, vp.y - 50)
	player.position = spawn_pos
	SceneTransition.spawn_trigger = ""
	SceneTransition.spawn_marker = ""

func _process(_delta: float) -> void:
	pass

func assign_digit(value: int):
	digit = value
	print(str(digit))
	on_digit_received()

func on_digit_received():
	pass
	
