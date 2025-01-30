extends Node

signal answer_answered
signal virtual_keyboard_shown
signal virtual_keyboard_hid
const ANSWER = 'Banana'
const DEFAULT_COLOR = Color(0xdbc1afff)
const WRONG_COLOR = Color(0xcf6a4fff)
const CORRECT_COLOR = Color(0xb2af5cff)
const MAX_TAP_HOLD_TIME = 0.2
@onready var wrong_buzz = preload("res://resources/sounds/wrong.wav")
@onready var correct_sound = preload("res://resources/sounds/correct.wav")
var word = ''
var input_letters = []
var is_solved = false
var is_touched = false
var touch_hold_counter = 0
var virtual_keyboard_is_shown = false
var answer_check_in_queue = false


func _ready() -> void:
	for character in ANSWER:
		var letter_node = load("res://resources/scenes/letter.tscn").instantiate()
		add_child(letter_node)
		input_letters.append(letter_node.get_node('Letter/Letter/Letter'))


func _input(event):
	if not is_solved and event is InputEventKey and event.is_pressed():
		var input_key = OS.get_keycode_string(event.keycode)
		var inputed = false
		
		# Character input
		# For pc, I have to check event.unicode != 0, because when using ctrl+C or ctrl+V, event.unicode == 0.
		# However, for web, event.unicode is always 0.
		if event.unicode != 0 and not Input.is_key_pressed(KEY_CTRL):
			if event.keycode >= KEY_A and event.keycode <= KEY_Z:
				inputed = append_to_input(input_key)
			
		# Backspace
		elif event.keycode == KEY_BACKSPACE:
			if Input.is_key_pressed(KEY_CTRL):
				word = ''
			else:
				if len(word) > 0:
					word = word.erase(word.length() - 1, 1)
			inputed = true
			
		# Delete
		elif event.keycode == KEY_DELETE:
			word = ''
			inputed = true
		
		# Copy & paste
		elif Input.is_key_pressed(KEY_CTRL):
			if input_key.to_lower() == 'c':
				DisplayServer.clipboard_set(word)
			if input_key.to_lower() == 'v':
				inputed = append_to_input(DisplayServer.clipboard_get())
		
		if inputed and not answer_check_in_queue:
			answer_check_in_queue = true
			call_deferred('update_display')
			call_deferred('check_answer')
			
	elif event is InputEventScreenTouch:
		if event.is_pressed():
			is_touched = true
		elif event.is_released():
			# If it's a tap, then show/hide virtual keyboard
			if touch_hold_counter <= MAX_TAP_HOLD_TIME:
				if virtual_keyboard_is_shown:
					DisplayServer.virtual_keyboard_hide()
					virtual_keyboard_is_shown = false
					virtual_keyboard_hid.emit()
				elif not is_solved:
					DisplayServer.virtual_keyboard_show(word, Rect2(0, 0, 0, 0), DisplayServer.KEYBOARD_TYPE_PASSWORD)
					virtual_keyboard_is_shown = true
					virtual_keyboard_shown.emit()
			is_touched = false
			touch_hold_counter = 0


func _process(delta: float) -> void:
	if is_touched:
		touch_hold_counter += delta


# Returns false if nothing is appended.
func append_to_input(string) -> bool:
	if len(word) == len(ANSWER):
		return false
	
	for character in string:
		var lower_character = character.to_lower()
		if lower_character >= 'a' and character <= 'z':
			word += lower_character
	word = word.left(len(ANSWER))
	if len(word) > 0:
		word[0] = word[0].to_upper()
	return true


func update_display() -> void:
	var i = 0
	for input_letter in input_letters:
		if i < len(word):
			set_letter(input_letters[i], word[i])
		else:
			set_letter(input_letters[i], ' ')
		i += 1


func set_letter(container, letter) -> void:
	for label in container.get_children():
		label.text = letter


func check_answer() -> void:
	answer_check_in_queue = false
	
	if len(word) == len(ANSWER):
		if word == ANSWER:
			answer_answered.emit()
			
			is_solved = true
			set_text_color(CORRECT_COLOR)
			GlobalVariables.play_sound(correct_sound)
			if GlobalVariables.is_mobile:
				DisplayServer.virtual_keyboard_hide()
		else:
			set_text_color(WRONG_COLOR)
			GlobalVariables.play_sound(wrong_buzz)
	else:
		set_text_color(DEFAULT_COLOR)


func set_text_color(color) -> void:
	for container in input_letters:
		for label in container.get_children():
			label.set('theme_override_colors/font_color', color)
