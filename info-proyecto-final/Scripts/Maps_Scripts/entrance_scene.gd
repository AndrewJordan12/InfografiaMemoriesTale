extends "res://Scripts/Maps_Scripts/_base_scene.gd"

@onready var player: CharacterBody2D = $Player

func _ready() -> void:
	super._ready()
	_position_player()

func _position_player() -> void:
	if player == null:
		return
	var vp_size: Vector2 = get_viewport_rect().size
	match SceneTransition.spawn_point:
		"left":
			player.position = Vector2(100, vp_size.y / 2.0)
		"right":
			player.position = Vector2(vp_size.x - 100, vp_size.y / 2.0)
		"top":
			player.position = Vector2(vp_size.x / 2.0, 100)
		"bottom":
			player.position = Vector2(vp_size.x / 2.0, vp_size.y - 100)
		_:
			player.position = Vector2(vp_size.x / 2.0, vp_size.y / 2.0)
	SceneTransition.spawn_point = "center"
