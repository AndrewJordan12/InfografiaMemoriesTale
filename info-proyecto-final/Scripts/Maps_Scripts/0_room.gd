extends BaseMap

@onready var state = get_node("/root/State")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		State.show_keypad()


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		State.hide_keypad()
