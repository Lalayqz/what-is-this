extends Node

signal answer_answered
signal virtual_keyboard_shown
signal virtual_keyboard_hid
const ANSWER = 'Banana'
const DEFAULT_COLOR = Color(0xdbc1afff)
const WRONG_COLOR = Color(0xcf6a4fff)
const CORRECT_COLOR = Color(0xb2af5cff)
const MAX_TAP_HOLD_TIME = 0.2
@onready var max_word_length = len(get_children())
@onready var wrong_buzz = preload("res://resources/sounds/wrong.wav")
@onready var correct_sound = preload("res://resources/sounds/correct.wav")
var word = ''
var input_letters = []
var is_solved = false
var is_touched = false
var touch_hold_counter = 0
var virtual_keyboard_is_shown = false
var answer_check_in_queue = false
# For mobile web only.
var line_edit
var last_line_edit_text = ''


func _ready() -> void:
	for letter in get_children():
		input_letters.append(letter.get_node('Letter/Letter/Letter'))


func _input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			is_touched = true
		elif event.is_released():
			# If it's a tap, then show/hide virtual keyboard
			if touch_hold_counter <= MAX_TAP_HOLD_TIME and not is_solved:
				if virtual_keyboard_is_shown:
					DisplayServer.virtual_keyboard_hide()
					virtual_keyboard_is_shown = false
					virtual_keyboard_hid.emit()
					
					# Clear the input so that the caret resetting to position 0 shouldn't be a problem!
					word = ''
					update_display()
				else:
					# Why I shouldn't use the default keyboard type:
					# Becuase auto-completion brings spaces to the keyboard buffer.
					DisplayServer.virtual_keyboard_show(word, Rect2(0, 0, 0, 0), DisplayServer.KEYBOARD_TYPE_PASSWORD)
					virtual_keyboard_is_shown = true
					virtual_keyboard_shown.emit()
			is_touched = false
			touch_hold_counter = 0


func _process(delta: float) -> void:
	if is_touched:
		touch_hold_counter += delta
	
	# Listener for line edit.
	# Keep the text of line edit in sync of the buffer of virtual keyborad.
	# Change word accordingly (append/remove) when line edit changes.
	# Also text format only happens on word, not on line edit.
	if GlobalVariables.is_mobile_on_web:
		var old_length = len(last_line_edit_text)
		var new_length = len(line_edit.text)
		var inputed = false
		
		# Append text to word.
		if new_length > old_length:
			inputed = append_to_input(line_edit.text.right(new_length - old_length))
		# Delete text from word.
		elif new_length < old_length and len(word) > 0:
			word = word.left(-1)
			inputed = true
			
		if inputed and not answer_check_in_queue:
			answer_check_in_queue = true
			call_deferred('update_display')
			call_deferred('check_answer')
		last_line_edit_text = line_edit.text


# Returns false if nothing is appended.
func append_to_input(string) -> bool:
	if len(word) == max_word_length:
		return false
	
	for character in string:
		var lower_character = character.to_lower()
		if lower_character >= 'a' and character <= 'z':
			word += lower_character
	word = word.left(max_word_length)
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
	
	if len(word) == max_word_length:
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


# for mobile web only.
func format_line_edit(_str, line_edit):
	var string_with_letters = ''
	for ch in line_edit.text:
		if ('A' <= ch and ch <= 'Z') or ('a' <= ch and ch <= 'z'):
			string_with_letters += ch
	
	var old_word = word
	word = ''
	append_to_input(string_with_letters)
	line_edit.text = word
	line_edit.caret_column = len(line_edit.text) # Because after changing text, the caret somehow goes to position 0.
	
	if word != old_word and not answer_check_in_queue:
		word = line_edit.text
		call_deferred('update_display')
		call_deferred('check_answer')


# for mobile web only. Not affecting input though.
func move_line_edit_caret(_input_event, line_edit):
	line_edit.caret_column = len(line_edit.text)
