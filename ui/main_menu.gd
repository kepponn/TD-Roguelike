extends Main_Menu_Parent

func _ready():
	ready_up()

# --------------------------------------------------------------------------
# BaseButton function via pressed() signals
# --------------------------------------------------------------------------

func _on_play_pressed():
	# Get and play the scene
	$Audio/Start.play()

func _on_play_audio_finished():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scene/scene.tscn")

func _on_options_pressed():
	# Make a volume slider and fullscreen/windowed options
	$Audio/Foward.play(0.25)
	$Menu.hide()
	$Options.show()

func _on_options_back_pressed():
	$Audio/Back.play(0.25)
	$Options.hide()
	$Menu.show()

func _on_quit_pressed():
	$Audio/Quit.play()

func _on_quit_audio_finished():
	get_tree().quit()


func _on_remap_pressed():
	$Audio/Foward.play(0.25)
	$Options.hide()
	$InputSettings.show()


func _on_back_input_setting_pressed():
	$Audio/Back.play(0.25)
	$Options.show()
	$InputSettings.hide()
