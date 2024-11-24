extends Node

const SOLVE_DUARTION = 0.5
#const HINT_TIME = [15 * 60, 30 * 60, 60 * 60] # 15min, 30min, 60min
const HINT_TIME = [15, 30, 60] # 15min, 30min, 60min
const HINT_FADE_DURATION = 1
const HINT_FADE_GAP = 0.5
@onready var title = $UI/Head/Title if GlobalVariables.is_mobile else $UI/Title/Title
@onready var input = $UI/Head/Input/Input if GlobalVariables.is_mobile else $UI/Input/Input/Input
@onready var pixel_display = $UI/Panel/Panel/Border/PixelDisplay/PixelDisplay
@onready var conclusion = $UI/Conclusion/Conclusion/Conclusion if GlobalVariables.is_mobile else null
var hint_sound = preload("res://resources/sounds/hint.wav")
var is_solved = false
var time_elapsed = 0
var current_hint_level = 0
var current_hint_node = null
var hint_tween


func _ready() -> void:
	input.answer_answered.connect(solve)
	if GlobalVariables.is_mobile:
		input.virtual_keyboard_shown.connect(switch_to_show_input)
		input.virtual_keyboard_hid.connect(switch_to_show_title)
		switch_to_show_title()


func _process(delta: float) -> void:
	if not is_solved and current_hint_level < len(HINT_TIME):
		time_elapsed += delta
		
		var to_update_hint = false
		while current_hint_level < len(HINT_TIME) and time_elapsed >= HINT_TIME[current_hint_level]:
			current_hint_level += 1
			to_update_hint = true
		if to_update_hint:
			update_hint()


func update_hint():
	GlobalVariables.play_sound(hint_sound)
	
	# Clears the hint animation if there is currently one.
	if hint_tween != null:
		hint_tween.custom_step(2 * HINT_FADE_DURATION + HINT_FADE_GAP)
	
	hint_tween = create_tween()
	if current_hint_node != null:
		hint_tween.tween_property(current_hint_node, "modulate:a", 0, HINT_FADE_DURATION)
		hint_tween.tween_interval(HINT_FADE_GAP)
		hint_tween.tween_callback(func(): remove_child(current_hint_node))
	hint_tween.tween_callback(add_hint_node)


func add_hint_node():
	var hint_node = load("res://resources/scenes/hint" + str(current_hint_level) + ".tscn").instantiate()
	var line1 = hint_node.get_node("Line1")
	line1.text = line1.text % "tap" if GlobalVariables.is_mobile else line1.text % "hover"
	
	add_child(hint_node)
	current_hint_node = hint_node
	hint_node.modulate.a = 0
	hint_tween = create_tween()
	hint_tween.tween_property(current_hint_node, "modulate:a", 1, HINT_FADE_DURATION)
	
	# I don't know why it doesn't work.
	#hint_tween.stop()
	#hint_tween.tween_property(current_hint_node, "modulate:a", 1, HINT_FADE_DURATION)
	#hint_tween.play()


func solve() -> void:
	is_solved = true
	
	var transparency_tween = create_tween()
	transparency_tween.tween_property(pixel_display, 'custom_minimum_size:x', 0, SOLVE_DUARTION)
	if GlobalVariables.is_mobile:
		conclusion.modulate.a = 1
	else:
		title.text = "It  is  a  banana !"


# For mobile only.
func switch_to_show_title():
	if not is_solved:
		title.modulate.a = 1
		input.modulate.a = 0


# For mobile only.
func switch_to_show_input():
	input.modulate.a = 1
	title.modulate.a = 0
