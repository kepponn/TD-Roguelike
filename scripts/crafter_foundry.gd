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
	check_icon_ui(false)
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
		if Function.search_regex("player", requestor.id):
			requestor.player_holdedMats = "bullet_box"
			requestor.player_isHoldingItem = true
			requestor.player_checkIngredientItem()
			requestor.player_ableInteract = false
			print("Picked up ", requestor.player_holdedMats, " from chemistry station")
		elif requestor.id == "conveyor_grabber":
			print("Crafter Foundry - Conveyor grabber taking bullet_box")
			return "bullet_box"
	else:
		print("Nothing to take from chemistry station")

func put(requestor, items):
	if !bullet_box:
		if items == "ore_copper" and !ore_copper:
			ore_copper = true
			check_requestor(requestor)
		elif items == "ore_zinc" and !ore_zinc:
			ore_zinc = true
			check_requestor(requestor)
		craft()


func check_requestor(requestor):
	if Function.search_regex("player", requestor.id):
		print("Crafter Foundry - Put down ", requestor.player_holdedMats)
		clean_requestor(requestor)
	elif Function.search_regex("conveyor", requestor.id):
		print("Crafter Foundry - Conveyor setter is sending ")

func clean_requestor(requestor):
	requestor.player_holdedMats = ""
	requestor.player_isHoldingItem = false
	requestor.player_checkIngredientItem()

func craft():
	if ore_copper and ore_zinc and !is_crafting and !bullet_box:
		is_crafting = true
		$CraftingTimer.start()
		print("foundry craft start")

func _process(_delta):
	progress_ui()
	if bullet_box:
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
			if ore_copper: $"IngredientInfo3D/SubViewport/Ingredient List/ore_copper".show()
			else: $"IngredientInfo3D/SubViewport/Ingredient List/ore_copper".hide()
			if ore_zinc: $"IngredientInfo3D/SubViewport/Ingredient List/ore_zinc".show()
			else: $"IngredientInfo3D/SubViewport/Ingredient List/ore_zinc".hide()
			if bullet_box: $"IngredientInfo3D/SubViewport/Ingredient List/bullet_box".show()
			else: $"IngredientInfo3D/SubViewport/Ingredient List/bullet_box".hide()
		false:
			$"IngredientInfo3D/SubViewport/Ingredient List/ore_copper".hide()
			$"IngredientInfo3D/SubViewport/Ingredient List/ore_zinc".hide()
			$"IngredientInfo3D/SubViewport/Ingredient List/bullet_box".hide()

func _on_crafting_timer_timeout():
	is_crafting = false
	ore_copper = false
	ore_zinc = false
	bullet_box = true
	print("foundry craft finished")
	
