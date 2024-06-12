extends Control

@onready var input_buttonScene = preload("res://ui/input_button.tscn")
@onready var action_list = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ActionList

var is_remapping = false
var action_toRemap = null
var remapping_button = null

#Input dictionary, it is a list of action that able to be rebinded
#left side should be the same as in the project settings,
#right side is the action name that will be printed 
var input_available = [
					"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
					"1","2","3","4","5","6","7","8","9","0",
					"Space"
					]

var input_actions = {
	#up, left, right, down might be changed later because we dont want to use default action
	#so dont forget to change this
	"ui_up": "Move up",
	"ui_left": "Move left",
	"ui_right": "Move right",
	"ui_down": "Move down",
	"interact": "Interact",
	"inspect": "Inspect",
	"start": "Start wave",
	"rotate": "Rotate"
}

func _ready():
	_createActionList()
	
	
func _createActionList():
	
	InputMap.load_from_project_settings()
	#to clear flush action_list node
	for item in action_list.get_children():
		item.queue_free()
		
	for action in input_actions:
		var button = input_buttonScene.instantiate()
		var action_label = button.find_child("LabelAction")
		var input_label = button.find_child("LabelInput")
		#Set Action text to selected action (ex. UI_left,UI_right, interact, exit)
		
		action_label.text = input_actions[action]
		
		#check if the selected action is binded with any key or not
		var events = InputMap.action_get_events(action)

		#print(input_actions[action]," : Action Name - Event Name : ", events[0].as_text())
		#if it is binded, then change Input text to binded key
		if events.size() > 0:
			input_label.text = events[0].as_text().trim_suffix(" (Physical)")
		#if it is not binded with any key, then just change to empty string
		else:
			input_label.text = ""
			
		action_list.add_child(button)
		#connect signal 
		button.pressed.connect(_on_input_button_pressed.bind(button, action))

func _on_input_button_pressed(button, action):
	if is_remapping == false:
		is_remapping = true
		action_toRemap = action
		remapping_button = button
		button.find_child("LabelInput").text = "Press any key to bind..."

func _input(event):
	
	if is_remapping == true:
		#this will check if input is from mouse or keyboard only,
		#for other input such as controller, touch, etc just type InputEvent and scroll down
		if ((event is InputEventKey and input_available.has(event.as_text()))or (event is InputEventMouseButton and event.pressed)):
			
			#used to not record double click
			if event is InputEventMouseButton and event.double_click:
				event.double_click = false
			
			#this will erase all the event on the selected action
			#if you want to erase only 1 event then use
			#action_erase_event(action_Name, events_name)
			InputMap.action_erase_events(action_toRemap)
			InputMap.action_add_event(action_toRemap, event)
			#update event text to new input event
			_updateActionList(remapping_button, event)
			
			#change it back to default value so we can remap again
			is_remapping = false
			action_toRemap = null
			remapping_button = null
			
			#idk how to explain this but i think it will prevent other func or code to get the event
			#this thing will fix if you wanted to remap to LMB as it will change event to LMB but then it will remap again right after
			
			accept_event()
			
func _updateActionList(button, event):
	button.find_child("LabelInput").text = event.as_text().trim_suffix(" (Physical)")
	

func _on_button_pressed():
	_createActionList()
