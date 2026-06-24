extends CanvasLayer

@onready var note = preload("res://Scenes/UI/FluteMinigame/MusicalNote.tscn")
@onready var metronome_timer : Timer = $Metronome_Timer
@onready var grid : Control = $Grid
@onready var rows : VBoxContainer = $Grid/Rows
@onready var beat_highlight : HBoxContainer = $Grid/CurrentNote

var loop_metronome = false

var beat : int = 0
var partiture = []

func _ready() -> void:
	metronome_timer.beat_tick.connect(_on_beat_tick)

func _process(delta: float) -> void:
	get_input()

func get_input():
	if Input.is_action_just_pressed("walk_up"):
		return Note.type.UP
	if Input.is_action_just_pressed("walk_down"):
		return Note.type.DOWN
	if Input.is_action_just_pressed("walk_left"):
		return Note.type.LEFT
	if Input.is_action_just_pressed("walk_right"):
		return Note.type.RIGHT
	if Input.is_action_just_pressed("interact"):
		toggle_metronome()
		return Note.type.SPACE
		
func close_UI():
	visible = false

func _on_beat_tick():
	print("beat= ", beat)
	grid.update_beat_highlight(beat)
	beat = (beat + 1) % grid.columns
	
func toggle_metronome():
	loop_metronome = !loop_metronome
	if metronome_timer.is_stopped():
		metronome_timer.one_shot = !loop_metronome  # If loop is false, one_shot should be true
		metronome_timer.start()
		print("Loop: ", loop_metronome)
	else:
		metronome_timer.stop()
		

	
