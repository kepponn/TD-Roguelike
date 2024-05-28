extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var spawner = $"../Spawn"

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var player_ableInteract: bool = false
var player_isHoldingItem: bool = false
var player_ableToDrop: bool = true
var player_inspectedItem
var player_interactedItem
var player_interactedItem_Temp

var preparation_phase: bool = true

func _physics_process(delta):
	# Why does we have jump?
	player_jump(delta)
	
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
	player_rotation(direction)
	open_shop()
	player_movingItems()
	ready()
	wave_cleared()
	esc()
	

func _ready():
	$Audio/Bgm/Preparation.play()

func open_shop():
	if player_interactedItem_Temp != null:
		if player_interactedItem_Temp.name == "Shop" and Input.is_action_just_pressed("inspect") and preparation_phase == true:
			%Shop.show()

func ready():
	if Input.is_action_just_pressed("start") and preparation_phase == true:
		$"../NavigationRegion3D".bake_navigation_mesh()
		spawner.count_enemies()
		spawner.spawn_timer.start()
		preparation_phase = false
		print("Player Ready, Entering Wave ", spawner.waves, " Defense Phase")
		$Audio/Bgm/Preparation.stop()
		$Audio/Bgm/Defending.play()
		%Shop.hide()
	
func wave_cleared():
	if $"../Enemies".get_child_count() == 0 and spawner.total_enemies == 0 and preparation_phase == false:
		spawner.waves = spawner.waves + 1
		%Shop.update_item()
		preparation_phase = true
		print("Wave_Cleared, Entering Prep Phase")
		$Audio/Bgm/Preparation.play()
		$Audio/Bgm/Defending.stop()

func esc():
	if Input.is_action_just_pressed("exit"):
		%IngameMenu.show()
		%IngameMenu.esc()
		get_tree().paused = true

func player_jump(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

func player_rotation(direction):
	if direction != Vector3.ZERO:
		var target_rotation = atan2(direction.x, direction.z) - PI / 2
		# more of math wizardry, last param in lerp_angle() determine how fast the character rotate
		$Node3D.rotation.y = lerp_angle($Node3D.rotation.y, target_rotation, 0.25)
	# rotation of items are being modified by this code while being held on hand
	# and repaired back to grid by check_grid()

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
	# align into nearest 90 degree from current itself rotation_degrees (maybe tween this into animation?)
	export_pos.rotation_degrees.y = round(export_pos.rotation_degrees.y / 90.0) * 90.0
	# export_pos.rotation.y = 0 # this is being applied instantly
	# Return the value in vector3 for future processing by tweens
	return Vector3(x, y, z)

func spawn_boughtItem():
	pass

func player_holdItem(item) -> void: # need to return something so the last timer didnt stop prematurely
	$Audio/SelectSfx.play()
	item.reparent(%"Holded Item", true) # Change the item parent into `%"Holded Item"` which reside in player node
	item.set_collision_layer_value(1, false) # Remove the collision layer from the item while being held in-hand
	#item.position = Vector3(0.5, 1, 0) # Set item position to be on top of player
	var holdItem_Tween = get_tree().create_tween()
	holdItem_Tween.tween_property(item, "position", Vector3(0.5, 1, 0), 0.15)
	# this TIMER is IMPORTANT because it wait for the tween animation to finish
	# WILL BE REOCCURING BUG - where item glitches from %Item.position to new position

func player_putItem(item):
	$Audio/SelectSfx.play()
	item.reparent(%Item, true) # Change the item parent into `%Item` node
	#item.set_collision_layer_value(1, true) # Enable the collision layer of the item
	# Check the grid of item when putting down to the world
	var putItem_Tween = get_tree().create_tween()
	putItem_Tween.tween_property(item, "position", check_grid(%"Interaction Zone", item), 0.15)
	#item.position = check_grid(%"Interaction Zone", item)
	await get_tree().create_timer(0.15).timeout
	item.set_collision_layer_value(1, true)

func player_swapItem(held_item, ground_item):
	held_item.reparent(%Item, true) 
	held_item.set_collision_layer_value(1, true)
	held_item.position = ground_item.position # Swap the position property from held item to ground item
	held_item.rotation.y = 0 # Repair the Y-AXIS rotation to default

func player_rotateItem(item):
	if player_isHoldingItem:
		# rotate in-hand item
		print("item in-hand rotating now")
		item.rotation_degrees += Vector3(0, 45, 0)
	elif !player_isHoldingItem and player_ableInteract and player_interactedItem_Temp != null:
		# rotate ground item
		player_interactedItem = player_interactedItem_Temp
		item.rotation_degrees += Vector3(0, 45, 0)
		print("item on-ground rotating now")
	# var rotate_Tween = get_tree().create_tween()
	# rotate_Tween.tween_property(item, "rotation", , 0.15)

func player_checkItemRange(item, enable: bool = true):
	var regex = RegEx.new() # need to add some regex to check for all the name id of turret
	var pattern = r"^(?i)turret.*$" # for example all turret name start with 'turret_name_affix_suffix_whatever'
	regex.compile(pattern) # check for match regex on 'turret' and be happy
	# if by any-case you want to check more than just turret, add new pattern to be checked and refactor this code into match maybe
	if regex.search(item.name) and enable:
		# modify temp variable to match the item range and show the area
		item.visible_range.show()
		#$"Node3D/Holded Item/Item Range".mesh.top_radius = player_interactedItem.attack_range
		#$"Node3D/Holded Item/Item Range".mesh.bottom_radius = player_interactedItem.attack_range
		#$"Node3D/Holded Item/Item Range".visible = true
	elif regex.search(item.name) and !enable:
		item.visible_range.hide()
		#$"Node3D/Holded Item/Item Range".visible = false

func player_movingItems():
	# PICK UP ITEM - NOT HOLDING item and HAVE INTERACTABLE item
	if player_ableInteract == true and player_isHoldingItem == false and Input.is_action_just_pressed("interact"):
		player_isHoldingItem = true
		# When the player decided to interact with the current item `player_interactedItem_Temp` (which always changing depend on the circumstance)
		# It will save the `player_interactedItem_Temp` into `player_interactedItem` to be used
		player_interactedItem = player_interactedItem_Temp
		player_holdItem(player_interactedItem)
		await get_tree().create_timer(0.15).timeout
		player_checkItemRange(player_interactedItem)
		print("Pick-up " + str(player_interactedItem) + " from " + str(player_interactedItem.position))
		# Maybe not needed because if item is moved over character's head
		# Then interaction zone body exited will triggered to change player_ableInteract to false
		player_ableInteract = false
		
	# DROP DOWN ITEM - HOLDING an item and NOT INTERACTING with other items
	elif player_ableInteract == false and player_isHoldingItem == true and player_ableToDrop == true and Input.is_action_just_pressed("interact"):
		# Should change the name of item placeholder into someting more unique, for now it stand as %Item
		player_putItem(player_interactedItem)
		player_checkItemRange(player_interactedItem, false)
		print("Dropping " + str(player_interactedItem) + " to " + str(player_interactedItem.position))
		# print(%"Interaction Zone".global_position)
		# print(player_interactedItem.position)
		player_isHoldingItem = false
		
	# SWAP ITEM - HOLDING an items and HAVE INTERACTABLE item
	elif player_ableInteract == true and player_isHoldingItem == true and player_ableToDrop == true and Input.is_action_just_pressed("interact"):
		print("Swapping " + str(player_interactedItem) + " with " + str(player_interactedItem_Temp))
		# All this line is the basic for item swapping
		# Swap held item property to on-ground item property
		player_swapItem(player_interactedItem, player_interactedItem_Temp)
		player_checkItemRange(player_interactedItem, false)
		# Take on-ground item
		player_interactedItem = player_interactedItem_Temp
		player_holdItem(player_interactedItem)
		await get_tree().create_timer(0.15).timeout
		player_checkItemRange(player_interactedItem, true)
	
	elif Input.is_action_just_pressed("inspect") and player_ableInteract == true:
		player_inspectedItem = player_interactedItem_Temp
		player_checkItemRange(player_inspectedItem)
	elif player_inspectedItem != null and player_ableInteract == false and player_isHoldingItem == false:
		player_checkItemRange(player_inspectedItem, false)
		
	elif Input.is_action_just_pressed("rotate"):
		if player_isHoldingItem:
			# rotate in-hand item
			# since this item in in hand it will need to pass grid_check() function
			print("Rotating on-hand " + str(player_interactedItem) + " to " + str(player_interactedItem.rotation_degrees))
			player_interactedItem.rotation_degrees += Vector3(0, 90, 0)
			audio_randomSelector($Audio/Pop, -10)
		elif !player_isHoldingItem and player_ableInteract and player_interactedItem_Temp != null:
			# rotate on-ground item
			player_interactedItem = player_interactedItem_Temp
			player_interactedItem.rotation_degrees += Vector3(0, 90, 0)
			print("Rotating on-ground " + str(player_interactedItem) + " to " + str(player_interactedItem.rotation_degrees))
			audio_randomSelector($Audio/Pop, -10)
		#player_rotateItem(player_interactedItem)
	
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
