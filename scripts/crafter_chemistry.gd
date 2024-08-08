extends StaticBody3D

var id: String = "crafter_chemistry"
var price: int

var type: String = "crafter"

# input items
var ore_saltpetre: bool = false
var ore_sulphur: bool = false
# output items
var gunpowder_box: bool = false

# when true the progress bar is increasing, only if player hold interact to it
var is_crafting: bool = false

func _ready():
	check_icon_ui(false)
	$ProgressBar3D/SubViewport/ProgressBar2D.max_value = $CraftingTimer.wait_time
	$ProgressBar3D/SubViewport/ProgressBar2D.value = 0

func reset():
	$CraftingTimer.stop()
	is_crafting = false
	ore_saltpetre = false
	ore_sulphur = false
	gunpowder_box = false

func take(requestor):
	if gunpowder_box:
		gunpowder_box = false
		if Function.search_regex("player", requestor.id):
			requestor.player_holdedMats = "gunpowder_box"
			requestor.player_isHoldingItem = true
			requestor.player_checkIngredientItem()
			requestor.player_ableInteract = false
			print("Picked up ", requestor.player_holdedMats, " from chemistry")
		elif requestor.id == "conveyor_grabber":
			print("Crafter Chemistry - Conveyor grabber taking gunpowder_box")
			return "gunpowder_box"
	else:
		print("Nothing to take from chemistry")

func put(requestor, items):
	if !gunpowder_box:
		if items == "ore_saltpetre" and !ore_saltpetre:
			ore_saltpetre = true
			check_requestor(requestor)
		elif items == "ore_sulphur" and !ore_sulphur:
			ore_sulphur = true
			check_requestor(requestor)
		
		craft()

	
func check_requestor(requestor):
	if Function.search_regex("player", requestor.id):
		print("Crafter Chemistry - Put down ", requestor.player_holdedMats)
		clean_requestor(requestor)
	elif Function.search_regex("conveyor", requestor.id):
		print("Crafter Chemistry - Conveyor setter is sending ")
	
func clean_requestor(requestor):
	requestor.player_holdedMats = ""
	requestor.player_isHoldingItem = false
	requestor.player_checkIngredientItem()

func craft():
	if ore_sulphur and ore_saltpetre and !is_crafting and !gunpowder_box:
		is_crafting = true
		$CraftingTimer.start()
		print("chemistry craft start")

func _process(_delta):
	progress_ui()
	if gunpowder_box:
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
			if ore_saltpetre: $"IngredientInfo3D/SubViewport/Ingredient List/ore_saltpetre".show()
			else: $"IngredientInfo3D/SubViewport/Ingredient List/ore_saltpetre".hide()
			if ore_sulphur: $"IngredientInfo3D/SubViewport/Ingredient List/ore_sulphur".show()
			else: $"IngredientInfo3D/SubViewport/Ingredient List/ore_sulphur".hide()
			if gunpowder_box: $"IngredientInfo3D/SubViewport/Ingredient List/gunpowder_box".show()
			else: $"IngredientInfo3D/SubViewport/Ingredient List/gunpowder_box".hide()
		false:
			$"IngredientInfo3D/SubViewport/Ingredient List/ore_saltpetre".hide()
			$"IngredientInfo3D/SubViewport/Ingredient List/ore_sulphur".hide()
			$"IngredientInfo3D/SubViewport/Ingredient List/gunpowder_box".hide()

func _on_crafting_timer_timeout():
	is_crafting = false
	ore_saltpetre = false
	ore_sulphur = false
	gunpowder_box = true
	print("chemistry craft finished")
	
