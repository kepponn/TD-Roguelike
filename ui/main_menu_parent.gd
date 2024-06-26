extends CanvasLayer
class_name Main_Menu_Parent

# --------------------------------------------------------------------------
# This function should be a scene with all node needed and simply imported for both main-menu and in-game menu
# Remember to put this _ready() function in the child
# Current child:
# "res://scene/ui/MainMenu.gd"
# "res://scene/ui/IngameMenu.gd"
# --------------------------------------------------------------------------

func ready_up():
	get_tree().paused = true
	_displaySettings()
	_audioSettings()
	$Audio/BackgroundMusic.play()
	$Menu.show()
	$Options.hide()

func _unhandled_input(event):
	if event is InputEventJoypadButton and event.is_pressed():
		if Input.is_action_just_pressed("controller_A"):
			var focused_button = get_viewport().gui_get_focus_owner()
			if focused_button:
				focused_button.emit_signal("pressed")
		if Input.is_action_just_pressed("controller_B"):
			if $Menu.visible:
				if get_parent().name == "MainMenu":
					$Menu/Play.grab_focus()
				elif get_parent().name == "Control":
					$Menu/Resume.grab_focus()
			elif $Options.visible: 
				$Options/Back.grab_focus()
			elif $InputSettings.visible:
				$InputSettings/Back.grab_focus()

func _displaySettings():
	if Settings.displayMode_fullscreen:
		%FullscreenButton.show()
		%WindowedButton.hide()
		%FullscreenButton.grab_focus()
	else:
		%FullscreenButton.hide()
		%WindowedButton.show()
		%WindowedButton.grab_focus()

func _audioSettings():
	%MasterVolume.value = Settings.audioMaster_volumeTemp
	%MusicVolume.value = Settings.audioMusic_volumeTemp
	%EffectVolume.value = Settings.audioEffect_volumeTemp

# --------------------------------------------------------------------------
# Audio volume settings
# Check the bus index name in editor bottom window > audio
# --------------------------------------------------------------------------

var audioMaster_volume = AudioServer.get_bus_index("Master")
var audioMusic_volume = AudioServer.get_bus_index("Music")
var audioEffect_volume = AudioServer.get_bus_index("Effect")

func audioMuteCheck(value, audioBus):
	# Volume slider value are based on audio-dB
	# 0dB as max and -30dB as minimum/muted
	if value == -30:
		AudioServer.set_bus_mute(audioBus, true)
		print("Audio Muted")
	else:
		AudioServer.set_bus_mute(audioBus, false)
		#print("Audio Unmute")

# --------------------------------------------------------------------------
# Resolution change settings fullscreen / windowed
# --------------------------------------------------------------------------

func _on_options_fullscreen_pressed():
	$Audio/Foward.play(0.25) # This is supposed to be in the parent
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	Settings.displayMode_fullscreen = false
	_displaySettings()
	print("Display mode changed: Windowed")
	#%FullscreenButton.hide()
	#%WindowedButton.show()

func _on_options_windowed_pressed():
	$Audio/Foward.play(0.25) # This is supposed to be in the parent
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	Settings.displayMode_fullscreen = true
	_displaySettings()
	print("Display mode changed: Fullscreen")
	#%WindowedButton.hide()
	#%FullscreenButton.show()

# --------------------------------------------------------------------------
# Audio volume slider settings
# --------------------------------------------------------------------------

func _on_options_master_volume(value):
	AudioServer.set_bus_volume_db(audioMaster_volume, value)
	Settings.audioMaster_volumeTemp = value
	audioMuteCheck(value, audioMaster_volume)

func _on_options_music_volume(value):
	AudioServer.set_bus_volume_db(audioMusic_volume, value)
	Settings.audioMusic_volumeTemp = value
	audioMuteCheck(value, audioMusic_volume)

func _on_options_effect_volume(value):
	AudioServer.set_bus_volume_db(audioEffect_volume, value)
	Settings.audioEffect_volumeTemp = value
	audioMuteCheck(value, audioEffect_volume)
