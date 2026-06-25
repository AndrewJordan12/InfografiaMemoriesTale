extends Node

@onready var flute_minigame = $FluteMinigame
@onready var soundtrack = $Soundtrack

var fluteminigame_players: Dictionary = {}
var soundtrack_players: Dictionary = {}

func _ready() -> void:
	for child in soundtrack.get_children():
		soundtrack_players[child.name] = child

	for child in flute_minigame.get_children():
		fluteminigame_players[child.name] = child

func play_soundtrack(sound_name: String):
	if soundtrack_players.has(sound_name):
		soundtrack_players[sound_name].play()
	else:
		push_error("Music not found: ", sound_name)

func sfx_fluteminigame(sound_name: String):
	if fluteminigame_players.has(sound_name):
		fluteminigame_players[sound_name].play()
	else:
		push_error("SFX not found: ", sound_name)
