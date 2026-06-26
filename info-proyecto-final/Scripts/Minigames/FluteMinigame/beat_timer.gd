extends Timer

signal beat_tick(beat_number)

@onready var root = get_parent()
@export var bpm: float = 120

func _ready() -> void:
	timeout.connect(_on_metronome_tick)
	set_metronome_settings()
	print(bpm)

func set_metronome_settings():
	if root.get("bpm"):
		wait_time = 60.0 / root.bpm
	else:
		wait_time = 60.0 / bpm 
	print(bpm)
	#one_shot handled by main script (flute_main)
	# one_shot should be false tho

func _on_metronome_tick():
	beat_tick.emit()

func toggle():
	if is_stopped():
		start()
		print("Metronome ON")
	else:
		stop()
		print("Metronome OFF")
