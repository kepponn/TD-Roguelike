extends StaticBody3D
class_name Ore_Parent

# ore_saltpetre + ore_sulphur = gun_powder (crafted in chemical station)
# ore_copper + ore_zinc = bullet_box (crafter in forge)

var id: String # this being set by child
var price: int # just in case this will be in shops

var type: String = "ingredients" # why have a type? so player didnt need to check for stupid shit

# take function being called by player
func take(requestor):
	match id:
		"ore_saltpetre":
			requestor.player_holdedMats = "ore_saltpetre"
		"ore_sulphur":
			requestor.player_holdedMats = "ore_sulphur"
		"ore_copper":
			requestor.player_holdedMats = "ore_copper"
		"ore_zinc":
			requestor.player_holdedMats = "ore_zinc"
	requestor.player_isHoldingItem = true
	requestor.player_checkIngredientItem()
	requestor.player_ableInteract = false
	print("Picked up ", requestor.player_holdedMats)
	
# put function
func put(_requestor):
	pass
