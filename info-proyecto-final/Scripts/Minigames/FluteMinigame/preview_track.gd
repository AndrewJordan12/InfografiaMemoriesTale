extends Node
class_name PreviewManager

# Reference to grid for visual updates
var grid: Control
var track_manager: TrackManager
var total_beats: int = 11
var current_beat: int = 0
var is_previewing: bool = false
var preview_complete_callback: Callable

# Opacity levels
const FUTURE_NOTE_OPACITY: float = 0.3
const FULL_OPACITY: float = 1.0
const HIDDEN_OPACITY: float = 0.0

# Track the notes that have been shown
var shown_beats: Array = []

func initialize(grid_ref: Control, track_ref: TrackManager, beat_count: int):
	grid = grid_ref
	track_manager = track_ref
	total_beats = beat_count

# Start preview mode
func start_preview(callback: Callable = Callable()) -> bool:
	if not track_manager or track_manager.current_track.is_empty():
		print("Preview: No track loaded")
		return false
	
	# Store the callback
	preview_complete_callback = callback
	
	is_previewing = true
	current_beat = 0
	shown_beats = []
	
	# Clear the grid first
	grid.hide_all_notes()
	
	# Show all track notes at low opacity (preview all notes)
	show_future_notes(-1)  # -1 means show all notes
	
	print("Preview started")
	return true

# Call this on each beat tick
func on_beat_tick(beat: int):
	if not is_previewing:
		return
	
	current_beat = beat
	
	# Show the current beat notes with animation
	show_beat_notes(beat)
	
	# Update future notes (hide notes that are now past)
	show_future_notes(beat)
	
	# Mark this beat as shown
	if beat not in shown_beats:
		shown_beats.append(beat)
	
	print("Preview beat: ", beat)
	
	# Check if preview is complete (we've shown all beats)
	if beat >= total_beats - 1:
		complete_preview()

# Show notes for a specific beat with animation
func show_beat_notes(beat: int):
	var track_notes = get_beat_notes_from_track(beat)
	
	for note_type in track_notes:
		var row_index = grid.get_row_index_for_note_type(note_type)
		if row_index != -1 and beat < grid.columns:
			var row = grid.rows.get_child(row_index)
			if beat < row.get_child_count():
				var note_node = row.get_child(beat)
				if note_node is Note:
					# Reset scale and show with animation
					note_node.scale = Vector2(1.0, 1.0)
					grid.show_note_animated(note_node)

# Show all future notes at low opacity
func show_future_notes(current_beat: int):
	# First hide all notes
	grid.hide_all_notes()
	
	# Then show track notes
	var track = track_manager.current_track
	
	for beat in track:
		var should_be_full = false
		
		# Check if this beat has been shown (past beats)
		if beat in shown_beats or beat < current_beat:
			should_be_full = true
		
		# Check if this is the current beat (being played now)
		if beat == current_beat:
			should_be_full = true
		
		for row_index in track[beat]:
			var note_type = track[beat][row_index]
			if beat < grid.columns:
				var row = grid.rows.get_child(row_index)
				if beat < row.get_child_count():
					var note_node = row.get_child(beat)
					if note_node is Note:
						if should_be_full:
							note_node.modulate.a = FULL_OPACITY
						else:
							# Future note - low opacity
							note_node.modulate.a = FUTURE_NOTE_OPACITY

# Get notes from track for a specific beat
func get_beat_notes_from_track(beat: int) -> Array:
	var result = []
	var track = track_manager.current_track
	
	if track.has(beat):
		for row_index in track[beat]:
			result.append(track[beat][row_index])
	
	return result

# Get the maximum beat in the track
func get_max_track_beat() -> int:
	var max_beat = 0
	var track = track_manager.current_track
	
	for beat in track:
		if beat > max_beat:
			max_beat = beat
	
	return max_beat

# Complete preview
func complete_preview():
	is_previewing = false
	print("Preview complete!")
	
	# Show all notes at full opacity for a moment
	show_all_track_notes()
	
	# Call the callback if set
	if preview_complete_callback.is_valid():
		preview_complete_callback.call()

# Show all track notes at full opacity
func show_all_track_notes():
	grid.hide_all_notes()
	
	var track = track_manager.current_track
	
	for beat in track:
		for row_index in track[beat]:
			var note_type = track[beat][row_index]
			if beat < grid.columns:
				var row = grid.rows.get_child(row_index)
				if beat < row.get_child_count():
					var note_node = row.get_child(beat)
					if note_node is Note:
						note_node.modulate.a = FULL_OPACITY
						note_node.scale = Vector2(1.0, 1.0)

# Clean up preview state
func stop_preview():
	is_previewing = false
	shown_beats = []
	current_beat = 0
	preview_complete_callback = Callable()  # Clear callback
	grid.hide_all_notes()
	print("Preview stopped")

# Check if preview is running
func is_running() -> bool:
	return is_previewing
