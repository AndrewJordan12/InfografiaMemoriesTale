extends CanvasLayer

@onready var metronome_timer : Timer = $Metronome_Timer
@onready var countdown_timer : Timer = $Countdown_Timer
@onready var grid : Control = $Grid
@onready var rows : VBoxContainer = $Grid/Rows
@onready var beat_highlight : HBoxContainer = $Grid/CurrentNote
@onready var countdown_label : Label = $Countdown 
@onready var instructions_label : Label = $Instructions 

var loop_metronome = false
var track_manager = TrackManager.new()
var current_track_name: String = "0"  

var beat : int = 0
var partiture = []
var beat_current_notes = []
var preview_active: bool = false
var countdown_active : bool = false

func _ready() -> void:
	metronome_timer.beat_tick.connect(_on_beat_tick)
	countdown_timer.timeout.connect(_on_countdown_tick)
	load_track(current_track_name)
	grid.setup_preview_manager(track_manager)
	
func _process(_delta: float) -> void:
	##if(State.fluteState.PLAYING):
	if State.flute_current_state == State.fluteState.WIN:
		on_completed_minigame()
	if !countdown_active:
		if Input.is_action_just_pressed("interact"):
			if (State.flute_current_state == State.fluteState.IDLE and State.player != State.player_state.WALKING):
				reset_and_restart()
		if Input.is_action_just_pressed("esc"):
			if (State.flute_current_state != State.fluteState.PLAYING):
				close_overlay()
		if State.flute_current_state == State.fluteState.PLAYING and get_input() != null:
			store_note(get_input())
	#grid.draw_partiture(partiture)

func _on_beat_tick():
	
	if State.flute_current_state == State.fluteState.PREVIEW:
		if grid.is_preview_running():
			grid.preview_beat_tick(beat)
		
		grid.update_beat_highlight(beat)
		beat = (beat + 1) % grid.columns
		return
	
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
		grid.add_beat_notes(beat, beat_current_notes)
		AudioManager.sfx_fluteminigame(enum_to_string(input))#sound according to input

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
	countdown_active = false
	toggle_metronome()
	grid.update_beat_highlight(beat)

func stop_playing():
	State.flute_current_state = State.fluteState.IDLE
	toggle_metronome()
	grid.set_show_future_notes(false)
	countdown_label.visible = false
	instructions_label.visible = true
	instructions_label.text = "PRESS SPACE TO CONTINUE (" + str(int(current_track_name)+1) + "/3)"

func start_countdown():
	grid.set_show_future_notes(true)
	countdown_active = true
	instructions_label.visible = false
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
		
		if State.flute_current_state == State.fluteState.PREVIEW:
			start_preview_playing()
		else:
			start_playing()
#endregion

#region UI controls

func close_overlay():
	if State.flute_current_state != State.fluteState.PLAYING || State.flute_current_state != State.fluteState.PREVIEW:
		if State.player != State.player_state.WALKING:
			var parent = get_parent()
			if parent:
				var trigger = parent.get_node_or_null("MinigameTrigger")
				print(trigger)
				print(trigger.name)
				print(trigger.trigger_name)
				if trigger and trigger.trigger_name == name:
					trigger.hide_overlay()
			State.player = State.player_state.WALKING
#endregion

#region track

func load_track(new_track: String):
	current_track_name = new_track
	if not track_manager.load_track(current_track_name):
		print("Failed to load track: ", current_track_name)
	
# Win condition
func check_win_condition():
	var grid_notes = grid.get_all_notes() 
	
	if track_manager.compare_track(grid_notes):
		on_win()
	else:
		on_lose()

func on_win():
	stop_playing()
	countdown_label.visible = false
	if current_track_name == "0":
		load_track("1")
		return
	if current_track_name == "1":
		load_track("2")
		return
	if current_track_name == "2":
		on_completed_minigame()
		return
		
func on_completed_minigame():
	instructions_label.text = "COMPLETE! (3/3) NUMBER IS : " + State.display_digit_in_scene("13")+ "\n PRESS ESC TO EXIT"
	State.flute_current_state = State.fluteState.WIN
		
func on_lose():
	stop_playing()
	instructions_label.text = "PRESS SPACE TO RETRY (" + str(int(current_track_name)+1) + "/3) \n PRESS ESC TO EXIT"

func reset_and_restart():
	beat = 0
	grid.clear_all_notes()
	grid.update_beat_highlight(-1)
	beat_current_notes = []
	countdown_label.visible = false
	start_countdown()
	
#endregion

#region preview
func start_preview():
	if track_manager.current_track.is_empty():
		print("No track to preview")
		return
	
	State.flute_current_state = State.fluteState.PREVIEW
	preview_active = true
	beat = 0
	grid.update_beat_highlight(-1)
	
	# Start preview with callback
	if grid.start_preview(Callable(self, "_on_preview_complete")):
		countdown_label.visible = true
		countdown_label.text = "3"
		countdown_timer.start()

func _on_preview_complete():
	# Returns to IDLE afterpreview
	grid.update_beat_highlight(-1)
	toggle_metronome()
	State.flute_current_state = State.fluteState.IDLE
	preview_active = false
	grid.stop_preview()
	countdown_label.visible = false

func start_preview_playing():
	toggle_metronome()
	beat = 0
#endregion

#region helper functions
func enum_to_string(type: Note.type) -> String:
	return Note.type.keys()[type]
	
func toggle_metronome():
	loop_metronome = !loop_metronome
	if metronome_timer.is_stopped():
		metronome_timer.one_shot = !loop_metronome
		metronome_timer.start()
		print("Loop: ", loop_metronome)
	else:
		metronome_timer.stop()

# used it to check if win condition is correct
func _print_player_notes():
	var json_string = grid.get_notes_as_json()
	print("=== Player Notes ===\n")
	print(json_string)
	print("\n=== End of Player Notes ===")
#endregion
