extends Control

@onready var player = get_node('/root/Node3D/Player')

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


func _process(_delta):
	if get_parent().name == "MainMenu":
		E.hide()
		C.hide()
		V.hide()
		Space.hide()
	
	elif get_parent().name == "Control":
		#--------------------------------------PREPARATION PHASE------------------------------------------------
		if Global.preparation_phase:
			#------------ E INPUT / INTERACT------------
			#DEFAULT STATE -> HIDE
			if !player.player_ableInteract and !player.player_isHoldingItem:
				E.hide()
			#PICK ITEM
			elif player.player_ableInteract and !player.player_isHoldingItem:
				text_E.text = "Pick up"
				E.show()
			#DROP ITEM
			elif !player.player_ableInteract and player.player_isHoldingItem:
				text_E.text = "Drop"
				E.show()
			#SWAP ITEM
			elif player.player_ableInteract and player.player_isHoldingItem:
				text_E.text = "Swap"
				E.show()
			
			#------------ C INPUT / INSPECT ------------
			#DEFAULT STATE -> HIDE
			if !player.player_ableInteract:
				C.hide()
			#INSPECT
			elif player.player_ableInteract and !player.player_isHoldingItem and !player.player_interactedItem_Temp.has_method("mount"):
				if player.player_interactedItem_Temp.id != "shop":
					text_C.text = "Inspect"
					C.show()
			#OPEN SHOP
				else:
					text_C.text = "Open Shop"
					C.show()
					
			#MOUNT
			elif player.player_interactedItem_Temp != null:
				if player.player_interactedItem_Temp.has_method("mount"):
					if player.player_isHoldingItem and player.player_interactedItem_Temp.currently_mountable_item == null:
						text_C.text = "Mount"
						C.show()
			#DISMOUNT
					elif !player.player_isHoldingItem and player.player_interactedItem_Temp.currently_mountable_item != null:
						text_C.text = "Dismount"
						C.show()
			
			#------------ V INPUT / ROTATE ------------
			#DEFAULT STATE -> HIDE
			if !player.player_ableInteract and !player.player_isHoldingItem:
				V.hide()
			#ROTATE HOLDED ITEM OR INTERACTABLE ITEM / TARGETED ITEM
			elif (player.player_isHoldingItem or player.player_ableInteract) and !Function.search_regex("wall", player.player_interactedItem_Temp.id):
				text_V.text = "Rotate"
				V.show()
			#ROTATE MOUNTED ITEM
			elif player.player_interactedItem_Temp.id == "wall_mountable" and player.player_interactedItem_Temp.get_child(-1).is_class("StaticBody3D"):
				text_V.text = "Rotate"
				V.show()
			
			#------------ SPACE INPUT / READY ------------
			text_Space.text = "Ready"
			Space.show()
				
		#--------------------------------------DEFENSE PHASE------------------------------------------------
		elif !Global.preparation_phase :
			#------------ E INPUT / INSPECT ------------
			E.hide()
			#------------ C INPUT / INSPECT ------------
			#DEFAULT STATE -> HIDE
			if !player.player_ableInteract:
				C.hide()
			#INSPECT
			elif player.player_ableInteract and !player.player_isHoldingItem and !player.player_interactedItem_Temp.has_method("mount"):
				if player.player_interactedItem_Temp.id != "shop":
					text_C.text = "Inspect"
					C.show()
			#------------ V INPUT / INSPECT ------------
			V.hide()
			#------------ SPACE INPUT / READY ------------
			Space.hide()

