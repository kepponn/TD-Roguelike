extends Main_Menu_Parent

# Dont forget to change the process to 'when paused'
# Therefore the menu can work while the game tree is paused

func _ready():
	#get_tree().paused = true
	hide()
	_displaySettings()
	_audioSettings()
	$Menu.show()
	$Options.hide()

func _process(_delta):
	# This was supposed to be 'esc' as well but it launch both function in the same time
	if Input.is_action_just_pressed("exit") and $Timer.time_left == 0:
		_on_resume_pressed()

func esc():
	$Audio/Foward.play(0.2)
	$Timer.start()

# --------------------------------------------------------------------------
# BaseButton function via pressed() signals
# --------------------------------------------------------------------------

func _on_resume_pressed():
	hide()
	#$Audio/Back.play(0.25)
	get_tree().paused = false

func _on_options_pressed():
	$Audio/Foward.play(0.25)
	$Menu.hide()
	$Options.show()
	
func _on_options_back_pressed():
	$Audio/Back.play(0.25)
	$Options.hide()
	$Menu.show()
	
func _on_quit_to_menu_pressed():
	$Audio/QuitMainMenu.play()
func _on_quit_to_menu_audio_finished():
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")

func _on_quit_to_desktop_pressed():
	$Audio/QuitDesktop.play()
func _on_quit_to_desktop_audio_finished():
	get_tree().quit()
