extends Control

@onready var sprite_animated: AnimatedSprite2D = $AnimatedSprite2D
@onready var glitch_overlay: ColorRect = $GlitchOverlay
@onready var scanlines: ColorRect = $Scanlines
@onready var loading_label: Label = $LoadingLabel

var glitch_timer: float = 0.0
var glitch_interval: float = 0.15
var scanline_timer: float = 0.0
var flicker_timer: float = 0.0
var glitch_active: bool = false

var glitch_colors: Array[Color] = [
	Color(0.0, 1.0, 0.3, 0.08),
	Color(0.3, 0.0, 1.0, 0.06),
	Color(1.0, 0.0, 0.5, 0.07),
	Color(0.0, 0.8, 1.0, 0.05),
	Color(1.0, 0.2, 0.0, 0.04),
]

func _ready() -> void:
	sprite_animated.play("default")
	_process_glitch()
	_update_scanlines()
	if SceneTransition.target_scene != "":
		get_tree().create_timer(1.5).timeout.connect(_on_load_complete)

func _process(delta: float) -> void:
	glitch_timer += delta
	scanline_timer += delta
	flicker_timer += delta

	if glitch_timer >= glitch_interval:
		glitch_timer = 0.0
		glitch_interval = randf_range(0.08, 0.4)
		_process_glitch()

	if scanline_timer >= 0.1:
		scanline_timer = 0.0
		_update_scanlines()

	if flicker_timer >= 0.05:
		flicker_timer = 0.0
		_process_flicker()

func _process_glitch() -> void:
	glitch_active = randf() > 0.4
	if glitch_active:
		var chosen_color: Color = glitch_colors[randi() % glitch_colors.size()]
		chosen_color.a = randf_range(0.02, 0.1)
		glitch_overlay.color = chosen_color
		glitch_overlay.visible = true
		glitch_overlay.position = Vector2(
			randf_range(-100, 500),
			randf_range(0, 600)
		)
		glitch_overlay.size = Vector2(
			randf_range(200, 800),
			randf_range(2, 12)
		)
	else:
		glitch_overlay.visible = false

func _update_scanlines() -> void:
	scanlines.color = Color(0, 0, 0, randf_range(0.02, 0.06))

func _process_flicker() -> void:
	if randf() > 0.85:
		loading_label.modulate.a = randf_range(0.3, 1.0)
	else:
		loading_label.modulate.a = 1.0

func _on_load_complete() -> void:
	get_tree().change_scene_to_file(SceneTransition.target_scene)
	SceneTransition.target_scene = ""
