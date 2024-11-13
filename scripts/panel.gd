extends Node

@onready var the_thing = $Border/TheThing
@onready var pixel_display = $Border/PixelDisplay
@onready var texture_of_the_thing = the_thing.texture.get_image()
@onready var pixel_display_default_color = pixel_display.color


func _ready() -> void:
	pass


func _input(event) -> void:
	if event is InputEventMouseMotion:
		var relative_mouse_position = event.position - the_thing.global_position
		
		var color
		if relative_mouse_position.x >= 0 and relative_mouse_position.x < texture_of_the_thing.get_width() and relative_mouse_position.y >= 0 and relative_mouse_position.y < texture_of_the_thing.get_height():
			color = texture_of_the_thing.get_pixelv(relative_mouse_position)
		else:
			color = pixel_display_default_color
		pixel_display.color = color


func _process(delta: float) -> void:
	pass
