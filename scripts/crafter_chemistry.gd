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

func reset():
	is_crafting = false
	ore_saltpetre = false
	ore_sulphur = false
	gunpowder_box = false

func take(requestor):
	if gunpowder_box:
		gunpowder_box = false
		requestor.player_holdedMats = "gunpowder_box"
		requestor.player_isHoldingItem = true
		requestor.player_checkIngredientItem()
		requestor.player_ableInteract = false
		print("Picked up ", requestor.player_holdedMats, " from chemistry")
	else:
		print("Nothing to take from chemistry")

func put(requestor, items):
	if items == "ore_saltpetre" and !ore_saltpetre:
		ore_saltpetre = true
		clean_requestor(requestor)
	elif items == "ore_sulphur" and !ore_sulphur:
		ore_sulphur = true
		clean_requestor(requestor)
	else:
		print("Cannot put ingredient ", requestor.player_holdedMats, " because chemistry is full, or do you put wrong ingredient?")

func clean_requestor(requestor):
	requestor.player_holdedMats = ""
	requestor.player_isHoldingItem = false
	requestor.player_checkIngredientItem()

func _process(_delta):
	if ore_saltpetre and ore_sulphur and !is_crafting and !gunpowder_box:
		is_crafting = true
		$CraftingTimer.start()
		print("chemistry craft start")

func _on_crafting_timer_timeout():
	is_crafting = false
	ore_saltpetre = false
	ore_sulphur = false
	gunpowder_box = true
	print("chemistry craft finished")
	
