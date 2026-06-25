extends Control
@onready var note_scene = preload("res://Scenes/UI/FluteMinigame/Note.tscn")
@onready var rows : VBoxContainer = $Rows
@onready var beat_highlight : HBoxContainer = $CurrentNote
@onready var beat_highlight_template = $CurrentNote/Highlight_Template

@export var columns = 11 #this is for the highlights, the max and planned amount of actual notes is 11, though not impossible to make it adjustable
var note_references: Dictionary = {}
var last_updated_beat: int = -1

func _ready() -> void:
	create_highlights() #creates appropiate amount of highlights
	update_beat_highlight(-1) #hides all already placed highlights by default
	create_notes() # #Clears notes in the scene and fills the grid with invisible notes
	
#region create and clear notes
#Clears notes in the scene and fills the grid with invisible notes
func create_notes():
	clear_existing_notes()
	note_references.clear()
	
	for row_index in range(rows.get_child_count()):
		var row = rows.get_child(row_index)
		var note_type = get_note_type_for_row(row_index)
		
		for col_index in range(columns):
			var new_note = create_note_instance(note_type)
			row.add_child(new_note)
			new_note.modulate.a = 0.0 

# Clear existing notes from all rows
func clear_existing_notes():
	for row_index in range(rows.get_child_count()):
		var row = rows.get_child(row_index)
		
		# Remove all existing Note children
		for child in row.get_children():
			if child is Note:
				row.remove_child(child)
				child.queue_free()

# Create a new Note instance of a specific type
func create_note_instance(note_type: Note.type) -> Note:
	var new_note = note_scene.instantiate()
	new_note.change_type(note_type)
	new_note.modulate.a = 1.0
	return new_note

# Recieves the input of a note and adds it to the note_reference
func add_beat_notes(beat: int, notes: Array):
	# Clear and add new notes for this beat
	if not note_references.has(beat):
		note_references[beat] = {}
	
	for note_type in notes:
		var row_index = get_row_index_for_note_type(note_type)
		if row_index != -1:
			note_references[beat][row_index] = note_type
	
	last_updated_beat = beat
	update_grid_display()

#endregion

#region draw current grid
#the function that updated the partiture
func update_grid_display():
	hide_all_notes() #puts all notes in alpha 0.0
	
	for beat_index in note_references:
		for row_index in note_references[beat_index]:
			var note_type = note_references[beat_index][row_index]
			var is_new = (beat_index == last_updated_beat)  # Only animate the just-updated beat
			show_note_at_position(note_type, beat_index, is_new)

# Show a specific note at a position
func show_note_at_position(note_type: Note.type, position_index: int, animate: bool = true):
	var row_index = get_row_index_for_note_type(note_type)
	if row_index == -1:
		return
	
	var row = rows.get_child(row_index)
	if position_index < row.get_child_count():
		var note_node = row.get_child(position_index)
		if note_node is Note:
			note_node.scale = Vector2(1.0, 1.0)  # Reset scale
			
			if animate:
				show_note_animated(note_node)
			else:
				note_node.modulate.a = 1.0		

# Animated function to show a note
func show_note_animated(note_node: Node, duration: float = 0.3):
	# Bounce effect
	var tween = create_tween()
	tween.tween_property(note_node, "modulate:a", 1.0, duration * 0.5)
	tween.tween_property(note_node, "scale", Vector2(1.2, 1.2), duration * 0.3)
	tween.tween_property(note_node, "scale", Vector2(1.0, 1.0), duration * 0.2)

#clears references and hides all notes
func clear_all_notes():
	note_references.clear()
	hide_all_notes()

# puts all notes in the partiture to alpha 0
func hide_all_notes():
	for row_index in range(rows.get_child_count()):
		var row = rows.get_child(row_index)
		for col_index in range(row.get_child_count()):
			var note = row.get_child(col_index)
			if note is Note:
				note.modulate.a = 0.0

#endregion
	
#region highlight
func create_highlights():
	# Clear existing copies (initially present for easier time making/undersatinding scene)
	for child in beat_highlight.get_children():
		if child != beat_highlight_template:
			child.queue_free()

	# Create n-1 copies (since template already exists)
	for i in range(columns - 1):
		var copy = beat_highlight_template.duplicate()
		beat_highlight.add_child(copy)

func update_beat_highlight(beat: int):
	var rects = beat_highlight.get_children()
	# Loop through all rects
	for i in range(rects.size()):
		var rect = rects[i]
		rect.modulate.a = 0.0
	if beat == -1: #for the onready
		return
	# Show only the selected one (if index is valid)
	if beat >= 0 and beat < rects.size():
		rects[beat].modulate.a = 0.4
		AudioManager.sfx_fluteminigame("beat_change")
#endregion

#region helper methods
				
func get_row_index_for_note_type(note_type: Note.type) -> int:
	match note_type:
		Note.type.LEFT:
			return 0  # Row1
		Note.type.UP:
			return 1  # Row2
		Note.type.RIGHT:
			return 2  # Row3
		Note.type.DOWN:
			return 3  # Row4
		Note.type.SPACE:
			return 4  # Row5
		_:
			return -1
			
# Get the Note type for a specific row
func get_note_type_for_row(row_index: int) -> Note.type:
	match row_index:
		0:
			return Note.type.LEFT
		1:
			return Note.type.UP
		2:
			return Note.type.RIGHT
		3:
			return Note.type.DOWN
		4:
			return Note.type.SPACE
		_:
			return Note.type.SPACE  # Default
			
func get_notes_as_json() -> String:
	var data = {}
	
	for beat in note_references:
		var beat_str = str(beat)
		data[beat_str] = {}
		
		for row in note_references[beat]:
			var note_type = note_references[beat][row]
			var note_type_str = Note.type.keys()[note_type]
			data[beat_str][str(row)] = note_type_str
	
	var json_string = JSON.stringify(data, "\t")
	return json_string
#endregion

# Add this function to get all grid notes in the correct format
func get_all_notes() -> Dictionary:
	return note_references.duplicate(true)
