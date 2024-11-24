extends Node


func _ready() -> void:
	if GlobalVariables.is_mobile:
		get_tree().change_scene_to_file("res://resources/scenes/main_mobile.tscn")
	else:
		get_tree().change_scene_to_file("res://resources/scenes/main_pc.tscn")
