extends Area2D

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		var trigger = get_parent()
		if trigger and trigger.has_method("_get_destination_text"):
			body.bubble_text = trigger._get_destination_text()

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		body.bubble_text = ""
