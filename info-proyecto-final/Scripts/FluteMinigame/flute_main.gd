extends CanvasLayer

@onready var metronome_timer : Timer = $Metronome_Timer
@onready var countdown_timer : Timer = $Countdown_Timer
@onready var grid : Control = $Grid
@onready var rows : VBoxContainer = $Grid/Rows
@onready var beat_highlight : HBoxContainer = $Grid/CurrentNote
@onready var countdown_label : Label = $Countdown 

var loop_metronome = false
var track_manager = TrackManager.new()
var current_track_name: String = "example_track"  

var beat : int = 0
var partiture = []
var beat_current_notes = []

func _ready() -> void:
	metronome_timer.beat_tick.connect(_on_beat_tick)
	countdown_timer.timeout.connect(_on_countdown_tick)
	load_track()
	
func _process(_delta: float) -> void:
	##if(State.fluteState.PLAYING):
	if Input.is_action_just_pressed("test"):
		start_countdown()
	if Input.is_action_just_pressed("replay"):
		reset_and_restart()
	if State.flute_current_state == State.fluteState.PLAYING and get_input() != null:
		store_note(get_input())
	#grid.draw_partiture(partiture)

func _on_beat_tick():
	if not State.flute_current_state == State.fluteState.PLAYING:
		return  
	
	print("beat: ",beat)
	beat = (beat + 1) % grid.columns
	grid.update_beat_highlight(beat)
	beat_current_notes = []
	
	if beat == 0:
		check_win_condition()
		grid.clear_all_notes()
		grid.update_beat_highlight(-1)

#region input and adding nodes

func store_note(input : Note.type):
	if beat_current_notes.size() <= Note.type.size() and !beat_is_repeated(input):
		beat_current_notes.append(input)
		# Update the grid with the current beat's notes (replace, not append)
		print("Inserted in beat: ",beat)
		grid.add_beat_notes(beat, beat_current_notes)
		AudioManager.sfx_fluteminigame(enum_to_string(input))#sound according to input
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
#endregion

#region start/stop countdown handler
func start_playing():
	State.flute_current_state = State.fluteState.PLAYING
	toggle_metronome()
	grid.update_beat_highlight(beat)
	print("Playing started!")

func stop_playing():
	State.flute_current_state = State.fluteState.IDLE
	toggle_metronome()
	countdown_label.visible = false
	print("Playing stopped")

func start_countdown():
	print("clik")
	countdown_label.visible = true
	countdown_label.text = "3"
	countdown_timer.start()

func _on_countdown_tick():
	var current = int(countdown_label.text)
	current -= 1
	
	if current > 0:
		countdown_label.text = str(current)
	else:
		countdown_timer.stop()
		countdown_label.visible = false
		start_playing()
#endregion

#region UI controls
func close_UI():
	visible = false
#endregion

#region track

func load_track():
	if not track_manager.load_track(current_track_name):
		print("Failed to load track: ", current_track_name)
	
# Win condition
func check_win_condition():
	var grid_notes = grid.get_all_notes() 
	
	if track_manager.compare_track(grid_notes):
		print("WINNER!")
		on_win()
	else:
		print("YOU MISSED HSAHHA")
		on_lose()

func on_win():
	stop_playing()
	countdown_label.text = "🎉"
	countdown_label.visible = true

func on_lose():
	stop_playing()
	print_player_notes()
	countdown_label.text = "❌"
	countdown_label.visible = true

func reset_and_restart():
	beat = 0
	grid.clear_all_notes()
	grid.update_beat_highlight(-1)
	beat_current_notes = []
	countdown_label.visible = false
	start_countdown()
#endregion

#region helper functions
func enum_to_string(type: Note.type) -> String:
	return Note.type.keys()[type]
	
func toggle_metronome():
	loop_metronome = !loop_metronome
	if metronome_timer.is_stopped():
		metronome_timer.one_shot = !loop_metronome  # If loop is false, one_shot should be true
		metronome_timer.start()
		print("Loop: ", loop_metronome)
	else:
		metronome_timer.stop()

# Add this function to print the player's notes
func print_player_notes():
	var json_string = grid.get_notes_as_json()
	print("=== Player Notes ===\n")
	print(json_string)
	print("\n=== End of Player Notes ===")
#endregion
