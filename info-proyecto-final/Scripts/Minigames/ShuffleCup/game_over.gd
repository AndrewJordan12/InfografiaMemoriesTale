extends Node2D

signal on_retry
signal on_X

@onready var GOLabel:Label = $PopUp/Label
@onready var retry:Button = $PopUp/Retry
@onready var X:Button = $X

var win_msg :String = "YOU WON \nCODE: "
var lose_msg : String = "YOU LOST :("

func _ready() -> void:
	GOLabel.visible = false
	retry.visible = false
	X.visible = false
	
func set_state(value:bool, digit):
	if value == true:
		GOLabel.text = win_msg + str(digit)
		retry.disabled = true
		retry.visible = false
	else:
		GOLabel.text = lose_msg
		retry.disabled = false
		retry.visible = true


func _on_x_pressed() -> void:
	on_X.emit()


func _on_retry_pressed() -> void:
	on_retry.emit()
