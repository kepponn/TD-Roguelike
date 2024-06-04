extends StaticBody3D

var id = "crafter"
var price

@onready var player = get_node('/root/Node3D/Player')
@onready var player_item = get_node('/root/Node3D/Player/Item')

var mats_gunpowder_box: int = 0
var mats_bullet_box: int = 0
var prod_ammo_box: int = 0
var is_crafting: bool = false

func _process(_delta):
	update_UI()
	craft_ammo()
	
func reset(): # To reset all crafter inventory, being call by default_state() in player.gd
	mats_gunpowder_box = 0
	mats_bullet_box = 0
	prod_ammo_box = 0
	is_crafting = false

func update_UI():
	$CraftingProgress3D/SubViewport/CraftingProgress2D.max_value = $CraftingTimer.wait_time
	$CraftingProgress3D/SubViewport/CraftingProgress2D.value = $CraftingTimer.time_left
	if $CraftingTimer.time_left == 0:
		$CraftingProgress3D.hide()
	else:
		$CraftingProgress3D.show()

func craft_ammo():
	if mats_bullet_box == 1 and mats_gunpowder_box == 1 and is_crafting == false:
		is_crafting = true
		$CraftingTimer.start()

func get_product():
	if prod_ammo_box == 1:
		prod_ammo_box = 0
		player.player_holdedMats = "ammo_box"
	else:
		player.player_holdedMats = ""

func get_ingredient(mats_id):
	#IF Succesfully added gunpowder
	if mats_id == "gunpowder_box" and mats_gunpowder_box == 0:
		mats_gunpowder_box = 1
		player.player_holdedMats = ""
		player.player_isHoldingItem = false
		player_item.hide()
		#hide player ingredient mesh
	#IF Succesfully added bullet
	elif mats_id == "bullet_box" and mats_bullet_box == 0:
		mats_bullet_box = 1
		player.player_holdedMats = ""
		player.player_isHoldingItem = false
		player_item.hide()
		#hide player ingredient mesh
	#IF failed to add any ingredient because crafter is full
	else:
		player.player_isHoldingItem = true
		pass
		
func _on_crafting_timer_timeout():
	print("Crafting Complete")
	mats_bullet_box = 0
	mats_gunpowder_box = 0
	prod_ammo_box = 1
	is_crafting = false
	
