extends Node

var available_ids = [
	"3","4",
	#"5","6","7",
	"8","9","10","11","12","13","14"
]

var assigned_ids := {}

var code_length := 4
var secret_code: Array[int] = []

func _ready():
	generate_puzzle()

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
