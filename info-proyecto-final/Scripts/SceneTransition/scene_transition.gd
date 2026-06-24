extends Node

var target_scene: String = ""
var spawn_trigger: String = ""
var spawn_marker: String = ""

func goto_scene(path: String, trigger_name: String = "", marker_name: String = "") -> void:
	target_scene = path
	spawn_trigger = trigger_name
	spawn_marker = marker_name
	get_tree().call_deferred("change_scene_to_file", "res://Scenes/Loading/loading.tscn")
