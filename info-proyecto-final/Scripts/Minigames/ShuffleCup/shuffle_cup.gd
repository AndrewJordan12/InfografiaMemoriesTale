extends Node2D

signal puzzle_ended(won:bool)

@export var reward_digit := 0

@onready var gameover = $GameOver
@onready var cups_parent = $PanelContainer/Cups
@onready var cup_scene = preload("res://Scenes/Minigame/Cup.tscn")
@onready var score_label = $Score
@onready var attempts_label = $Attempts

var current_level := 1
var visible_cups : Array = []
var original_positions := {}
var ball_cup : Button
var accepting_input := false
var attempts:int = 3

const MAX_CUPS := 5

const LEVELS = {
	1: {
		"cups": 3,
		"shuffles": 10
	},
	2: {
		"cups": 4,
		"shuffles": 12
	},
	3: {
		"cups": 5,
		"shuffles": 15
	}
}

func _ready():
	await  start()

func start():
	await create_cups()
	await start_level(1)

func create_cups():
	var cup_size := Vector2(200, 240)
	var spacing := 30.0
	await get_tree().process_frame
	var panel_width = max($PanelContainer.size.x, 500.0)
	var cups_per_row = max(1,int((panel_width + spacing) / (cup_size.x + spacing)))
	for i in range(MAX_CUPS):
		var cup: Button = cup_scene.instantiate()
		cups_parent.add_child(cup)
		cup.pressed.connect(_on_cup_selected.bind(cup))
		var row = i / cups_per_row
		var col = i % cups_per_row
		var row_count = min(cups_per_row,MAX_CUPS - row * cups_per_row)
		var row_width = row_count * cup_size.x + (row_count - 1) * spacing
		var start_x = (panel_width - row_width) * 0.5
		cup.position = Vector2(start_x + col * (cup_size.x + spacing),row * (cup_size.y + spacing))
		original_positions[cup] = cup.position
		print(cup.position)
	print("Created:", cups_parent.get_child_count())

func start_level(level:int):
	visible = true
	current_level = level
	attempts_label.text = "Attempts: " + str(attempts)
	score_label.text = "Level:"+ str(current_level) + "/" + str(LEVELS.size())
	accepting_input = false
	await reset_cups()
	var config = LEVELS[current_level]
	setup_cups(config.cups)
	ball_cup = visible_cups.pick_random()
	await ball_cup.reveal_ball()
	await shuffle_sequence(config.shuffles)
	accepting_input = true

func setup_cups(count:int):
	visible_cups.clear()
	for i in range(cups_parent.get_child_count()):
		var cup = cups_parent.get_child(i)
		var active = i < count
		cup.visible = active
		cup.disabled = !active
		if active:
			visible_cups.append(cup)

func reset_cups():
	for cup in cups_parent.get_children():
		cup.position = original_positions[cup]
		if cup.is_raised:
			await cup.lower_cup()
		cup.update_start_position()

func shuffle_sequence(shuffle_count:int):
	for i in range(shuffle_count):
		var a = randi() % visible_cups.size()
		var b = randi() % visible_cups.size()
		while a == b:
			b = randi() % visible_cups.size()
		await swap_cups(a, b)
		await get_tree().create_timer(0.15).timeout

func swap_cups(a:int, b:int):
	var cup_a = visible_cups[a]
	var cup_b = visible_cups[b]
	await cup_a.swap_with(cup_b)
	visible_cups[a] = cup_b
	visible_cups[b] = cup_a
	if ball_cup == cup_a:
		ball_cup = cup_b
	elif ball_cup == cup_b:
		ball_cup = cup_a

func _on_cup_selected(cup):
	print("CLICKED", cup)
	if !accepting_input:
		return
	accepting_input = false
	if cup == ball_cup:
		await handle_win()
	else:
		await handle_fail()

func handle_win():
	await ball_cup.raise_cup()
	var max_level = LEVELS.size()
	if current_level < max_level:
		await get_tree().create_timer(1.0).timeout
		await start_level(current_level + 1)
		score_label.text = "Level:"+ str(current_level) + "/" + str(max_level)
	else:
		puzzle_ended.emit(true)

func handle_fail():
	attempts -= 1
	attempts_label.text = "Attempts" + str(attempts)
	await ball_cup.raise_cup()
	if attempts <= 0:
		gameover.set_state(false, false)
		puzzle_ended.emit(false)
	else:
		retry()

func retry():
	await start_level(current_level)

func on_win(digit:int):
	gameover.set_state(true, digit)

func _on_game_over_on_retry() -> void:
	await  start_level(1)

func _on_game_over_on_x() -> void:
	visible = false
