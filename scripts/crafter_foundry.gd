extends StaticBody3D

var id: String = "crafter_foundry"
var price: int

var type: String = "crafter"

# input items
var ore_copper: bool = false
var ore_zinc: bool = false
# output items
var bullet_box: bool = false

# when true the progress bar is increasing, only if player hold interact to it
var is_crafting: bool = false

func _ready():
	$ProgressBar3D/SubViewport/ProgressBar2D.max_value = $CraftingTimer.wait_time
	$ProgressBar3D/SubViewport/ProgressBar2D.value = 0

func reset():
	$CraftingTimer.stop()
	is_crafting = false
	ore_copper = false
	ore_zinc = false
	bullet_box = false

func take(requestor):
	if bullet_box:
		bullet_box = false
		requestor.player_holdedMats = "bullet_box"
		requestor.player_isHoldingItem = true
		requestor.player_checkIngredientItem()
		requestor.player_ableInteract = false
		print("Picked up ", requestor.player_holdedMats, " from chemistry station")
	else:
		print("Nothing to take from chemistry station")

func put(requestor, items):
	if items == "ore_copper" and !ore_copper:
		ore_copper = true
		clean_requestor(requestor)
	elif items == "ore_zinc" and !ore_zinc:
		ore_zinc = true
		clean_requestor(requestor)
	else:
		print("Cannot put ingredient ", requestor.player_holdedMats, " because foundry is full, or do you put wrong ingredient?")

func clean_requestor(requestor):
	requestor.player_holdedMats = ""
	requestor.player_isHoldingItem = false
	requestor.player_checkIngredientItem()

func _process(_delta):
	progress_ui()
	if bullet_box:
		pass # show icon for this / item ready
	if ore_copper and ore_zinc and !is_crafting and !bullet_box:
		is_crafting = true
		$CraftingTimer.start()
		print("foundry craft start")

func progress_ui():
	if is_crafting:
		$ProgressBar3D.show()
		$ProgressBar3D/SubViewport/ProgressBar2D.max_value = $CraftingTimer.wait_time
		$ProgressBar3D/SubViewport/ProgressBar2D.value = $CraftingTimer.wait_time - $CraftingTimer.time_left
	else:
		$ProgressBar3D.hide()

func _on_crafting_timer_timeout():
	is_crafting = false
	ore_copper = false
	ore_zinc = false
	bullet_box = true
	print("foundry craft finished")
	
