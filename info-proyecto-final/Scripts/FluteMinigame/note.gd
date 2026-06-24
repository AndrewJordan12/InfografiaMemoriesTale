extends TextureRect
class_name Note

@export var sprite_up : Texture2D
@export var sprite_down : Texture2D
@export var sprite_left : Texture2D
@export var sprite_right : Texture2D
@export var sprite_space : Texture2D

enum type {LEFT, RIGHT, UP, DOWN, SPACE}

func _ready() -> void:
	if type:
		set_note_value()
	else:
		print("Your note doesnt have type...wait. What.")

func set_note_value():
	match type:
		type.UP:
			texture = sprite_up
		type.DOWN:
			texture = sprite_down
		type.LEFT:
			texture = sprite_left
		type.RIGHT:
			texture = sprite_right
		type.SPACE:
			texture = sprite_space
