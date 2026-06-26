extends Node2D

signal on_retry

@onready var GOLabel:Label = $PopUp/Label
@onready var retry:Button = $PopUp/Retry

var win_msg :String = "YOU WON \nCODE: "
var lose_msg : String = "YOU LOST :("

func _ready() -> void:
	#GOLabel.visible = false
	#retry.visible = false
	visible = false
	
func set_state(value:bool, digit):
	visible = true
	if value == true:
		GOLabel.text = win_msg + str(digit)
		retry.disabled = true
		retry.visible = false
	else:
		GOLabel.text = lose_msg
		retry.disabled = false
		retry.visible = true

func _on_retry_pressed() -> void:
	on_retry.emit()
	visible = false
