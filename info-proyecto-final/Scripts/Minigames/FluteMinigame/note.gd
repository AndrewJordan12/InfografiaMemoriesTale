extends TextureRect
class_name Note

@export var sprite_up : Texture2D
@export var sprite_down : Texture2D
@export var sprite_left : Texture2D
@export var sprite_right : Texture2D
@export var sprite_space : Texture2D

enum type {LEFT, RIGHT, UP, DOWN, SPACE}

var note_type: type = type.LEFT #default
var fresh: bool = false

func _ready() -> void:
	set_note_value()

func set_note_value():
	match note_type: 
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

func change_type(new_type: type):
	note_type = new_type
	set_note_value()  # Update the texture

func show_note_animated(duration: float = 0.3):
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, duration * 0.5)
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), duration * 0.3)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), duration * 0.2)
