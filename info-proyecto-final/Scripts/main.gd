extends Node

var available_ids = [
	"3","4",
	#"5","6","7",
	"8","9","10","11","12","13","14"
]

var assigned_ids := {}
var code_length := 4
var secret_code: Array[int] = []
var max_retries: int = 3
var retries : int = 0

var keypad_scene = preload("res://Scenes/UI/Keypad.tscn")
var keypad_instance 
var ui_layer:CanvasLayer

#fluteminigame
enum fluteState {PLAYING, PREVIEW, IDLE}
var flute_current_state : fluteState = fluteState.IDLE

func _ready():
	generate_puzzle()
	init_ui()

func init_ui():
	ui_layer = CanvasLayer.new()
	ui_layer.layer = 100
	get_tree().root.add_child.call_deferred(ui_layer)
	keypad_instance = keypad_scene.instantiate()
	ui_layer.add_child.call_deferred(keypad_instance)
	keypad_instance.visible = false
	
#region code generation and validation

func generate_puzzle():
	secret_code.clear()
	assigned_ids.clear()

	for i in range(code_length):
		secret_code.append(randi_range(0, 9))

	var shuffled = available_ids.duplicate()
	shuffled.shuffle()
	var selected_ids = shuffled.slice(0, code_length)

	for i in range(code_length):
		assigned_ids[selected_ids[i]] = secret_code[i]

	print("Code:", secret_code)
	print("Assignments:", assigned_ids)
	
func get_digit(receiver_id: String) -> int:
	return assigned_ids.get(receiver_id, -1)
	
func get_code_lenght() -> int:
	return code_length
	
func validate_code(code:String) -> bool:
	if code.length() != code_length:
		return false
	retries += 1
	
	var scode = "" 
	for digit in secret_code:
		scode += str(digit)
	if code == scode:
		on_won()
		return true
	if retries >= max_retries:
		on_failed()
	return false
	
func show_keypad():
	keypad_instance.visible = true
	
func hide_keypad():
	keypad_instance.visible = false
#endregion

func on_failed():
	print("Failed")
	
func on_won():
	print("WON")

#Flute minigame
#region fluteminigame
func flute_start():
	flute_current_state = fluteState.PLAYING
	
func flute_stop():
	flute_current_state = fluteState.PLAYING
	
func flute_exit():
	flute_current_state = fluteState.PLAYING
#endregion
