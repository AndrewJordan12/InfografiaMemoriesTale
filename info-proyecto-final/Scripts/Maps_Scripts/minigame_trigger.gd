extends Area2D

@export var target_scene: String = ""
@export var trigger_name: String = ""

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
			SceneTransition.return_spawn_marker = "Spawnpoint"
			SceneTransition.goto_minigame(target_scene, get_tree().current_scene.scene_file_path, trigger_name)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and not _triggered:
		_player = body
		_player.bubble_text = "Minijuego"
		_triggered = true
		_waiting = true
		_bubble_timer = 0.8
		set_deferred("monitoring", false)

func disable_trigger() -> void:
	monitoring = false
	var collision = get_node_or_null("CollisionShape2D")
	if collision:
		collision.set_deferred("disabled", true)
	monitorable = false
