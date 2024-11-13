extends Node

const SOLVE_DUARTION = 0.5
@onready var input = $UI/Input/Input/Input
@onready var pixel_display = $UI/Panel/Panel/Border/PixelDisplay


func _ready() -> void:
	input.answer_answered.connect(solve)


func _process(delta: float) -> void:
	pass


func solve() -> void:
	var transparency_tween = create_tween()
	transparency_tween.tween_property(pixel_display, 'size:x', 0, SOLVE_DUARTION)
