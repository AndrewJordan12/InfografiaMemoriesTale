extends Node
class_name TrackManager

# Track data structure: {beat: {row_index: note_type}}
var current_track: Dictionary = {}
var track_name: String = ""
var file_path = "res://Scripts/Minigames/FluteMinigame/Tracks/"

# Load a track from a JSON file
func load_track(track_name: String) -> bool:
	file_path += track_name + ".json"
	
	if not FileAccess.file_exists(file_path):
		print("Track not found: ", file_path)
		return false
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		print("Error parsing JSON: ", json.get_error_message())
		return false
	
	var data = json.data
	current_track = {}
	
	# Convert JSON data to note_references format
	json_to_dictionary(data)
	
	self.track_name = track_name
	print("Track loaded: ", track_name)
	return true

# Compare current grid notes with the loaded track
func compare_track(grid_notes: Dictionary) -> bool:
	# Check if both have the same beats
	if grid_notes.keys().size() != current_track.keys().size():
		print("Beat count mismatch: ", grid_notes.keys().size(), " vs ", current_track.keys().size())
		return false
	
	for beat in current_track:
		if not grid_notes.has(beat):
			print("Beat missing: ", beat)
			return false
		
		if grid_notes[beat].keys().size() != current_track[beat].keys().size():
			print("Note count mismatch at beat ", beat)
			return false
		
		for row in current_track[beat]:
			if not grid_notes[beat].has(row):
				print("Row missing at beat ", beat, " row ", row)
				return false
			
			if grid_notes[beat][row] != current_track[beat][row]:
				print("Note type mismatch at beat ", beat, " row ", row)
				return false
	
	print("Track matches!")
	return true

# Convert JSON data to note_references format
func json_to_dictionary(data):
	for beat_str in data:
		var beat = int(beat_str)
		current_track[beat] = {}
		
		for row_str in data[beat_str]:
			var row = int(row_str)
			var note_type_str = data[beat_str][row_str]
			var note_type = Note.type[note_type_str]  # Convert string to enum
			current_track[beat][row] = note_type
