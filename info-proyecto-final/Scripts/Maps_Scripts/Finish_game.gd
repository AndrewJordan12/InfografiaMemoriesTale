extends Area2D

@onready var rect = get_parent().get_node("FinishUtils/ColorRect")
@onready var label : Label = get_parent().get_node("FinishUtils/Label")
@onready var buttonExit : Button = get_parent().get_node("ButtonExit")

func _ready():
	var tween = create_tween()
	tween.tween_property(rect, "modulate:a", 0.0, 6)
	if State.won_status:
			label.text = "YOU WON"
	else:
			label.text = "YOU LOST"
	
	
func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		State.player = State.player_state.STANDING
		var sprite = body.get_node("AnimatedSprite2D")
		body.get_node("AnimatedSprite2D").play("walk_back")
		var tween = create_tween()
		tween.tween_property(sprite, "modulate:a", 0.0, 3)
		await get_tree().create_timer(3.5).timeout
		body.queue_free()
		label.visible = true
		buttonExit.visible = true
		buttonExit.disabled = false


func _on_button_button_up() -> void:
	get_tree().quit()
