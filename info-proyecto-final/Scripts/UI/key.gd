extends Button

@onready var label = $PanelContainer/Label
@onready var colorRect = $PanelContainer/ColorRect
@export var key_value : String = "7"
@export var is_num : bool = true

signal key_pressed(value:String)

var is_hoveredd := false
var is_pressedd := false
var is_active := false
var press_animation := 0.0
var is_clicked := false  


func _ready():
	colorRect.material = colorRect.material.duplicate()
	colorRect.material.set_shader_parameter("key_text", key_value)
	colorRect.material.set_shader_parameter("is_active", false)
	if label:
		label.text = key_value

func _process(delta):
	if is_pressedd:
		press_animation = min(press_animation + delta * 8.0, 1.0)
	else:
		press_animation = max(press_animation - delta * 6.0, 0.0)
	
	colorRect.material.set_shader_parameter("is_pressed", is_pressedd)
	colorRect.material.set_shader_parameter("press_animation", press_animation)

func _on_mouse_entered():
	is_hoveredd = true
	colorRect.material.set_shader_parameter("is_hovered", true)

func _on_mouse_exited():
	is_hoveredd = false
	colorRect.material.set_shader_parameter("is_hovered", false)

func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_pressedd = true
			is_clicked = true
		else:
			if is_clicked:  
				is_pressedd = false
				is_clicked = false
				if is_num:
					emit_signal("key_pressed", key_value)
				
				# Visual feedback
				colorRect.material.set_shader_parameter("is_active", true)
				await get_tree().create_timer(0.15).timeout
				colorRect.material.set_shader_parameter("is_active", false)

func set_active(active: bool):
	is_active = active
	colorRect.material.set_shader_parameter("is_active", active)
