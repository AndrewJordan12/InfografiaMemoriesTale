extends Button

@export var raise_height := 40.0
@export var raise_duration := 0.4
@export var swap_duration := 0.5

var start_position: Vector2
var is_raised := false

func _ready() -> void:
	start_position = position

func raise_cup():
	if is_raised:
		return
	is_raised = true
	var tween = create_tween()
	tween.tween_property(self,"position:y",start_position.y - raise_height,raise_duration)
	await tween.finished

func lower_cup():
	if !is_raised:
		return
	is_raised = false
	var tween = create_tween()
	tween.tween_property(self,"position:y",start_position.y,raise_duration)
	await tween.finished


func swap_with(other: Button):
	var my_pos = position
	var other_pos = other.position
	var tween = create_tween()
	tween.parallel().tween_property(self,"position",other_pos,swap_duration)
	tween.parallel().tween_property(other,"position",my_pos,swap_duration)
	await tween.finished
	update_start_position()
	if other.has_method("update_start_position"):
		other.update_start_position()

func update_start_position():
	start_position = position
