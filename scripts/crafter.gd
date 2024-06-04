extends StaticBody3D



var id = "crafter"
var price

@onready var player = get_node('/root/Node3D/Player')
@onready var player_item = get_node('/root/Node3D/Player/Item')

var mats_Gunpowder: int = 0
var mats_Bullet: int = 0
var prod_ammo: int = 0
var is_crafting: bool = false

func _process(delta):
	update_UI()
	craft_ammo()

func update_UI():
	$CraftingProgress3D/SubViewport/CraftingProgress2D.max_value = $CraftingTimer.wait_time
	$CraftingProgress3D/SubViewport/CraftingProgress2D.value = $CraftingTimer.time_left
	if $CraftingTimer.time_left == 0:
		$CraftingProgress3D.hide()
	else:
		$CraftingProgress3D.show()

func craft_ammo():
	if mats_Bullet == 1 and mats_Gunpowder == 1 and is_crafting == false:
		is_crafting = true
		$CraftingTimer.start()

func get_product():
	if prod_ammo == 1:
		prod_ammo = 0
		player.player_holdedMats = "ammo_box"
	else:
		player.player_holdedMats = ""

func get_ingredient(mats_id):
	#IF Succesfully added gunpowder
	if mats_id == "gunpowder_box" and mats_Gunpowder == 0:
		mats_Gunpowder = 1
		player.player_holdedMats == null
		player.player_isHoldingItem = false
		player_item.hide()
		#hide player ingredient mesh
	#IF Succesfully added bullet
	elif mats_id == "bullet_box" and mats_Bullet == 0:
		mats_Bullet = 1
		player.player_holdedMats == null
		player.player_isHoldingItem = false
		player_item.hide()
		#hide player ingredient mesh
	#IF failed to add any ingredient because crafter is full
	else:
		player.player_isHoldingItem = true
		pass
		
func _on_crafting_timer_timeout():
	print("Crafting Complete")
	mats_Bullet = 0
	mats_Gunpowder = 0
	prod_ammo = 1
	is_crafting = false
	
