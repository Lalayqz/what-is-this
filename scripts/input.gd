extends Node

signal answer_answered
const ANSWER = 'Banana'
const DEFAULT_COLOR = Color(0xdbc1afff)
const WRONG_COLOR = Color(0xcf6a4fff)
const CORRECT_COLOR = Color(0xb2af5cff)
@onready var max_word_length = len(get_children())
var word = ''
var input_letters = []
var is_solved = false


func _ready() -> void:
	for letter in get_children():
		input_letters.append(letter.get_node('Letter/Letter'))


func _input(event):
	if not is_solved and event is InputEventKey and event.is_pressed():
		var input_key = OS.get_keycode_string(event.keycode)
		var inputed = false
		
		# Character input
		if event.unicode != 0:
			if event.keycode >= KEY_A and event.keycode <= KEY_Z: # When Chinese is inputed, input_key will be 'Unknown'
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
		
		if inputed:
			call_deferred('update_display')
			call_deferred('check_answer')


func _process(delta: float) -> void:
	pass


# Returns false if nothing is appended.
func append_to_input(string) -> bool:
	if len(word) == max_word_length:
		return false
	
	for character in string:
		var lower_character = character.to_lower()
		if lower_character >= 'a' and character <= 'z':
			word += lower_character
		word = word.substr(0, max_word_length)
		word[0] = word[0].to_upper()
	return true


func update_display() -> void:
	var i = 0
	for input_letter in input_letters:
		if i < len(word):
			input_letters[i].text = word[i]
		else:
			input_letters[i].text = ' '
		i += 1


func check_answer() -> void:
	if len(word) == max_word_length:
		if word == ANSWER:
			answer_answered.emit()
			
			is_solved = true
			set_text_color(CORRECT_COLOR)
		else:
			set_text_color(WRONG_COLOR)
	else:
		set_text_color(DEFAULT_COLOR)


func set_text_color(color) -> void:
	for input_letter in input_letters:
		input_letter.set('theme_override_colors/font_color', color)
