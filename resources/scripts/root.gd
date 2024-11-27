extends Node


func _ready() -> void:
	call_deferred("change_scene")


func change_scene():
	if GlobalVariables.is_mobile:
		if GlobalVariables.is_mobile_on_web:
			get_tree().change_scene_to_file("res://resources/scenes/main_mobile_web.tscn")
		else:
			get_tree().change_scene_to_file("res://resources/scenes/main_mobile.tscn")
	else:
		get_tree().change_scene_to_file("res://resources/scenes/main_pc.tscn")
