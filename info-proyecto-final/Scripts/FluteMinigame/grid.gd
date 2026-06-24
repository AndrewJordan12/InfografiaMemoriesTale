extends Control
@onready var rows : VBoxContainer = $Rows
@onready var beat_highlight : HBoxContainer = $CurrentNote
@onready var beat_highlight_template = $CurrentNote/Highlight_Template

@export var columns = 11

func _ready() -> void:
	create_highlights()
	update_beat_highlight(-1) #hides all highlights by default

func _process(delta: float) -> void:
	pass

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
