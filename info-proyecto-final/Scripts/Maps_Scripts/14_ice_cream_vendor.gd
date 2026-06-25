extends BaseMap

@onready var minigame = $ShuffleCup
func _ready() -> void:
	super._ready()
	

func _on_shuffle_cup_puzzle_ended(won: bool) -> void:
	if won == true:
		minigame.on_win(digit)

func start_puzzle():
	minigame.visible = true
	minigame.start()
	
func _on_shuffle_cup_close() -> void:
	minigame.visible = false
