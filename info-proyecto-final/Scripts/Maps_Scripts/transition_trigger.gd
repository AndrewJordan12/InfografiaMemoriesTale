extends Area2D

@export var target_scene: String = ""
@export var spawn_marker: String = ""
@onready var labelMap : Label = get_parent().get_node("MapMention")

var _player: CharacterBody2D
var _triggered: bool = false
var _bubble_timer: float = 0.0
var _waiting: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _exit_tree() -> void:
	_player = null

func _process(delta: float) -> void:
	if _waiting:
		_bubble_timer -= delta
		if _bubble_timer <= 0.0:
			_waiting = false
			SceneTransition.goto_scene(target_scene, name, spawn_marker)

func _get_destination_text() -> String:
	var names = {
		"1_Entrance": "Entrada",
		"3_OneLampTwoBenches": "Banco con Lampara",
		"4_Bust": "Busto",
		"8_BridgeMiddle": "Puente (Medio)",
		"9_BridgeBottom": "Puente (Abajo)",
		"10_Statue": "Estatua",
		"11_PondBench": "Banco del Lago",
		"12_ForestPath": "Sendero del Bosque",
		"13_MusicMan": "Musico",
		"14_IceCreamVendor": "Vendedor de Helados",
	}
	var key = target_scene.get_file().get_basename()
	return names.get(key, key)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and not _triggered:
		_player = body
		_player.bubble_text = _get_destination_text()
		labelMap.visible = true
		labelMap.text = _get_destination_text()
		_triggered = true
		_waiting = true
		_bubble_timer = 0.8
		set_deferred("monitoring", false)
