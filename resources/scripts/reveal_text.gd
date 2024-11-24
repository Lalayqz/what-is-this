extends Node

@onready var text = $Text
@onready var cover = $Cover


func _ready():
	cover.custom_minimum_size = text.size
	text.hide()
	cover.mouse_entered.connect(hide_cover)
	cover.mouse_exited.connect(show_cover)


func hide_cover():
	cover.modulate.a = 0
	text.show()
	

func show_cover():
	cover.modulate.a = 1
	text.hide()  # So that the text cannot be seen when the cover is translucent (when the hint is fading in/out)


func _process(delta):
	pass
