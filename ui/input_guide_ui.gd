extends Control

# Keyboard start here
@onready var WASD = $MarginContainer/HBoxContainer/WASD
@onready var E = $MarginContainer/HBoxContainer/E
@onready var C = $MarginContainer/HBoxContainer/C
@onready var V = $MarginContainer/HBoxContainer/V
@onready var X = $MarginContainer/HBoxContainer/X
@onready var Space = $MarginContainer/HBoxContainer/Space

@onready var text_WASD = $MarginContainer/HBoxContainer/WASD/WASDEventLabel
@onready var text_E = $MarginContainer/HBoxContainer/E/EEventLabel
@onready var text_C = $MarginContainer/HBoxContainer/C/CEventLabel
@onready var text_V = $MarginContainer/HBoxContainer/V/VEventLabel
@onready var text_X = $MarginContainer/HBoxContainer/X/XEventLabel
@onready var text_Space = $MarginContainer/HBoxContainer/Space/SpaceEventLabel

@onready var icon_E = $MarginContainer/HBoxContainer/E/EIcon
@onready var icon_C = $MarginContainer/HBoxContainer/C/CIcon
@onready var icon_V = $MarginContainer/HBoxContainer/V/VIcon
@onready var icon_X = $MarginContainer/HBoxContainer/X/XIcon
@onready var icon_Space = $MarginContainer/HBoxContainer/Space/SpaceIcon
# Keyboard end here

# Controller start here
@onready var controller_A = $MarginContainer/HBoxContainerController/A
@onready var controller_B = $MarginContainer/HBoxContainerController/B
@onready var controller_X = $MarginContainer/HBoxContainerController/X
@onready var controller_Y = $MarginContainer/HBoxContainerController/Y
@onready var controller_Start = $MarginContainer/HBoxContainerController/Start
@onready var controller_AnalogL = $MarginContainer/HBoxContainerController/Move

@onready var text_controller_A = $MarginContainer/HBoxContainerController/A/AEventLabel
@onready var text_controller_B = $MarginContainer/HBoxContainerController/B/BEventLabel
@onready var text_controller_X = $MarginContainer/HBoxContainerController/X/XEventLabel
@onready var text_controller_Y = $MarginContainer/HBoxContainerController/Y/YEventLabel
@onready var text_controller_Start = $MarginContainer/HBoxContainerController/Start/StartEventLabel
@onready var text_controller_AnalogL = $MarginContainer/HBoxContainerController/Move/EventLabel
# Controller end here

func _input(event):
	if event is InputEventKey or event is InputEventMouse:
		$MarginContainer/HBoxContainerController.hide()
		$MarginContainer/HBoxContainer.show()
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		$MarginContainer/HBoxContainerController.show()
		$MarginContainer/HBoxContainer.hide()

func _ready():
	update_Icon()

func _process(_delta):
	update_Icon()
	if get_parent().name == "MainMenu":
		hide_all()
	elif get_parent().name == "Control":
		# Maybe check this after done loading the main menu scene?
		var player = get_node('/root/Scene/Player')
		update_visibility_and_text(WASD, controller_AnalogL, true, "Move")
		
		#--------------------------------------PLAYER CONTROL DISABLED------------------------------------------------
		
		if player.player_lockInput and player.player_interactedItem_Temp != null:
			hide_all()
			if player.player_interactedItem_Temp.id == "shop" and get_viewport().gui_get_focus_owner() != null:
				update_visibility_and_text(null, controller_B, true, "Close Shop")
				if get_node("/root/Scene/UI/Control/Shop").reroll_price <= 50:
					update_visibility_and_text(null, controller_Y, true, "Reroll Item")
				if Function.search_regex("Item", get_viewport().gui_get_focus_owner().name):
					update_visibility_and_text(E, controller_A, true, "Buy Item")
					if get_viewport().gui_get_focus_owner().get_parent().name == "ShopItem" and get_node("/root/Scene/UI/Control/Shop").storage_itemList.get_child_count() < 4:
						update_visibility_and_text(C, controller_X, true, "Store Blueprint")
				elif get_viewport().gui_get_focus_owner().name == "RerollButton":
					if get_node("/root/Scene/UI/Control/Shop").reroll_price <= 50:
						update_visibility_and_text(E, controller_A, true, "Reroll Item")
					update_visibility_and_text(C, controller_X, false)
				elif get_viewport().gui_get_focus_owner().name == "CloseButton":
					update_visibility_and_text(E, controller_A, true, "Close Shop")
					update_visibility_and_text(C, controller_X, false)
			if Function.search_regex("mortar", player.player_interactedItem_Temp.id):
				if !Global.preparation_phase:
					update_visibility_and_text(E, controller_A, true, "Shoot Mortar")
				update_visibility_and_text(V, controller_B, true, "Quit Aiming Mode")
				update_visibility_and_text(WASD, controller_AnalogL, true, "Aim Mortar")
				
		#--------------------------------------PREPARATION PHASE------------------------------------------------
		elif Global.preparation_phase:
			
			#------------ E INPUT / INTERACT ------------
			#DEFAULT STATE -> HIDE
			if !player.player_ableInteract and !player.player_isHoldingItem:
				update_visibility_and_text(E, controller_A, false)
			#PICK ITEM
			elif player.player_ableInteract and !player.player_isHoldingItem:
				update_visibility_and_text(E, controller_A, true, "Pick up")
			#DROP ITEM
			elif !player.player_ableInteract and player.player_isHoldingItem:
				update_visibility_and_text(E, controller_A, true, "Drop")
			#SWAP ITEM
			elif player.player_ableInteract and player.player_isHoldingItem:
				update_visibility_and_text(E, controller_A, true, "Swap")
				
			#------------ C INPUT / INSPECT ------------
			#DEFAULT STATE -> HIDE
			if !player.player_ableInteract:
				update_visibility_and_text(C, controller_X, false)
			#INSPECT
			elif player.player_ableInteract and !player.player_isHoldingItem and !player.player_interactedItem_Temp.has_method("mount"):
				if player.player_interactedItem_Temp.id != "shop":
					update_visibility_and_text(C, controller_X, true, "Inspect")
			#OPEN SHOP
				else:
					update_visibility_and_text(C, controller_X, true, "Open Shop")
			#MOUNT
			elif player.player_interactedItem_Temp != null:
				if player.player_interactedItem_Temp.has_method("mount"):
					if player.player_isHoldingItem and player.player_interactedItem_Temp.currently_mountable_item == null:
						update_visibility_and_text(C, controller_X, true, "Mount")
			#DISMOUNT
					elif !player.player_isHoldingItem and player.player_interactedItem_Temp.currently_mountable_item != null:
						update_visibility_and_text(C, controller_X, true, "Dismount")
			
			#------------ X INPUT / CHECK ------------
			# DEFAULT STATE -> HIDE
			if !player.player_ableInteract and !player.player_isHoldingItem:
				update_visibility_and_text(X, controller_Y, false)
			#MOUNTED TURRET
			elif player.player_interactedItem_Temp.has_method("mount"):
				if !player.player_isHoldingItem and player.player_interactedItem_Temp.is_mountable_occupied:
					update_visibility_and_text(X, controller_Y, true, "Check Area")
			#ON HEAD TURRET
			elif !player.player_ableInteract and player.player_isHoldingItem:
				if Function.search_regex("turret", player.player_interactedItem.id):
					update_visibility_and_text(X, controller_Y, true, "Check Area")
			#GROUND TURRET
			elif player.player_ableInteract and !player.player_isHoldingItem:
				if Function.search_regex("turret", player.player_interactedItem_Temp.id) or Function.search_regex("mortar", player.player_interactedItem_Temp.id):
					update_visibility_and_text(X, controller_Y, true, "Check Area")
			
			
			#------------ V INPUT / ROTATE ------------
			#DEFAULT STATE -> HIDE
			if !player.player_ableInteract and !player.player_isHoldingItem:
				update_visibility_and_text(V, controller_B, false)
			#ROTATE HOLDED ITEM OR INTERACTABLE ITEM / TARGETED ITEM
			elif (player.player_isHoldingItem or player.player_ableInteract) and !Function.search_regex("wall", player.player_interactedItem_Temp.id):
				if Function.search_regex("mortar", player.player_interactedItem_Temp.id):
					if player.player_ableInteract and !player.player_isHoldingItem:
						update_visibility_and_text(V, controller_B, true, "Enter Aiming Mode")
					else:
						update_visibility_and_text(V, controller_B, false)
				else:
					update_visibility_and_text(V, controller_B, true, "Rotate")
			#ROTATE MOUNTED ITEM
			elif player.player_interactedItem_Temp.id == "wall_mountable" and player.player_interactedItem_Temp.get_child(-1).is_class("StaticBody3D"):
				update_visibility_and_text(V, controller_B, true, "Rotate")
			
			#------------ SPACE INPUT / READY ------------
			update_visibility_and_text(Space, controller_Start, true, "Start Wave")
				
		#--------------------------------------DEFENSE PHASE------------------------------------------------
		elif !Global.preparation_phase :
			#------------ E INPUT / INSPECT ------------
			#DEFAULT STATE -> HIDE
			if !player.player_ableInteract:
				update_visibility_and_text(E, controller_A, false)
			#RELOAD TURRET
			elif player.player_ableInteract and player.player_isHoldingItem and player.player_interactedItem_Temp.has_method("reload") and player.player_holdedMats == "ammo_box":
				if player.player_interactedItem_Temp.bullet_ammo != player.player_interactedItem_Temp.bullet_maxammo:
					update_visibility_and_text(E, controller_A, true, "Reload Turret")
			# Player not holding any item
			elif player.player_ableInteract and !player.player_isHoldingItem:
				match player.player_interactedItem_Temp.id:
					"gunpowder_box":
						update_visibility_and_text(E, controller_A, true, "Pick up Gunpowder")
					"bullet_box":
						update_visibility_and_text(E, controller_A, true, "Pick up Bullet")
					"crafter":
						if player.player_interactedItem_Temp.prod_ammo_box > 0:
							update_visibility_and_text(E, controller_A, true, "Pick up Ammo")
			# Player is holding item
			elif player.player_ableInteract and player.player_isHoldingItem:
				match player.player_interactedItem_Temp.id:
					"gunpowder_box":
						if player.player_holdedMats == "gunpowder_box":
							update_visibility_and_text(E, controller_A, true, "Drop Gunpowder")
					"bullet_box":
						if player.player_holdedMats == "bullet_box":
							update_visibility_and_text(E, controller_A, true, "Drop Bullet")
					"crafter":
						if player.player_holdedMats == "gunpowder_box":
							update_visibility_and_text(E, controller_A, true, "Add Gunpowder")
						elif player.player_holdedMats == "bullet_box":
							update_visibility_and_text(E, controller_A, true, "Add Bullet")
					"drone_base":
						if player.player_holdedMats == "ammo_box":
							update_visibility_and_text(E, controller_A, true, "Add Ammo")
			#------------ C INPUT / INSPECT ------------
			#DEFAULT STATE -> HIDE
			if !player.player_ableInteract:
				update_visibility_and_text(C, controller_X, false)
			#INSPECT
			elif player.player_ableInteract and !player.player_isHoldingItem and !player.player_interactedItem_Temp.has_method("mount"):
				if player.player_interactedItem_Temp.id != "shop":
					update_visibility_and_text(C, controller_X, true, "Inspect")
			#------------ V INPUT / INSPECT ------------
			if player.player_ableInteract and Function.search_regex("mortar", player.player_interactedItem_Temp.id):
				update_visibility_and_text(V, controller_B, true, "Enter Aiming Mode")
			# DEFAULT STATE -> HIDE
			else:
				update_visibility_and_text(V, controller_B, false)
			#------------ SPACE INPUT / READY ------------
			update_visibility_and_text(Space, controller_Start, false)

func hide_all():
	# Keyboard
	E.hide()
	C.hide()
	V.hide()
	X.hide()
	Space.hide()
	WASD.hide() # When does this change visibility to true?
	# Controller
	controller_A.hide() # E keyboard
	controller_B.hide() # V keyboard
	controller_X.hide() # C keyboard
	controller_Y.hide() # X keyboard
	controller_Start.hide()
	controller_AnalogL.hide() # When does this change visibility to true?

func update_visibility_and_text(keyboard_keys, controller_button, visibility: bool, text: String = ""):
	if visibility:
		if keyboard_keys != null:
			keyboard_keys.show()
			match keyboard_keys:
				WASD:
					text_WASD.text = text
				E:
					text_E.text = text
				C:
					text_C.text = text
				V:
					text_V.text = text
				X:
					text_X.text = text
				Space:
					text_Space.text = text
		if controller_button != null:
			controller_button.show()
			match controller_button:
				controller_AnalogL:
					text_controller_AnalogL.text = text
				controller_A:
					text_controller_A.text = text
				controller_B:
					text_controller_B.text = text
				controller_X:
					text_controller_X.text = text
				controller_Y:
					text_controller_Y.text = text
				controller_Start:
					text_controller_Start.text = text
	else:
		if keyboard_keys != null:
			keyboard_keys.hide()
		if controller_button != null:
			controller_button.hide()
	
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
	#Update X Icon
	var key_X = InputMap.action_get_events("check")[0].as_text().trim_suffix(" (Physical)")
	icon_X.texture = load("res://assets/icon/KeyboardButton/"+ str(key_X) +"_light.png")
	#Update Space Icon
	var key_Space = InputMap.action_get_events("start")[0].as_text().trim_suffix(" (Physical)")
	icon_Space.texture = load("res://assets/icon/KeyboardButton/"+ str(key_Space) +"_light.png")
