extends Area2D

@export var target_scene: String = ""
@export var spawn_point: String = "center"
@export var trigger_color: Color = Color(0, 1, 1, 0.3)
@export var trigger_size: Vector2 = Vector2(50, 50):
	set(value):
		trigger_size = value
		if is_inside_tree():
			_apply_size()

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	$Polygon2D.color = trigger_color
	_apply_size()

func _apply_size() -> void:
	if not is_inside_tree():
		return
	var poly: Polygon2D = $Polygon2D
	var half_x: float = trigger_size.x / 2.0
	var half_y: float = trigger_size.y / 2.0
	poly.polygon = PackedVector2Array([
		Vector2(-half_x, -half_y),
		Vector2(half_x, -half_y),
		Vector2(half_x, half_y),
		Vector2(-half_x, half_y)
	])
	poly.color = trigger_color
	for child in get_children():
		if child is CollisionShape2D and child.shape is RectangleShape2D:
			child.shape.size = trigger_size

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		set_deferred("monitoring", false)
		SceneTransition.goto_scene(target_scene, spawn_point)
