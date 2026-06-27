extends Control

const MAX_LEVEL: int = 2
const FLASH_DURATION: float = 0.5
const FLASH_GAP: float = 0.3
const LOSSES_TO_SCREAMER: int = 3
const LOSSES_TO_FAIL: int = 6
const RECEIVER_ID: String = "13"

var current_level: int = 1
var sequence: Array = []
var player_index: int = 0
var is_playing_sequence: bool = false
var can_press: bool = false
var consecutive_losses: int = 0
var total_losses: int = 0
var has_won: bool = false
var digit: int = -1

@onready var buttons: Array = [
	$Buttons/Grid/Red,
	$Buttons/Grid/Green,
	$Buttons/Grid/Yellow,
	$Buttons/Grid/Blue
]
@onready var flash_overlays: Array = [
	$Buttons/Grid/Red/Flash,
	$Buttons/Grid/Green/Flash,
	$Buttons/Grid/Yellow/Flash,
	$Buttons/Grid/Blue/Flash
]
@onready var sounds: Array = [$sfx/Do, $sfx/Re, $sfx/Mi, $sfx/Fa]
@onready var level_label: Label = $Panel/VBox/LevelLabel
@onready var score_label: Label = $Panel/VBox/ScoreLabel
@onready var start_button: Button = $Panel/VBox/StartButton
@onready var screamer_image: TextureRect = $ScreamerLayer/ScreamerImage
@onready var screamer_black: ColorRect = $ScreamerLayer/BlackOverlay
@onready var screamer_sound: AudioStreamPlayer = $ScreamerLayer/ScreamerSound
@onready var fail_menu: CanvasLayer = $FailMenu
@onready var fail_label: Label = $FailMenu/Panel/VBox/FailLabel
@onready var btn_yes: Button = $FailMenu/Panel/VBox/BtnYes
@onready var btn_no: Button = $FailMenu/Panel/VBox/BtnNo

func _ready() -> void:
	digit = State.get_digit(RECEIVER_ID)
	_reset_ui()
	screamer_image.visible = false
	screamer_black.visible = false
	fail_menu.visible = false
	btn_yes.pressed.connect(_on_yes_pressed)
	btn_no.pressed.connect(_on_no_pressed)
	
	if SceneTransition.minigame_won and digit != -1:
		_show_won_state()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		if has_won:
			_return_to_map(true)

func _reset_ui() -> void:
	level_label.text = "Nivel: 1 / %d" % MAX_LEVEL
	score_label.text = "Presiona INICIAR"
	start_button.disabled = false
	_hide_all_flashes()

func _show_won_state() -> void:
	has_won = true
	start_button.disabled = true
	level_label.text = "Nivel: COMPLETADO"
	score_label.text = "COMPLETADO! NUMERO: " + str(digit) + "\nPRESIONA ESC PARA SALIR"

func _hide_all_flashes() -> void:
	for flash in flash_overlays:
		flash.visible = false

func _disable_buttons() -> void:
	for btn in buttons:
		btn.disabled = true

func _enable_buttons() -> void:
	for btn in buttons:
		btn.disabled = false

func _flash_button(index: int) -> void:
	flash_overlays[index].visible = true
	sounds[index].play()
	await get_tree().create_timer(FLASH_DURATION).timeout
	flash_overlays[index].visible = false
	await get_tree().create_timer(FLASH_GAP).timeout

func _on_start_pressed() -> void:
	current_level = 1
	sequence.clear()
	start_button.disabled = true
	_play_sequence()

func _play_sequence() -> void:
	is_playing_sequence = true
	can_press = false
	_disable_buttons()
	_hide_all_flashes()

	var flashes_per_color: int = current_level
	sequence.clear()
	for color_index in range(4):
		for _i in range(flashes_per_color):
			sequence.append(color_index)
	sequence.shuffle()

	level_label.text = "Nivel: %d / %d" % [current_level, MAX_LEVEL]
	score_label.text = "Observa..."

	await get_tree().create_timer(0.5).timeout

	for color_index in sequence:
		await _flash_button(color_index)

	player_index = 0
	is_playing_sequence = false
	can_press = true
	_enable_buttons()
	score_label.text = "Tu turno: 0 / %d" % sequence.size()

func _checkPlayerButton(button: int) -> void:
	if not can_press:
		return

	flash_overlays[button].visible = true
	sounds[button].play()
	await get_tree().create_timer(0.15).timeout
	flash_overlays[button].visible = false

	if sequence[player_index] == button:
		player_index += 1
		if player_index >= sequence.size():
			can_press = false
			_disable_buttons()
			consecutive_losses = 0
			score_label.text = "Correcto!"
			await get_tree().create_timer(1.0).timeout
			_next_level()
		else:
			score_label.text = "Tu turno: %d / %d" % [player_index, sequence.size()]
	else:
		_on_error()

func _next_level() -> void:
	if current_level < MAX_LEVEL:
		current_level += 1
		_play_sequence()
	else:
		has_won = true
		SceneTransition.minigame_won = true
		level_label.text = "Nivel: COMPLETADO"
		score_label.text = "COMPLETADO! NUMERO: " + str(digit) + "\nPRESIONA ESC PARA SALIR"
		start_button.disabled = true

func _on_error() -> void:
	can_press = false
	_disable_buttons()
	_hide_all_flashes()
	consecutive_losses += 1
	total_losses += 1
	$sfx/error.play()
	score_label.text = "Fallaste! Reiniciando..."
	await $sfx/error.finished

	if consecutive_losses >= LOSSES_TO_SCREAMER:
		consecutive_losses = 0
		await _play_screamer()

	if total_losses >= LOSSES_TO_FAIL:
		_show_fail_menu()
		return

	current_level = 1
	sequence.clear()
	_reset_ui()

func _show_fail_menu() -> void:
	can_press = false
	_disable_buttons()
	fail_label.text = "Volver a la normalidad?"
	fail_menu.visible = true

func _on_yes_pressed() -> void:
	fail_menu.visible = false
	_return_to_map(false)

func _on_no_pressed() -> void:
	fail_menu.visible = false
	current_level = 1
	sequence.clear()
	total_losses = 0
	_reset_ui()

func _return_to_map(trigger_won: bool) -> void:
	if SceneTransition.return_scene != "":
		if trigger_won:
			SceneTransition.minigame_won = true
		SceneTransition.return_from_minigame()
	else:
		_reset_ui()

func _play_screamer() -> void:
	screamer_black.visible = true
	screamer_image.visible = true

	var tex_size: Vector2 = screamer_image.texture.get_size()
	screamer_image.pivot_offset = tex_size / 2.0
	screamer_image.position = Vector2(576.0, 324.0) - (tex_size / 2.0)
	screamer_image.scale = Vector2.ZERO

	var max_scale_x: float = 1152.0 / tex_size.x
	var max_scale_y: float = 648.0 / tex_size.y
	var max_scale: float = min(max_scale_x, max_scale_y)

	screamer_sound.play()

	var expand_time: float = 0.4
	var tween: Tween = create_tween()
	tween.tween_property(screamer_image, "scale", Vector2(max_scale, max_scale), expand_time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)

	await screamer_sound.finished

	screamer_image.visible = false
	screamer_black.visible = false
