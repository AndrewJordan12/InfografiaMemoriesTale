extends Node2D

@onready var gameover = $GameOver
@onready var cups_parent = $PanelContainer/Cups
@onready var cup_scene = preload("res://Scenes/Minigames/ShuffleCup/Cup.tscn")
@onready var score_label = $Score
@onready var attempts_label = $Attempts
@onready var ball = $Ball

var current_level := 1
var visible_cups : Array = []
var original_positions := {}
var ball_index := 0
const BALL_OFFSET := Vector2(70, 165) 
var accepting_input := false
var max_attempts : int = 3
var attempts : int = max_attempts
const MAX_CUPS := 5

const LEVELS = {
	1: {
		"cups": 3,
		"shuffles": 1
	},
	2: {
		"cups": 4,
		"shuffles": 1
	},
	3: {
		"cups": 5,
		"shuffles": 1
	}
}

func _ready():
	await start()

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

func start_level(level:int):
	visible = true
	current_level = level
	attempts_label.text = "Attempts: " + str(attempts)
	score_label.text = "Level:"+ str(current_level) + "/" + str(LEVELS.size())
	accepting_input = false
	await reset_cups()
	var config = LEVELS[current_level]
	setup_cups(config.cups)
	ball.visible = false
	ball_index = randi() % visible_cups.size()
	update_ball_position()
	await visible_cups[ball_index].raise_cup()
	ball.visible = true
	await get_tree().create_timer(1.5).timeout
	await visible_cups[ball_index].lower_cup()
	ball.visible = false
	await shuffle_sequence(config.shuffles)
	accepting_input = true

func update_ball_position():
	var cup = visible_cups[ball_index]
	ball.global_position = cup.global_position + BALL_OFFSET

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
		if cup.is_raised:
			await cup.lower_cup()
		cup.position = original_positions[cup]
		cup.update_start_position()
	ball.visible = false

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
	if ball_index == a:
		ball_index = b
	elif ball_index == b:
		ball_index = a
	update_ball_position()

func _on_cup_selected(cup):
	if !accepting_input:
		return
	accepting_input = false
	if cup == visible_cups[ball_index]:
		await handle_win()
	else:
		await handle_fail()

func handle_win():
	ball.visible = true
	await visible_cups[ball_index].raise_cup()
	var max_level = LEVELS.size()
	if current_level < max_level:
		await get_tree().create_timer(1.0).timeout
		await start_level(current_level + 1)
		score_label.text = "Level:"+ str(current_level) + "/" + str(max_level)
	else:
		gameover.set_state(true, 1)
		on_puzzle_ended()

func handle_fail():
	attempts -= 1
	attempts_label.text = "Attempts" + str(attempts)
	ball.visible = true
	await visible_cups[ball_index].raise_cup()
	if attempts <= 0:
		gameover.set_state(false, 0)
		on_puzzle_ended()
	else:
		retry()

func on_puzzle_ended():
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 2
	add_child(timer)
	timer.start()
	timer.timeout.connect(
		func(): 
			visible = false
			SceneTransition.return_spawn_marker = "Spawnpoint"
			SceneTransition.goto_minigame("res://Scenes/Maps_Scenes/14_IceCreamVendor.tscn", get_tree().current_scene.scene_file_path, "MinigameTrigger")
			)

func retry():
	await start_level(current_level)

func on_win(digit:int):
	gameover.set_state(true, digit)

func _on_game_over_on_retry() -> void:
	attempts = max_attempts
	await  start_level(1)

	
