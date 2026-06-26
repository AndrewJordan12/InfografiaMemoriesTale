extends Area2D

@export var target_scene: String = ""
@export var trigger_name: String = ""
@onready var overlay_minigame= load(target_scene).instantiate()

	
func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		hide_overlay()
	
func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		show_overlay()

func show_overlay():
	if overlay_minigame == null:
		get_parent().add_child(overlay_minigame)
	else:
		get_parent().add_child(overlay_minigame)
	State.player = State.player_state.STANDING

func hide_overlay():
	print("Removing overla2y")
	if overlay_minigame != null and overlay_minigame.is_inside_tree():
		get_parent().remove_child(overlay_minigame)
		print("Removing overlay")
