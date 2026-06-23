extends Control
class_name NumberKeypad
# signals
signal code_entered(code: String)

@export var num_digits: int = 5
@export var auto_submit_on_max: bool = false
@export var hide_entered_digits: bool = false 
@export var hide_delay: float = 0.5  

@onready var display_label: Label = $PanelContainer/VBoxContainer/PanelContainer/AScreen
@onready var grid_container: GridContainer = $PanelContainer/VBoxContainer/HBoxContainer/KeyContainer 
@onready var clear_button: Button = $PanelContainer/VBoxContainer/HBoxContainer/KeyContainer2/CLEAR
@onready var del_button: Button = $PanelContainer/VBoxContainer/HBoxContainer/KeyContainer2/DEL
@onready var enter_button: Button = $PanelContainer/VBoxContainer/HBoxContainer/KeyContainer2/ENTER

var current_code: String = ""
var digit_timer: Timer = null
var last_digit: String = ""  

func _ready():
	setup_buttons()
	setup_timer()
	update_display()

func setup_buttons():
	for key in grid_container.get_children():
		key.key_pressed.connect(_on_key_pressed)

func setup_timer():
	digit_timer = Timer.new()
	digit_timer.wait_time = hide_delay
	digit_timer.one_shot = true
	digit_timer.timeout.connect(_on_hide_digit_timeout)
	add_child(digit_timer)

func add_digit(digit: String):
	if digit.length() != 1:
		return
	if not digit.is_valid_int():
		return
	if current_code.length() >= num_digits:
		return
	last_digit = digit
	current_code += digit
	update_display()
	if hide_entered_digits:
		digit_timer.start()
	
	if auto_submit_on_max and current_code.length() >= num_digits:
		submit_code()

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
	last_digit = ""
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
		var visible_count = current_code.length()
		if digit_timer and digit_timer.is_stopped() == false and visible_count > 0:
			for i in range(visible_count - 1):
				display_text += "•"
			display_text += current_code[visible_count - 1]
		else:
			for i in range(visible_count):
				display_text += "•"
	else:
		display_text = current_code
	if display_text.is_empty():
		display_text = ""
		for i in range(num_digits):
			display_text += " _ "
	
	display_label.text = display_text

func _on_hide_digit_timeout():
	update_display()

func _on_clear_pressed():
	clear_code()

func _on_del_pressed():
	remove_digit()

func _on_enter_pressed():
	print("HOLA")
	submit_code()

func reset():
	clear_code()
	update_display()

func _on_key_pressed(value: String) -> void:
	add_digit(value)
