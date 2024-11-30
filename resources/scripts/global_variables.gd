extends Node

var is_mobile_on_web = OS.has_feature("web_android") or OS.has_feature("web_ios")
var is_mobile = is_mobile_on_web or OS.has_feature("mobile")


func play_sound(sound):
	var audio_player = AudioStreamPlayer.new()
	get_tree().root.add_child(audio_player)
	audio_player.stream = sound
	audio_player.play()
	audio_player.finished.connect(func(): audio_player.queue_free())
