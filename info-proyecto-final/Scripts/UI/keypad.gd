extends Control
class_name NumberKeypad

# signals
signal code_entered(code: String)

@export var num_digits: int = 5
@export var auto_submit_on_max: bool = true
@export var hide_entered_digits: bool = false 
@export var hide_delay: float = 0.5  

@onready var display_label: Label = $PanelContainer/VBoxContainer/PanelContainer/AScreen
@onready var grid_container: GridContainer = $PanelContainer/VBoxContainer/HBoxContainer/KeyContainer 
@onready var clear_button: Button = $PanelContainer/VBoxContainer/HBoxContainer/KeyContainer2/CLEAR
@onready var del_button: Button = $PanelContainer/VBoxContainer/HBoxContainer/KeyContainer2/DEL
@onready var enter_button: Button = $PanelContainer/VBoxContainer/HBoxContainer/KeyContainer2/ENTER

var current_code: String = ""
var digit_timer: Timer = null

func _ready():
	setup_buttons()
	setup_timer()
	update_display()

func setup_buttons():
	clear_button.pressed.connect(_on_clear_pressed)
	var clearLabel = clear_button.get_child(0).get_child(1)
	if clearLabel:
		clearLabel.text = "CLEAR"
	del_button.pressed.connect(_on_del_pressed)
	var del_buttonLabel = del_button.get_child(0).get_child(1)
	if del_buttonLabel:
		del_buttonLabel.text = "DEL"
	enter_button.pressed.connect(_on_enter_pressed)
	var enter_buttonLabel = enter_button.get_child(0).get_child(1)
	if enter_buttonLabel:
		enter_buttonLabel.text = "ENTER"
	for key in grid_container.get_children():
		key.pressed.connect(_on_number_button_pressed.bind(key))
		var label = key.get_child(0).get_child(1)
		if label:
			label.text = (key.name).right(1)

func setup_timer():
	digit_timer = Timer.new()
	digit_timer.wait_time = hide_delay
	digit_timer.one_shot = true
	digit_timer.timeout.connect(_on_hide_digit_timeout)
	add_child(digit_timer)

func _on_number_button_pressed(button: Control):
	var digit = ""
	if button is Button:
		digit = button.text
	else:
		return
	add_digit(digit)

func add_digit(digit: String):
	if digit.length() != 1:
		return
	if not digit.is_valid_int() and digit != ".":
		return
	if current_code.length() >= num_digits:
		return
	current_code += digit
	update_display()
	#if auto_submit_on_max and current_code.length() >= num_digits:
		#submit_code()
	

func remove_digit():
	if current_code.is_empty():
		return
	current_code = current_code.left(current_code.length() - 1)
	update_display()
	return true

func clear_code():
	if current_code.is_empty():
		return
	current_code = ""
	update_display()

func submit_code():
	if current_code.is_empty():
		return
	if current_code.length() < num_digits:
		print("ERROR Min Digits: ", num_digits)
		return 
	code_entered.emit(current_code)
	print("Code entered: ", current_code)
	clear_code()

func update_display():
	if not display_label:
		return
	var display_text = ""
	if hide_entered_digits:
		var visible_digits = current_code.length()
		for i in range(visible_digits):
			display_text += "•"
		if digit_timer and digit_timer.is_stopped() == false:
			if current_code.length() > 0:
				display_text = current_code.left(current_code.length() - 1)
				for i in range(display_text.length()):
					display_text[i] = "•"
				display_text += current_code[current_code.length() - 1]
			else:
				display_text = ""
	else:
		display_text = current_code
	
	if display_text.is_empty():
		for i in range(num_digits):
			display_text += " _ "
	display_label.text = display_text

func _on_hide_digit_timeout():
	update_display()

func _show_last_digit_temporarily():
	if hide_entered_digits and digit_timer:
		digit_timer.start()

func _on_clear_pressed():
	clear_code()

func _on_del_pressed():
	remove_digit()

func _on_enter_pressed():
	submit_code()

func reset():
	clear_code()
	update_display()
