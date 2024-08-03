extends StaticBody3D

var id: String = "storage_box"

var type: String = "storage"

var is_used: bool = false
var items_display: String # this should be whatever below the $Models
var items_count: int = 0
var items_count_max: int = 3

func _ready():
	check_self()

func take(requestor):
	if items_count > 0:
		items_count -= 1
		requestor.player_holdedMats = items_display
		requestor.player_isHoldingItem = true
		requestor.player_checkIngredientItem()
		requestor.player_ableInteract = false
		print("Picked up ", requestor.player_holdedMats)
		print(items_display, items_count)
	else:
		print("there is nothing to take from storage")
	check_self()

func put(requestor, items):
	if (items_display == "" or items_display == items) and items_count < items_count_max:
		# set limiter if needed for items
		items_display = items
		items_count += 1
		clean_requestor(requestor)
		print(items_display, items_count)
	else:
		print("items displayed is different to what this storage store! or it is already maxed-out!")
	check_self()

func clean_requestor(requestor):
	requestor.player_holdedMats = ""
	requestor.player_isHoldingItem = false
	requestor.player_checkIngredientItem()

func check_self(): # refactor this into check_self() and call it when something changes
	if items_count == 0:
		items_display = ""
		is_used = false
	else:
		is_used = true
	if is_used:
		match items_display:
			"ammo_box":
				$Models/ammo_box.show()
				check_self_item()
			"bullet_box":
				$Models/bullet_box.show()
				check_self_item()
			"gunpowder_box":
				$Models/gunpowder_box.show()
				check_self_item()
			"ore_copper":
				$Models/ore_copper.show()
				check_self_item()
			"ore_zinc":
				$Models/ore_zinc.show()
				check_self_item()
			"ore_sulphur":
				$Models/ore_sulphur.show()
				check_self_item()
			"ore_saltpetre":
				$Models/ore_saltpetre.show()
				check_self_item()
	else:
		for child in $Models.get_children():
			if child is Node3D and not child is MeshInstance3D:
				child.hide()

func check_self_item():
	match items_count:
		1:
			get_node("Models/"+items_display+"/1").show()
			get_node("Models/"+items_display+"/2").hide()
			get_node("Models/"+items_display+"/3").hide()
		2:
			get_node("Models/"+items_display+"/1").show()
			get_node("Models/"+items_display+"/2").show()
			get_node("Models/"+items_display+"/3").hide()
		3:
			get_node("Models/"+items_display+"/1").show()
			get_node("Models/"+items_display+"/2").show()
			get_node("Models/"+items_display+"/3").show()
