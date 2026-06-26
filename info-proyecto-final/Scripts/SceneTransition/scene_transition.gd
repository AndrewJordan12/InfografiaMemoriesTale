extends Node

var target_scene: String = ""
var spawn_trigger: String = ""
var spawn_marker: String = ""
var return_scene: String = ""
var return_trigger_name: String = ""
var return_spawn_marker: String = ""
var minigame_won: bool = false

func goto_scene(path: String, trigger_name: String = "", marker_name: String = "") -> void:
	target_scene = path
	spawn_trigger = trigger_name
	spawn_marker = marker_name
	get_tree().call_deferred("change_scene_to_file", "res://Scenes/Loading/loading.tscn")

func goto_minigame(minigame_scene: String, from_scene: String, trigger: String) -> void:
	return_scene = from_scene
	return_trigger_name = trigger
	minigame_won = false
	goto_scene(minigame_scene)

func return_from_minigame() -> void:
	if return_scene == "":
		return
	var path = return_scene
	var trigger = return_trigger_name
	var marker = return_spawn_marker
	return_scene = ""
	return_trigger_name = ""
	return_spawn_marker = ""
	goto_scene(path, trigger, marker)
	
