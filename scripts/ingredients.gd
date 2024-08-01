extends StaticBody3D
class_name Ingredients

# still debating to use this for whole ingredient type stuff..

var id: String

var type: String = "ingredients"

func take(requestor):
	match id:
		"what?":
			pass
	requestor.player_isHoldingItem = true
	requestor.player_checkIngredientItem()
	requestor.player_ableInteract = false
	print("Picked up ", requestor.player_holdedMats)
