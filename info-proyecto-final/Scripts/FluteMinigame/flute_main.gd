extends CanvasLayer

@onready var metronome_timer : Timer = $Metronome_Timer
@onready var grid : Control = $Grid
@onready var rows : VBoxContainer = $Grid/Rows
@onready var beat_highlight : HBoxContainer = $Grid/CurrentNote

var loop_metronome = false

var beat : int = 0
var partiture = []
var beat_current_notes = []

func _ready() -> void:
	metronome_timer.beat_tick.connect(_on_beat_tick)

	
func _process(delta: float) -> void:
	##if(State.fluteState.PLAYING):
	if get_input() != null:
		store_note(get_input())
	#grid.draw_partiture(partiture)

func store_note(input : Note.type):
	if beat_current_notes.size() <= Note.type.size() and !beat_is_repeated(input):
		beat_current_notes.append(input)
		# Update the grid with the current beat's notes (replace, not append)
		grid.add_beat_notes(beat, beat_current_notes)
	else:
		print("Duplicate or full")

func beat_is_repeated(new_note : Note.type):
	for note in beat_current_notes:
		if grid.get_note_type_for_row(note) == new_note: 
			return true
	return false

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
		return Note.type.SPACE
	if Input.is_action_just_pressed("test"):
		reset_track()
		
func close_UI():
	visible = false

func _on_beat_tick():
	print("beat= ", beat)
	beat = (beat + 1) % grid.columns
	grid.update_beat_highlight(beat)
	beat_current_notes = []
	if beat == 0:
		grid.clear_all_notes()
		
func toggle_metronome():
	loop_metronome = !loop_metronome
	if metronome_timer.is_stopped():
		metronome_timer.one_shot = !loop_metronome  # If loop is false, one_shot should be true
		metronome_timer.start()
		print("Loop: ", loop_metronome)
	else:
		metronome_timer.stop()
		
func reset_track():
	toggle_metronome()
