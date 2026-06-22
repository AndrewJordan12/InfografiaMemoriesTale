extends Node

var target_scene: String = ""
var spawn_point: String = "center"

func goto_scene(path: String, spawn: String = "center") -> void:
	target_scene = path
	spawn_point = spawn
	get_tree().change_scene_to_file("res://Scenes/Loading/loading.tscn")
