extends CharacterBody3D

const SPEED = 300.0
const JUMP_VELOCITY = 4.5

var id = "player"

@onready var scene = get_node('/root/Scene')
@onready var holded_item = %"Holded Item"
@onready var parent_item = get_node('/root/Scene/World/NavigationRegion3D/Item') # All items location
#@onready var inspectedItem_UI_Sprite = get_node('/root/Scene/UI/InspectedItemUI3D')
#@onready var inspectedItem_UIOLD = get_node('/root/Scene/UI/InspectedItemUI3D/SubViewport/InspectedItemUI')
@onready var inspectedItem_UI = get_node('/root/Scene/UI/Control/InspectedItemUI')
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var player_ableInteract: bool = false
var player_isHoldingItem: bool = false
var player_ableToDrop: bool = true # Check interaction area of player is it able to drop something there?
var player_inspectedItem
var player_interactedItem
var player_interactedItem_Temp

var player_holdedMats: String

var player_lockInput: bool = false

var player_lastButtonFocused

func _physics_process(delta):

	if player_lastButtonFocused != null:
		player_lastButtonFocused.grab_focus()
		player_lastButtonFocused = null
	
	DEBUG_turret_targeting_DEBUG()
	
	# navigation.bake_navigation_mesh()
	# for the player to be on ground via gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	# Equal to keyboard WASD and controller Stick Left analog and dpad
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED * delta 
		velocity.z = direction.z * SPEED * delta 
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if !player_lockInput: # Which mean if enable this thing will not be processed
		move_and_slide()
		player_model()
		open_shop()
		mountable_wall()
		player_InteractItems()
		player_CheckItems()
		#player_InspectItemsArea()
		player_RotateItems()
	player_rotation(direction)
	player_interactionZoneProcess()
	player_placementPreviewProcess()
	ready()
	esc()

func DEBUG_turret_targeting_DEBUG():
	if player_interactedItem_Temp != null:
		if Input.is_action_just_pressed("debug+"):
			if Function.search_regex("turret", player_interactedItem_Temp.id):
				player_interactedItem_Temp.update_target_priority()
			elif player_interactedItem_Temp.id == "wall_mountable" and player_interactedItem_Temp.is_mountable_occupied:
				player_interactedItem_Temp.currently_mountable_item.update_target_priority()
		if Input.is_action_just_pressed("debug-"):
			if Function.search_regex("turret", player_interactedItem_Temp.id):
				player_interactedItem_Temp.check_target_priority()
			elif player_interactedItem_Temp.id == "wall_mountable" and player_interactedItem_Temp.is_mountable_occupied:
				player_interactedItem_Temp.currently_mountable_item.check_target_priority()

func _ready():
	# Stop the audio temporary
	$Audio/MoveSfx.stream_paused = true
	# Hide all the ingredient icons (being used in defense phase)
	$"Node3D/Ingredient Item/Ingredient Sprite".hide()

func open_shop():
	if player_interactedItem_Temp != null:
		# Open shop action
		if player_interactedItem_Temp.name == "Shop" and Input.is_action_just_pressed("inspect") and Global.preparation_phase == true:
			get_node('/root/Scene/UI/Control/Shop').show()
			player_lockInput = true
			get_node('/root/Scene/UI/Control/Shop/PanelContainer2/MarginContainer/HBoxContainer/CloseButton').grab_focus()
		# Sell item action
		elif player_interactedItem_Temp.name == "Sell" and Input.is_action_just_pressed("inspect") and player_isHoldingItem and Global.preparation_phase == true:
			# Item list in Global.sellable_item
			# And make sure all the item have sell price, beucase it will be needed for calculation
			for sellable_item_check in Global.sellable_item:
				if Function.search_regex(sellable_item_check, player_interactedItem.id):
					inspectedItem_UI.hide()
					player_checkItemRange(player_interactedItem, false)
					player_interactedItem_Temp.sell(player_interactedItem)
					player_lockInput = true

func mountable_wall():
	# This check for preparation phase, if true then this process will be accessible
	if player_interactedItem_Temp != null and Global.preparation_phase: # Check wall_mountable
		if player_interactedItem_Temp.has_method("mount") and Input.is_action_just_pressed("inspect"): # check for wall_mountable function
			if player_ableInteract and player_isHoldingItem and player_interactedItem_Temp.currently_mountable_item == null:
				player_interactedItem_Temp.mount(true)
				player_interactedItem = null
			elif player_ableInteract and !player_isHoldingItem and player_interactedItem_Temp.currently_mountable_item != null:
				player_interactedItem_Temp.mount(false)
				# This to disable continous area check when dismounted
				player_inspectedItem = player_interactedItem
				player_checkItemRange(player_inspectedItem, false)

func player_interactionZoneProcess():
	$"Node3D/Interaction Zone/CollisionShape3D".global_position = check_grid(%"Interaction Zone", $"Node3D/Interaction Zone/CollisionShape3D")

func default_state(): # this being called by scene to reset the player state
	player_ableInteract = false
	player_isHoldingItem = false
	player_interactedItem_Temp = null
	player_holdedMats = ""
	player_checkIngredientItem()

func ready():
	if Input.is_action_just_pressed("start"):
		scene.request_defense_phase(self)
	
func esc():
	if Input.is_action_just_pressed("exit"):
		player_lastButtonFocused = get_viewport().gui_get_focus_owner()
		scene.pause()

func player_rotation(direction):
	if direction != Vector3.ZERO and !player_lockInput:
		var target_rotation = atan2(direction.x, direction.z) - PI / 2
		# more of math wizardry, last param in lerp_angle() determine how fast the character rotate
		$Node3D.rotation.y = lerp_angle($Node3D.rotation.y, target_rotation, 0.25)
		$Audio/MoveSfx.stream_paused = false
	else:
		$Audio/MoveSfx.stream_paused = true
	# rotation of items are being modified by this code while being held on hand
	# and repaired back to grid by check_grid()

func player_model():
	var modelHand_Tween = get_tree().create_tween()
	if player_ableInteract and (Input.is_action_just_pressed("check") or Input.is_action_just_pressed("inspect") or Input.is_action_just_pressed("rotate")):
		# This tween is being replaced by if-statement below, therefore only show a little hand movement
		modelHand_Tween.tween_property($Node3D/Models/Hand, "rotation_degrees", Vector3(-53.4, 0, 0), 0.1)
	if player_isHoldingItem:
		modelHand_Tween.tween_property($Node3D/Models/Hand, "rotation_degrees", Vector3(0, 0, 0), 0.1)
		#$Node3D/Models/Hand.rotation.x = lerp_angle($Node3D/Models/Hand.rotation.x, 0.0, 0.1)
	else:
		modelHand_Tween.tween_property($Node3D/Models/Hand, "rotation_degrees", Vector3(53.4, 0, 0), 0.1)
		#$Node3D/Models/Hand.rotation_degrees.x = 53.4

func audio_randomSelector(path, volume: int = 0):
	var Sfx = path.get_children() # path to where the audio childern are
	var SfxPicker = Sfx[randi() % Sfx.size()]
	SfxPicker.volume_db = volume
	SfxPicker.pitch_scale = randf_range(0.9, 1.1)
	SfxPicker.play()

func check_grid(import_pos, export_pos):
	# read the docs more, round() function is just what we want, it round .5 to up
	# could be done directly in-line because this support vector3
	# export_pos.position.x = round(import_pos.global_position.x) # X-AXIS
	var x = round(import_pos.global_position.x)
	# The Y-AXIS is depend on how the %"Interaction Zone" placement is in the world. before it was 1.501, now it is 1.33
	# export_pos.position.y = round(import_pos.global_position.y) # Y-AXIS (sometimes messed up by the character interact area)
	var y = round(import_pos.global_position.y)
	# export_pos.position.z = round(import_pos.global_position.z) # Z-AXIS
	var z = round(import_pos.global_position.z)
	# disable janky item rotation when held by player to align with grid
	if export_pos.is_class("StaticBody3D"): # Bad design of code, check wall property somewhere else?
			if Function.search_regex("wall", export_pos.id):
				export_pos.rotation_degrees.y = 0 # Dont move my walls!
			else:
				export_pos.rotation_degrees.y = round(export_pos.rotation_degrees.y / 90.0) * 90.0
	else:
		# align into nearest 90 degree from current itself rotation_degrees (maybe tween this into animation?)
		export_pos.rotation_degrees.y = round(export_pos.rotation_degrees.y / 90.0) * 90.0
	# export_pos.rotation.y = 0 # this is being applied instantly
	# Return the value in vector3 for future processing by tweens
	return Vector3(x, y, z)

func player_placementPreviewProcess():
	# This is the essential process function for player_placementPreview()
	if %"Placement Item".get_child_count() > 0:
		%"Placement Item".get_child(0).process_mode = PROCESS_MODE_DISABLED # Need to be executed here, the player_placementPreview function cannot handle the request
		# Blue material when able to drop items or (unique) place item on top of mounted wall 
		if player_ableToDrop and !player_ableInteract or (player_ableInteract and player_interactedItem_Temp.has_method("mount") and Function.search_regex("turret", %"Placement Item".get_child(0).id)):
			player_placementPreviewMaterial(%"Placement Item".get_child(0), "blue")
		# Red material when cannot drop item or going to swap
		elif !player_ableToDrop or player_ableInteract:
			player_placementPreviewMaterial(%"Placement Item".get_child(0), "red")
		# Check grid location for preview item
		if player_interactedItem_Temp != null:
			if player_interactedItem_Temp.has_method("mount") and Function.search_regex("turret", %"Placement Item".get_child(0).id) and player_ableInteract: # Unique cases for turret mounting preview
				%"Placement Item".get_child(0).global_position = check_grid(%"Interaction Zone", %"Placement Item".get_child(0)) + Vector3(0, 1, 0)
			else: # Every cases will follow this normal check grid
				%"Placement Item".get_child(0).global_position = check_grid(%"Interaction Zone", %"Placement Item".get_child(0))
		else:
			%"Placement Item".get_child(0).global_position = check_grid(%"Interaction Zone", %"Placement Item".get_child(0))
		# Take on-hand item rotation and applied it to preview-item (there will always be on-hand item when we run the preview process!)
		%"Placement Item".get_child(0).global_rotation_degrees.y = round(%"Holded Item".get_child(-1).global_rotation_degrees.y / 90.0) * 90.0

func player_placementPreviewMaterial(node, color):
	if node.has_node("Models"):
		# Loop for each item in models to change the materials
		var item_temp_models = node.get_node("Models")
		var item_preview_material
		match color:
			"blue":
				item_preview_material = load("res://assets/shaders/blue_opacity.tres")
			"red":
				item_preview_material = load("res://assets/shaders/red_opacity.tres")
		for models in item_temp_models.get_children():
			if models is MeshInstance3D: # Savekeeping just in case, but anything in models node should be mesh!
				models.material_override = item_preview_material
				# Unique cases for nested "Head", "Body", "Spike"
			elif models is Node3D and (models.name == "Head" or models.name == "Body" or models.name == "Spike" or models.name == "Drone"):
				for child_models in models.get_children():
					if child_models is MeshInstance3D:
						child_models.material_override = item_preview_material
					# Really fucking nested "HeadModels" that only seen in Turrets
					elif child_models is Node3D and child_models.name == "HeadModels":
						for grandchild_models in child_models.get_children():
							if grandchild_models is MeshInstance3D:
								grandchild_models.material_override = item_preview_material

func player_placementPreview(enable: bool):
	# To be able to return the preview blueprint, the items scene need to be setup properly with meshes with parent node name "Models"
	# If not then this will not return the preview blueprint materials, but instead the item itself (without any modification as preview)
	# This function is embbeded in: player_heldItem(), player_putItem(), player_swapItem(), and mountable_wall chenanigans
	if enable:
		#print("Creating preview for "+ str(player_interactedItem.id))
		var path_temp: String = "res://scene/"+str(player_interactedItem.id)+".tscn"
		var item_temp = load(path_temp).instantiate()
		# Check if the scene have "Models" node inside
		%"Placement Item".add_child(item_temp, true)
	if !enable:
		#print("Deleteing preview belong to "+ str(player_interactedItem.id))
		match %"Placement Item".get_child(0).id:
			"extra_health": # Unique cases for "extra_health" since it need to call destroy() function
				%"Placement Item".get_child(0).destroy()
		%"Placement Item".get_child(0).queue_free()

func player_holdItem(item) -> void: # need to return something so the last timer didnt stop prematurely
	$Audio/SelectSfx.play()
	player_placementPreview(true)
	#inspectedItem_UI_Sprite.hide()
	item.reparent(holded_item, true) # Change the item parent into `%"Holded Item"` which reside in player node
	item.set_collision_layer_value(1, false) # Remove the collision layer from the item while being held in-hand
	#item.position = Vector3(0.5, 1, 0) # Set item position to be on top of player
	var holdItem_Tween = get_tree().create_tween()
	holdItem_Tween.tween_property(item, "position", Vector3(0.5, 1, 0), 0.15)
	# this TIMER is IMPORTANT because it wait for the tween animation to finish
	# WILL BE REOCCURING BUG - where item glitches from %Item.position to new position

func player_putItem(item):
	$Audio/SelectSfx.play()
	player_placementPreview(false)
	#inspectedItem_UI_Sprite.hide()
	item.reparent(parent_item, true) # Change the item parent into `%Item` node
	#item.set_collision_layer_value(1, true) # Enable the collision layer of the item
	# Check the grid of item when putting down to the world
	var putItem_Tween = get_tree().create_tween()
	putItem_Tween.tween_property(item, "position", check_grid(%"Interaction Zone", item), 0.15)
	#item.position = check_grid(%"Interaction Zone", item)
	await get_tree().create_timer(0.15).timeout
	item.set_collision_layer_value(1, true)

func player_swapItem(held_item, ground_item):
	player_placementPreview(false)
	#inspectedItem_UI_Sprite.hide()
	held_item.reparent(parent_item, true) 
	held_item.set_collision_layer_value(1, true)
	held_item.position = ground_item.position # Swap the position property from held item to ground item
	held_item.rotation.y = 0 # Repair the Y-AXIS rotation to default

func player_rotateItemProcess():
	if player_isHoldingItem:
		if player_interactedItem.id != "mortar":
			# rotate in-hand item
			# since this item in in hand it will need to pass grid_check() function
			print("Rotating on-hand " + str(player_interactedItem) + " to " + str(player_interactedItem.rotation_degrees))
			player_interactedItem.rotation_degrees += Vector3(0, 90, 0)
			audio_randomSelector($Audio/Pop, -10)
	elif !player_isHoldingItem and player_ableInteract and player_interactedItem_Temp != null:
		# rotate on-ground item
		player_interactedItem = player_interactedItem_Temp
		if Function.search_regex("wall", player_interactedItem.id):
			if player_interactedItem.id == "wall_mountable" and player_interactedItem.is_mountable_occupied:
				player_interactedItem.currently_mountable_item.rotation_degrees += Vector3(0, 90, 0)
				audio_randomSelector($Audio/Pop, -10)
			pass # Dont move my wall!
		else:
			player_interactedItem.rotation_degrees += Vector3(0, 90, 0)
			print("Rotating on-ground " + str(player_interactedItem) + " to " + str(player_interactedItem.rotation_degrees))
			audio_randomSelector($Audio/Pop, -10)

func player_checkItemRange(item, enable: bool = true):
	print(item, enable)
	#var regex = RegEx.new() # need to add some regex to check for all the name id of turret
	#var pattern = r"^(?i)turret.*$" # for example all turret name start with 'turret_name_affix_suffix_whatever'
	#regex.compile(pattern) d# check for match regex on 'turret' and be happy
	# if by any-case you want to check more than just turret, add new pattern to be checked and refactor this code into match maybe
	if enable:
		if Function.search_regex("turret", item.id) or Function.search_regex("mortar", item.id) or Function.search_regex("wall_spiked", item.id) or Function.search_regex("enhancement", item.id) or Function.search_regex("drone_station", item.id):
			item.visible_range.show()
		elif Function.search_regex("wall_mountable", item.id) and item.is_mountable_occupied:
			item.currently_mountable_item.visible_range.show()
	else:
		if Function.search_regex("turret", item.id) or Function.search_regex("mortar", item.id) or Function.search_regex("wall_spiked", item.id) or Function.search_regex("enhancement", item.id) or Function.search_regex("drone_station", item.id):
			item.visible_range.hide()
		elif Function.search_regex("wall_mountable", item.id) and item.is_mountable_occupied:
			item.currently_mountable_item.visible_range.hide()

func player_checkIngredientItem():
	# Future rework to cast the texture icon directly to Sprite3D
	match player_holdedMats:
		"":
			$"Node3D/Ingredient Item/Ingredient Sprite".hide()
		"ammo_box":
			$"Node3D/Ingredient Item/Ingredient Sprite".texture = load("res://assets/icon/ammo-box.png")
			$"Node3D/Ingredient Item/Ingredient Sprite".show()
		"gunpowder_box":
			$"Node3D/Ingredient Item/Ingredient Sprite".texture = load("res://assets/icon/powder.png")
			$"Node3D/Ingredient Item/Ingredient Sprite".show()
		"bullet_box":
			$"Node3D/Ingredient Item/Ingredient Sprite".texture = load("res://assets/icon/shotgun-rounds.png")
			$"Node3D/Ingredient Item/Ingredient Sprite".show()

func player_InteractItems():
	#================================================ PREPARATION PHASE ==================================================================================================
	if Global.preparation_phase:
		# PICK UP ITEM - NOT HOLDING item and HAVE INTERACTABLE item
		if player_ableInteract == true and player_isHoldingItem == false and Input.is_action_just_pressed("interact"):
			player_isHoldingItem = true
			# When the player decided to interact with the current item `player_interactedItem_Temp` (which always changing depend on the circumstance)
			# It will save the `player_interactedItem_Temp` into `player_interactedItem` to be used
			player_interactedItem = player_interactedItem_Temp
			player_holdItem(player_interactedItem)
			print("Pick-up " + str(player_interactedItem) + " from " + str(player_interactedItem.position))
			# Maybe not needed because if item is moved over character's head
			# Then interaction zone body exited will triggered to change player_ableInteract to false
			player_ableInteract = false
			
		# DROP DOWN ITEM - HOLDING an item and NOT INTERACTING with other items
		elif player_ableInteract == false and player_isHoldingItem == true and player_ableToDrop == true and Input.is_action_just_pressed("interact"):
			# Should change the name of item placeholder into someting more unique, for now it stand as %Item
			player_putItem(player_interactedItem)
			print("Dropping " + str(player_interactedItem) + " to " + str(player_interactedItem.position))
			# print(%"Interaction Zone".global_position)
			# print(player_interactedItem.position)
			player_isHoldingItem = false
			player_interactedItem = null
			
		# SWAP ITEM - HOLDING an items and HAVE INTERACTABLE item
		elif player_ableInteract == true and player_isHoldingItem == true and player_ableToDrop == true and Input.is_action_just_pressed("interact"):
			print("Swapping " + str(player_interactedItem) + " with " + str(player_interactedItem_Temp))
			# All this line is the basic for item swapping
			# Swap held item property to on-ground item property
			player_swapItem(player_interactedItem, player_interactedItem_Temp)
			# Take on-ground item
			player_interactedItem = player_interactedItem_Temp
			print("Now holding " + str(player_interactedItem) + " as result from swapping item")
			player_holdItem(player_interactedItem)
			
	#================================================ DEFENSE PHASE ==================================================================================================
	elif !Global.preparation_phase:
		# SHOOT MORTAR
		if player_ableInteract == true and Input.is_action_just_pressed("interact") and player_interactedItem_Temp.has_method("controlled"):
			player_interactedItem_Temp.shoot()
		# RELOAD TURRET - HOLDING an AMMO and HAVE INTERACTABLE TURRET
		if player_ableInteract == true and player_isHoldingItem == true and Input.is_action_just_pressed("interact") and player_interactedItem_Temp.has_method("reload") and player_holdedMats == "ammo_box":
			if player_interactedItem_Temp.bullet_ammo != player_interactedItem_Temp.bullet_maxammo and !player_interactedItem_Temp.requesting_droneReload:
				print("Reloading ", player_interactedItem_Temp)
				player_interactedItem_Temp.reload()
				player_isHoldingItem = false
				player_holdedMats = ""
				player_checkIngredientItem()
		# RELOAD MOUNTED TURRET - HOLDING an AMMO and HAVE MOUNTED WALL that have turret in it
		if player_ableInteract == true and player_isHoldingItem == true and Input.is_action_just_pressed("interact") and player_interactedItem_Temp.has_method("mount") and player_holdedMats == "ammo_box":
			if player_interactedItem_Temp.currently_mountable_item.has_method("reload"):
				if player_interactedItem_Temp.currently_mountable_item.bullet_ammo != player_interactedItem_Temp.currently_mountable_item.bullet_maxammo and !player_interactedItem_Temp.currently_mountable_item.requesting_droneReload:
					print("Reloading mounted ", player_interactedItem_Temp.currently_mountable_item, " on ", player_interactedItem_Temp)
					player_interactedItem_Temp.currently_mountable_item.reload()
					player_isHoldingItem = false
					player_holdedMats = ""
					player_checkIngredientItem()
		# PICK UP INGREDIENT
		elif player_ableInteract == true and player_isHoldingItem == false and Input.is_action_just_pressed("interact") and !Function.search_regex("turret", player_interactedItem_Temp.id):
			if player_interactedItem_Temp.id == "gunpowder_box":
				player_holdedMats = "gunpowder_box"
				player_isHoldingItem = true
				player_checkIngredientItem()
				player_ableInteract = false
				print("Picked up ", player_holdedMats)
			elif player_interactedItem_Temp.id == "bullet_box":
				player_holdedMats = "bullet_box"
				player_isHoldingItem = true
				player_checkIngredientItem()
				player_ableInteract = false
				print("Picked up ", player_holdedMats)
			elif player_interactedItem_Temp.id == "crafter":
				player_interactedItem_Temp.get_product()
				player_checkIngredientItem()
			elif player_interactedItem_Temp.id == "conveyor" or player_interactedItem_Temp.id == "conveyor_grabber":
				if !player_interactedItem_Temp.inv.is_empty():
					player_holdedMats = player_interactedItem_Temp.takeItem()
					player_isHoldingItem = true
					player_checkIngredientItem()
					player_ableInteract = false
		
		# DROP INGREDIENT
		elif player_ableInteract == true and player_isHoldingItem == true and player_ableToDrop == true and Input.is_action_just_pressed("interact"):
			if player_holdedMats == player_interactedItem_Temp.id:
				print("Dropped back ", player_holdedMats)
				player_isHoldingItem = false
				player_holdedMats = ""
				player_checkIngredientItem()
			elif player_interactedItem_Temp.id == "crafter":
				player_interactedItem_Temp.get_ingredient(player_holdedMats)
				player_checkIngredientItem()
				#CHANGE CRAFTER VARIABLE
			elif player_interactedItem_Temp.id == "drone_station" and player_holdedMats == "ammo_box":
				player_interactedItem_Temp.add_ammoToBase()
				player_checkIngredientItem()
			elif player_interactedItem_Temp.id == "conveyor" or player_interactedItem_Temp.id == "conveyor_grabber":
				if player_interactedItem_Temp.inv.is_empty():
					player_interactedItem_Temp.recieveItem(player_holdedMats)
					player_isHoldingItem = false
					player_holdedMats = ""
					player_checkIngredientItem()

func player_CheckItems():
	# This show the player card-like information about item, will be immediately turn off if player do any action
	# Add more information but in text-type to some items? maybe make a new UI3D for that?
	if Input.is_action_just_pressed("check") and (player_ableInteract or player_isHoldingItem):
		if player_isHoldingItem:
			player_inspectedItem = player_interactedItem
		else:
			player_inspectedItem = player_interactedItem_Temp
		player_checkItemRange(player_inspectedItem, true)
		#player_inspectedItem = player_interactedItem_Temp
		#player_checkItemRange(player_inspectedItem, true)
		#var sprite_adjustment = Vector3(0, 2, 0) #Vector3(0, 2, -1.5)
		#inspectedItem_UI_Sprite.global_position = player_inspectedItem.global_position + sprite_adjustment
		if "attack_damage" in player_inspectedItem and player_inspectedItem.attack_damage != null:
			inspectedItem_UI.AttackDamageText = str(player_inspectedItem.attack_damage)
			if player_inspectedItem.buff_isEnchanted:
				inspectedItem_UI.AttackDamageText = inspectedItem_UI.AttackDamageText + "+" + str(player_inspectedItem.enchanted_bonus)
		if "attack_range" in player_inspectedItem:
			inspectedItem_UI.AttackRangeText = str(player_inspectedItem.attack_range)
			if player_inspectedItem.id == "mortar":
				inspectedItem_UI.AttackRangeText = str(player_inspectedItem.attack_rangeMin) + "~" + str(player_inspectedItem.attack_rangeMax)
			if player_inspectedItem.id == "wall_spiked":
				inspectedItem_UI.AttackRangeText = "1"
		if "attack_speed" in player_inspectedItem:
			inspectedItem_UI.AttackSpeedText = player_inspectedItem.attack_speed
		if "is_mountable_occupied" in player_inspectedItem:
			if player_inspectedItem.is_mountable_occupied:
				inspectedItem_UI.AttackDamageText = str(player_inspectedItem.currently_mountable_item.attack_damage)
				inspectedItem_UI.AttackRangeText = str(player_inspectedItem.currently_mountable_item.attack_range)
				inspectedItem_UI.AttackSpeedText = str(player_inspectedItem.currently_mountable_item.attack_speed)
				inspectedItem_UI.AmmoText = str(player_inspectedItem.currently_mountable_item.bullet_maxammo)
				if player_inspectedItem.currently_mountable_item.buff_isEnchanted:
					inspectedItem_UI.AttackDamageText = inspectedItem_UI.AttackDamageText + "+" + str(player_inspectedItem.currently_mountable_item.enchanted_bonus)
				if player_inspectedItem.currently_mountable_item.buff_isMounted:
					inspectedItem_UI.AttackRangeText = inspectedItem_UI.AttackRangeText + "+" + str(player_inspectedItem.currently_mountable_item.mounted_bonus)
		if "bullet_maxammo" in player_inspectedItem:
			inspectedItem_UI.AmmoText = str(player_inspectedItem.bullet_maxammo)
		if "bonus_range" in player_inspectedItem and !player_inspectedItem.is_mountable_occupied:
			inspectedItem_UI.AttackRangeBuffText = "+" + str(player_inspectedItem.bonus_range)
		if "bonus_attack" in player_inspectedItem:
			inspectedItem_UI.AttackDamageBuffText = "+" + str(player_inspectedItem.bonus_attack)
		if "base_ammo" in player_inspectedItem:
			inspectedItem_UI.DroneAmmoCapacityText = str(player_inspectedItem.max_ammo)
		inspectedItem_UI.show()
	elif player_inspectedItem != null and player_interactedItem_Temp != null and player_ableInteract == false:
	# player_ableInteract to check the item itself and show the card of it
		# This basically check if the temp is changed or player see 'empty' grid
		if player_inspectedItem != player_interactedItem:
			player_checkItemRange(player_inspectedItem, false)
			inspectedItem_UI.AttackDamageText = null
			inspectedItem_UI.AttackRangeText = null
			inspectedItem_UI.AttackSpeedText = null
			inspectedItem_UI.AmmoText = null
			inspectedItem_UI.AttackDamageBuffText = null
			inspectedItem_UI.AttackRangeBuffText = null
			inspectedItem_UI.DroneAmmoCapacityText = null
			inspectedItem_UI.hide()
		#-------------------------------------------------------------------------------------------------------------------------------------------------
		#if Function.search_regex("turret", player_inspectedItem.id):
			#print("INSPECTED TURRET")
			#if player_inspectedItem.buff_isEnchanted:
				#inspectedItem_UI.AttackDamageText = str(player_inspectedItem.attack_damage) + "+" + str(player_inspectedItem.enchanted_bonus)
			#else:
				#inspectedItem_UI.AttackDamageText = player_inspectedItem.attack_damage
			#if player_inspectedItem.buff_isMounted:
				#inspectedItem_UI.AttackRangeText = str(player_inspectedItem.attack_range) + "+" + str(player_inspectedItem.mounted_bonus)
			#else:
				#inspectedItem_UI.AttackRangeText = player_inspectedItem.attack_range
			#
			##inspectedItem_UI.AttackDamageText = player_inspectedItem.attack_damage
			##inspectedItem_UI.AttackRangeText = player_inspectedItem.attack_range
			#inspectedItem_UI.AttackSpeedText = player_inspectedItem.attack_speed
			#inspectedItem_UI.AmmoText = player_inspectedItem.bullet_maxammo
			#inspectedItem_UI.show()
		#
		#if Function.search_regex("mortar", player_inspectedItem.id):
			#print("INSPECTED MORTAR")
			#if player_inspectedItem.buff_isEnchanted:
				#inspectedItem_UI.AttackDamageText = str(player_inspectedItem.attack_damage) + "+" + str(player_inspectedItem.enchanted_bonus)
			#else:
				#inspectedItem_UI.AttackDamageText = player_inspectedItem.attack_damage
			#inspectedItem_UI.AttackRangeText = str(player_inspectedItem.attack_rangeMin) + "-" + str(player_inspectedItem.attack_rangeMax)
			#inspectedItem_UI.AttackSpeedText = player_inspectedItem.attack_speed
			#inspectedItem_UI.show()
		#
		#match player_inspectedItem.id:
			#"wall_spiked":
				#print("INSPECTED WALL SPIKED")
				#if player_inspectedItem.buff_isEnchanted:
					#inspectedItem_UI.AttackDamageText = str(player_inspectedItem.attack_damage) + "+" + str(player_inspectedItem.enchanted_bonus)
				#else:
					#inspectedItem_UI.AttackDamageText = player_inspectedItem.attack_damage
				#inspectedItem_UI.AttackRangeText = "1"
				#inspectedItem_UI.AttackSpeedText = player_inspectedItem.attack_speed
				#inspectedItem_UI.show()
			## Will mess with player interaction when mounting a turret (showing card of the wall itself and mounting at the same time)
			#"wall_mountable":
				#print("INSPECTED WALL MOUNTABLE")
				#if player_inspectedItem.is_mountable_occupied:
					##if Function.search_regex("turret", player_inspectedItem.get_child(-1).id):
					#
					#if player_inspectedItem.currently_mountable_item.buff_isEnchanted:
						#inspectedItem_UI.AttackDamageText = str(player_inspectedItem.currently_mountable_item.attack_damage) + "+" + str(player_inspectedItem.currently_mountable_item.enchanted_bonus)
					#else:
						#inspectedItem_UI.AttackDamageText = player_inspectedItem.currently_mountable_item.attack_damage
					#
					#if player_inspectedItem.currently_mountable_item.buff_isMounted:
						#inspectedItem_UI.AttackRangeText = str(player_inspectedItem.currently_mountable_item.attack_range) + "+" + str(player_inspectedItem.currently_mountable_item.mounted_bonus)
					#else:
						#inspectedItem_UI.AttackRangeText = player_inspectedItem.currently_mountable_item.attack_range
						#
					#inspectedItem_UI.AttackSpeedText = player_inspectedItem.currently_mountable_item.attack_speed
					#inspectedItem_UI.AmmoText = player_inspectedItem.currently_mountable_item.bullet_maxammo
					#inspectedItem_UI.show()
				#else:
					#inspectedItem_UI.AttackDamageText = null
					#inspectedItem_UI.AttackRangeBuffText = "+1"
					#inspectedItem_UI.AttackSpeedText = null
					#inspectedItem_UI.AmmoText = null
					#inspectedItem_UI.show()
			#"enhancement":
				#inspectedItem_UI.AttackDamageBuffText = "+5"
				#inspectedItem_UI.show()
			#"drone_station":
				#inspectedItem_UI.AttackRangeText = player_inspectedItem.area_range
				#inspectedItem_UI.DroneAmmoCapacityText = "3"
				#inspectedItem_UI.show()
	##elif player_inspectedItem != null and player_ableInteract == false and player_isHoldingItem == false:
	#elif player_inspectedItem != null and player_interactedItem_Temp != null and player_ableInteract == false:
	## player_ableInteract to check the item itself and show the card of it
		## This basically check if the temp is changed or player see 'empty' grid
		#if player_inspectedItem != player_interactedItem:
			##player_checkItemRange(player_inspectedItem, false)
			#inspectedItem_UI.AttackDamageText = null
			#inspectedItem_UI.AttackRangeText = null
			#inspectedItem_UI.AttackSpeedText = null
			#inspectedItem_UI.AmmoText = null
			#inspectedItem_UI.AttackDamageBuffText = null
			#inspectedItem_UI.AttackRangeBuffText = null
			#inspectedItem_UI.hide()
			#player_checkItemRange(player_inspectedItem, false)
	#-------------------------------------------------------------------------------------------------------------------------------------------------

func player_InspectItemsArea():
	if Input.is_action_just_pressed("check") and (player_ableInteract or player_isHoldingItem):
		if player_isHoldingItem:
			player_inspectedItem = player_interactedItem
		else:
			player_inspectedItem = player_interactedItem_Temp
		player_checkItemRange(player_inspectedItem, true)
	elif player_inspectedItem != null and !player_isHoldingItem:
		if player_inspectedItem != player_interactedItem_Temp or !player_ableInteract:
			player_checkItemRange(player_inspectedItem, false)

func player_RotateItems():
	if Input.is_action_just_pressed("rotate"):
		# Unique interaction with mortar when rotating instead it rotate the aiming of the mortar
		if player_interactedItem_Temp != null and Function.search_regex("mortar", player_interactedItem_Temp.id) and !player_isHoldingItem:
			player_interactedItem_Temp.controlled()
		# Rotate everything else with +90deg
		elif Global.preparation_phase:
			player_rotateItemProcess()

func _on_interaction_zone_body_entered(body):
	if body.is_class("GridMap") and player_isHoldingItem:
		# disable drop if the interaction area collide with gridmap
		player_ableToDrop = false
	if body.is_class("StaticBody3D") and body.get_parent().name == 'Item':
		player_interactedItem_Temp = body
		player_ableInteract = true
		#print("player ABLE to interact with w" + body.name)

func _on_interaction_zone_body_exited(body):
	if body.is_class("GridMap") and player_isHoldingItem:
		# enable drop if the interaction area collide with gridmap
		player_ableToDrop = true
	if body.is_class("StaticBody3D") and body.get_parent().name == 'Item':
		player_ableInteract = false
		#print("player UNABLE to interact with " + body.name)
