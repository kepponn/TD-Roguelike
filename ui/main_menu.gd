extends Main_Menu_Parent

var menu_buttons: Array
var level_button = preload("res://ui/level_selection_button.tscn")
var level_scene = {
	# level name and scene path
	"developer_debug": "res://scene/scene_level_debug.tscn",
	"the_diagonal_square": "res://scene/scene_level_1.tscn"
}

func seed_level_selection_scene():
	$LevelSelection/VBoxContainer/DummyButton.hide()
	$LevelSelection/VBoxContainer.add_theme_constant_override("separation", 10)
	for level_name in level_scene.keys():
		var button = level_button.instantiate()
		button.set_label_text = level_name.capitalize().replace("_", " ")
		var signal_name = "pressed"
		var callable = Callable(self, "_on_level_selection_button_pressed").bind(level_scene[level_name])
		button.connect(signal_name, callable)
		$LevelSelection/VBoxContainer.size.y += 40
		$LevelSelection/VBoxContainer.add_child(button, true)
	#var button = level_button.instantiate()
	#button.set_label_text = "Back"
	#button.connect("pressed", _on_level_selection_back_pressed)
	#$LevelSelection/VBoxContainer.size.y += 40
	#$LevelSelection/VBoxContainer.add_child(button, true)
	$LevelSelection/Back.position.y = $LevelSelection/VBoxContainer.size.y + 15
	$LevelSelection/Back.focus_neighbor_top = $LevelSelection/VBoxContainer.get_child(-1).get_path()

func _ready():
	ready_up()
	seed_level_selection_scene()
	$LevelSelection.hide()
	$InputSettings.hide()
	$Menu/Play.grab_focus()

# --------------------------------------------------------------------------
# BaseButton function via pressed() signals
# --------------------------------------------------------------------------

func _on_play_pressed():
	# Get and play the scene
	$Audio/Foward.play(0.25)
	$Menu.hide()
	$LevelSelection.show()
	$"LevelSelection/VBoxContainer/Button".grab_focus()

func _on_level_selection_button_pressed(scene_path: String):
	$Audio/Start.play()
	await get_tree().create_timer(0.15).timeout
	get_tree().paused = false
	get_tree().change_scene_to_file(scene_path)

func _on_level_selection_back_pressed():
	$Audio/Back.play(0.25)
	$LevelSelection.hide()
	$Menu.show()
	$Menu/Play.grab_focus()

func _on_options_pressed():
	# Make a volume slider and fullscreen/windowed options
	$Audio/Foward.play(0.25)
	$Menu.hide()
	$Options.show()
	$Options/Back.grab_focus()

func _on_options_back_pressed():
	$Audio/Back.play(0.25)
	$Options.hide()
	$Menu.show()
	$Menu/Options.grab_focus()

func _on_quit_pressed():
	$Audio/Quit.play()

func _on_quit_audio_finished():
	get_tree().quit()

func _on_remap_pressed():
	$Audio/Foward.play(0.25)
	$Options.hide()
	$InputSettings.show()
	$InputSettings/Back.grab_focus()

func _on_back_input_setting_pressed():
	$Audio/Back.play(0.25)
	$Options.show()
	$Options/Back.grab_focus()
	$InputSettings.hide()
