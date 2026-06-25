extends BaseMap

@onready var minigame = $ShuffleCup
func _ready() -> void:
	super._ready()
	await start_puzzle()

func _on_shuffle_cup_puzzle_ended(won: bool) -> void:
	if won == true:
		minigame.on_win(digit)

func start_puzzle():
	await minigame.start()
	
