extends StaticBody3D

var id: String = "crafter"
var price: int

var type: String = "crafter"

# input items
var bullet_box: bool = false
var gunpowder_box: bool = false
# output items
var ammo_box : bool = false
# when true the progress bar is increasing, only if player hold interact to it
var is_crafting: bool = false

func _ready():
	check_icon_ui(false)
	$ProgressBar3D/SubViewport/ProgressBar2D.max_value = $CraftingTimer.wait_time
	$ProgressBar3D/SubViewport/ProgressBar2D.value = 0

func reset():
	$CraftingTimer.stop()
	is_crafting = false
	bullet_box = false
	gunpowder_box = false
	ammo_box = false

func take(requestor):
	if ammo_box:
		ammo_box = false
		if Function.search_regex("player", requestor.id):
			requestor.player_holdedMats = "ammo_box"
			requestor.player_isHoldingItem = true
			requestor.player_checkIngredientItem()
			requestor.player_ableInteract = false
			print("Picked up ", requestor.player_holdedMats, " from ammo crafter")
		elif requestor.id == "conveyor_grabber":
			print("Ammo Crafter - Conveyor grabber taking ammo_box")
			return "ammo_box"
	else:
		print("Nothing to take from ammo crafter")

func put(requestor, items):
	if !ammo_box:
		if items == "bullet_box" and !bullet_box:
			bullet_box = true
			check_requestor(requestor)
		elif items == "gunpowder_box" and !gunpowder_box:
			gunpowder_box = true
			check_requestor(requestor)
		
		craft()

func check_requestor(requestor):
	if Function.search_regex("player", requestor.id):
		print("Ammo Crafter - Put down ", requestor.player_holdedMats)
		clean_requestor(requestor)
	elif Function.search_regex("conveyor", requestor.id):
		print("Ammo Crafter - Conveyor setter is sending ")

func clean_requestor(requestor):
	requestor.player_holdedMats = ""
	requestor.player_isHoldingItem = false
	requestor.player_checkIngredientItem()

func craft():
	if bullet_box and gunpowder_box and !is_crafting and !ammo_box:
		is_crafting = true
		$CraftingTimer.start()
		print("ammo crafter craft start")

func _process(_delta):
	progress_ui()
	if ammo_box:
		pass # show icon for this / item ready


func progress_ui():
	if is_crafting:
		$ProgressBar3D.show()
		$ProgressBar3D/SubViewport/ProgressBar2D.max_value = $CraftingTimer.wait_time
		$ProgressBar3D/SubViewport/ProgressBar2D.value = $CraftingTimer.wait_time - $CraftingTimer.time_left
		check_icon_ui(false)
	else:
		$ProgressBar3D.hide()
		check_icon_ui(true)

func check_icon_ui(show_icon: bool):
	match show_icon:
		true:
			if bullet_box: $"IngredientInfo3D/SubViewport/Ingredient List/bullet_box".show()
			else: $"IngredientInfo3D/SubViewport/Ingredient List/bullet_box".hide()
			if gunpowder_box: $"IngredientInfo3D/SubViewport/Ingredient List/gunpowder_box".show()
			else: $"IngredientInfo3D/SubViewport/Ingredient List/gunpowder_box".hide()
			if ammo_box: $"IngredientInfo3D/SubViewport/Ingredient List/ammo_box".show()
			else: $"IngredientInfo3D/SubViewport/Ingredient List/ammo_box".hide()
		false:
			$"IngredientInfo3D/SubViewport/Ingredient List/gunpowder_box".hide()
			$"IngredientInfo3D/SubViewport/Ingredient List/bullet_box".hide()
			$"IngredientInfo3D/SubViewport/Ingredient List/ammo_box".hide()

func _on_crafting_timer_timeout():
	is_crafting = false
	bullet_box = false
	gunpowder_box = false
	ammo_box = true
	print("ammo crafter craft finished")
	


#extends StaticBody3D
#
#var id = "crafter"
#var price
#
#@onready var player = get_node('/root/Scene/Player')
#
#@onready var icon_Gunpowder = $"IngredientInfo3D/SubViewport/Ingredient List/GunpowderIcon"
#@onready var icon_Bullet = $"IngredientInfo3D/SubViewport/Ingredient List/BulletIcon"
#@onready var icon_Ammo = $"IngredientInfo3D/SubViewport/Ingredient List/AmmoIcon"
#
#var mats_gunpowder_box: int = 0
#var mats_bullet_box: int = 0
#var prod_ammo_box: int = 0
#var is_crafting: bool = false
#
#func _process(delta):
	#var idle_speed = 20 * delta
	#var process_speed = 80 * delta
	#if is_crafting:
		#$Models/Torus.rotation_degrees.y += process_speed
		#$Models/Torus2.rotation_degrees.y -= process_speed
		#$Models/Torus3.rotation_degrees.y += process_speed
	#else:
		#$Models/Torus.rotation_degrees.y += idle_speed
		#$Models/Torus2.rotation_degrees.y -= idle_speed
		#$Models/Torus3.rotation_degrees.y += idle_speed
	#update_UI()
	#craft_ammo()
	#
#func reset(): # To reset all crafter inventory, being call by default_state() in player.gd
	#$CraftingTimer.stop()
	#mats_gunpowder_box = 0
	#mats_bullet_box = 0
	#prod_ammo_box = 0
	#is_crafting = false
#
#func update_UI():
	#if Global.preparation_phase:
		#$CraftingProgress3D.hide()
		#$IngredientInfo3D.hide()
	#else:
		#$CraftingProgress3D.show()
		#$IngredientInfo3D.show()
	#
	#$CraftingProgress3D/SubViewport/CraftingProgress2D.max_value = $CraftingTimer.wait_time
	#$CraftingProgress3D/SubViewport/CraftingProgress2D.value = $CraftingTimer.time_left
	#
	#if $CraftingTimer.time_left == 0:
		#$CraftingProgress3D.hide()
	#else:
		#$CraftingProgress3D.show()
	#
	#
	#if mats_bullet_box == 1 or mats_gunpowder_box == 1:
		#icon_Bullet.show()
		#icon_Gunpowder.show()
		#if mats_gunpowder_box == 1:
			#icon_Gunpowder.self_modulate = Color("#ffffff")
		#else:
			#icon_Gunpowder.self_modulate = Color("#757575")
		#if mats_bullet_box == 1:
			#icon_Bullet.self_modulate = Color("#ffffff")
		#else:
			#icon_Bullet.self_modulate = Color("#757575")
	#else :
		#icon_Gunpowder.hide()
		#icon_Bullet.hide()
		#
	#if prod_ammo_box == 1:
		#icon_Ammo.show()
	#else:
		#icon_Ammo.hide()
		#
#func craft_ammo():
	## Currently locks any crafting if there is prod items
	#if mats_bullet_box == 1 and mats_gunpowder_box == 1 and is_crafting == false and prod_ammo_box == 0:
		#is_crafting = true
		#$CraftingTimer.start()
#
#func get_product():
	#if prod_ammo_box == 1:
		#prod_ammo_box = 0
		#player.player_holdedMats = "ammo_box"
		#player.player_isHoldingItem = true
		#player.player_ableInteract = false
		#print("Picked up ", player.player_holdedMats, " from crafter")
	#else:
		#player.player_holdedMats = ""
		#player.player_isHoldingItem = false
		#player.player_ableInteract = true
#
#func get_ingredient(mats_id):
	##IF Succesfully added gunpowder
	#if mats_id == "gunpowder_box" and mats_gunpowder_box == 0:
		#print("Put ingredient ", player.player_holdedMats, " to crafter")
		#mats_gunpowder_box = 1
		#player.player_holdedMats = ""
		#player.player_isHoldingItem = false
		##hide player ingredient mesh
	##IF Succesfully added bullet
	#elif mats_id == "bullet_box" and mats_bullet_box == 0:
		#print("Put ingredient ", player.player_holdedMats, " to crafter")
		#mats_bullet_box = 1
		#player.player_holdedMats = ""
		#player.player_isHoldingItem = false
		##hide player ingredient mesh
	##IF failed to add any ingredient because crafter is full
	#else:
		#print("Cannot put ingredient ", player.player_holdedMats, " because crafter is full")
		#player.player_isHoldingItem = true
		#pass
		#
#func _on_crafting_timer_timeout():
	#mats_bullet_box = 0
	#mats_gunpowder_box = 0
	#prod_ammo_box = 1
	#is_crafting = false
	#
#func conveyor_put_ingredient(mats_id):
	#if mats_id == "gunpowder_box" and mats_gunpowder_box == 0:
		#mats_gunpowder_box = 1
	#elif mats_id == "bullet_box" and mats_bullet_box == 0:
		#mats_bullet_box = 1
#
#func conveyor_get_product():
	#if prod_ammo_box == 1:
		#prod_ammo_box = 0
		#return "ammo_box"
