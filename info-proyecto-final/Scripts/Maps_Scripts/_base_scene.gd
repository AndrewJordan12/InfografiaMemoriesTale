extends Node2D

func _ready() -> void:
	_position_player()

func _position_player() -> void:
	var player = get_node_or_null("Player")
	if player == null:
		return
	if SceneTransition.spawn_trigger == "":
		return
	var trigger = get_node_or_null(SceneTransition.spawn_trigger)
	if trigger == null:
		return
	var vp: Vector2 = get_viewport_rect().size
	var pos: Vector2 = trigger.position + Vector2(60, 0)
	pos.x = clampf(pos.x, 50, vp.x - 50)
	pos.y = clampf(pos.y, 50, vp.y - 50)
	player.position = pos
	SceneTransition.spawn_trigger = ""
