extends Control

# Maybe check this after done loading the main menu scene?
@onready var player = get_node('/root/Node3D/Player')

# Keyboard start here
@onready var WASD = $MarginContainer/HBoxContainer/WASD
@onready var E = $MarginContainer/HBoxContainer/E
@onready var C = $MarginContainer/HBoxContainer/C
@onready var V = $MarginContainer/HBoxContainer/V
@onready var Space = $MarginContainer/HBoxContainer/Space

@onready var text_WASD = $MarginContainer/HBoxContainer/WASD/WASDEventLabel
@onready var text_E = $MarginContainer/HBoxContainer/E/EEventLabel
@onready var text_C = $MarginContainer/HBoxContainer/C/CEventLabel
@onready var text_V = $MarginContainer/HBoxContainer/V/VEventLabel
@onready var text_Space = $MarginContainer/HBoxContainer/Space/SpaceEventLabel

@onready var icon_E = $MarginContainer/HBoxContainer/E/EIcon
@onready var icon_C = $MarginContainer/HBoxContainer/C/CIcon
@onready var icon_V = $MarginContainer/HBoxContainer/V/VIcon
@onready var icon_Space = $MarginContainer/HBoxContainer/Space/SpaceIcon
# Keyboard end here

# Controller start here
@onready var controller_A = $MarginContainer/HBoxContainerController/A
@onready var controller_B = $MarginContainer/HBoxContainerController/B
@onready var controller_X = $MarginContainer/HBoxContainerController/X
@onready var controller_Start = $MarginContainer/HBoxContainerController/Start
@onready var controller_StickL = $MarginContainer/HBoxContainerController/Move

@onready var text_controller_A = $MarginContainer/HBoxContainerController/A/AEventLabel
@onready var text_controller_B = $MarginContainer/HBoxContainerController/B/BEventLabel
@onready var text_controller_X = $MarginContainer/HBoxContainerController/X/XEventLabel
@onready var text_controller_Start = $MarginContainer/HBoxContainerController/Start/StartEventLabel
# Controller end here

func _ready():
	update_Icon()

func _process(_delta):
	update_Icon()
	if get_parent().name == "MainMenu":
		# Keyboard
		E.hide()
		C.hide()
		V.hide()
		Space.hide()
		WASD.hide()
		# Controller
		controller_A.hide() # E keyboard
		controller_B.hide() # V keyboard
		controller_X.hide() # C keyboard
		controller_Start.hide()
		controller_StickL.hide()
	
	elif get_parent().name == "Control":
		#--------------------------------------PREPARATION PHASE------------------------------------------------
		if Global.preparation_phase:
			#------------ E INPUT / INTERACT------------
			#DEFAULT STATE -> HIDE
			if !player.player_ableInteract and !player.player_isHoldingItem:
				E.hide()
				controller_A.hide()
			#PICK ITEM
			elif player.player_ableInteract and !player.player_isHoldingItem:
				text_E.text = "Pick up"
				E.show()
				text_controller_A.text = "Pick up"
				controller_A.show()
			#DROP ITEM
			elif !player.player_ableInteract and player.player_isHoldingItem:
				text_E.text = "Drop"
				E.show()
				text_controller_A.text = "Drop"
				controller_A.show()
			#SWAP ITEM
			elif player.player_ableInteract and player.player_isHoldingItem:
				text_E.text = "Swap"
				E.show()
				text_controller_A.text = "Swap"
				controller_A.show()
			
			#------------ C INPUT / INSPECT ------------
			#DEFAULT STATE -> HIDE
			if !player.player_ableInteract:
				C.hide()
				controller_X.hide()
			#INSPECT
			elif player.player_ableInteract and !player.player_isHoldingItem and !player.player_interactedItem_Temp.has_method("mount"):
				if player.player_interactedItem_Temp.id != "shop":
					text_C.text = "Inspect"
					C.show()
					text_controller_X.text = "Inspect"
					controller_X.show()
			#OPEN SHOP
				else:
					text_C.text = "Open Shop"
					C.show()
					text_controller_X.text = "Open Shop"
					controller_X.show()
					
			#MOUNT
			elif player.player_interactedItem_Temp != null:
				if player.player_interactedItem_Temp.has_method("mount"):
					if player.player_isHoldingItem and player.player_interactedItem_Temp.currently_mountable_item == null:
						text_C.text = "Mount"
						C.show()
						text_controller_X.text = "Mount"
						controller_X.show()
			#DISMOUNT
					elif !player.player_isHoldingItem and player.player_interactedItem_Temp.currently_mountable_item != null:
						text_C.text = "Dismount"
						C.show()
						text_controller_X.text = "Dismount"
						controller_X.show()
			
			#------------ V INPUT / ROTATE ------------
			#DEFAULT STATE -> HIDE
			if !player.player_ableInteract and !player.player_isHoldingItem:
				V.hide()
				controller_B.hide()
			#ROTATE HOLDED ITEM OR INTERACTABLE ITEM / TARGETED ITEM
			elif (player.player_isHoldingItem or player.player_ableInteract) and !Function.search_regex("wall", player.player_interactedItem_Temp.id):
				text_V.text = "Rotate"
				V.show()
				text_controller_B.text = "Rotate"
				controller_B.show()
			#ROTATE MOUNTED ITEM
			elif player.player_interactedItem_Temp.id == "wall_mountable" and player.player_interactedItem_Temp.get_child(-1).is_class("StaticBody3D"):
				text_V.text = "Rotate"
				V.show()
				text_controller_B.text = "Rotate"
				controller_B.show()
			
			#------------ SPACE INPUT / READY ------------
			text_Space.text = "Ready"
			Space.show()
			text_controller_Start.text = "Ready"
			controller_Start.show()
				
		#--------------------------------------DEFENSE PHASE------------------------------------------------
		elif !Global.preparation_phase :
			#------------ E INPUT / INSPECT ------------
			E.hide()
			controller_A.hide()
			#------------ C INPUT / INSPECT ------------
			#DEFAULT STATE -> HIDE
			if !player.player_ableInteract:
				C.hide()
				controller_X.hide()
			#INSPECT
			elif player.player_ableInteract and !player.player_isHoldingItem and !player.player_interactedItem_Temp.has_method("mount"):
				if player.player_interactedItem_Temp.id != "shop":
					text_C.text = "Inspect"
					C.show()
					text_controller_X.text = "Inspect"
					controller_X.show()
			#------------ V INPUT / INSPECT ------------
			V.hide()
			controller_B.hide()
			#------------ SPACE INPUT / READY ------------
			Space.hide()
			controller_Start.hide()
	
	
func update_Icon():
	#Update E Icon
	
	var key_E = InputMap.action_get_events("interact")[0].as_text().trim_suffix(" (Physical)")
	icon_E.texture = load("res://assets/icon/KeyboardButton/"+ str(key_E) +"_light.png")
	#Update C Icon
	var key_C = InputMap.action_get_events("inspect")[0].as_text().trim_suffix(" (Physical)")
	icon_C.texture = load("res://assets/icon/KeyboardButton/"+ str(key_C) +"_light.png")
	#Update V Icon
	var key_V = InputMap.action_get_events("rotate")[0].as_text().trim_suffix(" (Physical)")
	icon_V.texture = load("res://assets/icon/KeyboardButton/"+ str(key_V) +"_light.png")
	#Update Space Icon
	var key_Space = InputMap.action_get_events("start")[0].as_text().trim_suffix(" (Physical)")
	icon_Space.texture = load("res://assets/icon/KeyboardButton/"+ str(key_Space) +"_light.png")
