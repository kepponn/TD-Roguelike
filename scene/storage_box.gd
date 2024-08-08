extends StaticBody3D

var id: String = "storage_box"

var type: String = "storage"

var is_used: bool = false
var is_instanced: bool = false
var items_display: String # this should be whatever below the $Models
var items_count: int = 0
var items_count_max: int = 3

func _ready():
	check_self()

func take(requestor):
	if items_count > 0:
		items_count -= 1
		if Function.search_regex("player", requestor.id):
			requestor.player_holdedMats = items_display
			requestor.player_isHoldingItem = true
			requestor.player_checkIngredientItem()
			requestor.player_ableInteract = false
			print("Storage - Picked up ", requestor.player_holdedMats)
		elif requestor.id == "conveyor_grabber":
			print("Storage - Conveyor grabber taking ", items_display)
			return items_display
			# Then after this the conveyor_grabber call for check_self() to update the models
		#print("Storage - Contain ", items_display, " x", items_count)
	else:
		print("Storage - There is nothing in the storage")
	check_self()

func put(requestor, items):
	if (items_display == "" or items_display == items) and items_count < items_count_max:
		# set limiter if needed for items
		items_display = items
		items_count += 1
		if Function.search_regex("player", requestor.id):
			print("Storage - Put down ", requestor.player_holdedMats)
			clean_requestor(requestor)
		elif requestor.id == "conveyor_setter":
			print("Storage - Conveyor setter is sending ", items)
		#print("Storage - Contain ", items_display, " x", items_count)
	else:
		print("Storage - Items displayed is different to what this storage store! or it is already maxed-out!")
	check_self()

func clean_requestor(requestor):
	requestor.player_holdedMats = ""
	requestor.player_isHoldingItem = false
	requestor.player_checkIngredientItem()

func check_self(): # refactor this into check_self() and call it when something changes
	if items_count == 0:
		items_display = ""
		is_used = false
		is_instanced = false
		check_item_count()
	else:
		is_used = true
	if is_used:
		match items_display:
			"ammo_box":
				if !is_instanced:
					var mesh = load("res://models/object/ammo_box.obj")
					var mats = load("res://models/materials/ammo_box_toon.tres")
					$"Models/1".mesh = mesh
					$"Models/1".material_override = mats
					$"Models/1".position = Vector3(0.015, -0.103, 0.204)
					$"Models/1".rotation_degrees = Vector3(0, 0, 0)
					$"Models/1".scale = Vector3(1, 1, 1)
					$"Models/2".mesh = mesh
					$"Models/2".material_override = mats
					$"Models/2".position = Vector3(0.015, -0.103, -0.258)
					$"Models/2".rotation_degrees = Vector3(0, 0, 0)
					$"Models/2".scale = Vector3(1, 1, 1)
					$"Models/3".mesh = mesh
					$"Models/3".material_override = mats
					$"Models/3".position = Vector3(0.018, 0.308, -0.019)
					$"Models/3".rotation_degrees = Vector3(0, 7.2, 0)
					$"Models/3".scale = Vector3(1, 1, 1)
					is_instanced = true
				check_item_count()
			"bullet_box":
				if !is_instanced:
					var mats = load("res://models/materials/bullet_case_toon.tres")
					$"Models/1".mesh = load("res://models/object/bullet-p1.obj")
					$"Models/1".material_override = mats
					$"Models/1".position = Vector3(0.112, 0.004, 0.204)
					$"Models/1".rotation_degrees = Vector3(0, 0, 0)
					$"Models/1".scale = Vector3(1, 1, 1)
					$"Models/2".mesh = load("res://models/object/bullet-p2.obj")
					$"Models/2".material_override = mats
					$"Models/2".position = Vector3(-0.24, -0.167, 0.003)
					$"Models/2".rotation_degrees = Vector3(0, -5.7, 0)
					$"Models/2".scale = Vector3(1, 1, 1)
					$"Models/3".mesh = load("res://models/object/bullet-p3.obj")
					$"Models/3".material_override = mats
					$"Models/3".position = Vector3(0.162, -0.185, -0.202)
					$"Models/3".rotation_degrees = Vector3(0, 7.2, 0)
					$"Models/3".scale = Vector3(1, 1, 1)
					is_instanced = true
				check_item_count()
			"gunpowder_box":
				if !is_instanced:
					var mesh = load("res://models/object/barrel.obj")
					var mats = load("res://models/materials/wood_alternative_toon.tres")
					$"Models/1".mesh = mesh
					$"Models/1".material_override = mats
					$"Models/1".position = Vector3(0.251, 0.025, 0.169)
					$"Models/1".rotation_degrees = Vector3(0, 7.6, 0)
					$"Models/1".scale = Vector3(1, 1, 1)
					$"Models/2".mesh = mesh
					$"Models/2".material_override = mats
					$"Models/2".position = Vector3(-0.238, 0.025, 0.081)
					$"Models/2".rotation_degrees = Vector3(0, 0, 0)
					$"Models/2".scale = Vector3(1, 1, 1)
					$"Models/3".mesh = mesh
					$"Models/3".material_override = mats
					$"Models/3".position = Vector3(0.098, 0.025, -0.249)
					$"Models/3".rotation_degrees = Vector3(0, 18.1, 0)
					$"Models/3".scale = Vector3(1, 1, 1)
					is_instanced = true
				check_item_count()
			"ore_copper":
				if !is_instanced:
					var mesh = load("res://models/object/basic-ore.obj")
					var mats = load("res://models/materials/ore_copper_toon.tres")
					$"Models/1".mesh = mesh
					$"Models/1".material_override = mats
					$"Models/1".position = Vector3(0.127, 0.209, 0.156)
					$"Models/1".rotation_degrees = Vector3(0, -155.3, 0)
					$"Models/1".scale = Vector3(0.57, 0.57, 0.57)
					$"Models/2".mesh = mesh
					$"Models/2".material_override = mats
					$"Models/2".position = Vector3(-0.145, 0.105, -0.046)
					$"Models/2".rotation_degrees = Vector3(0, 62.7, 0)
					$"Models/2".scale = Vector3(0.494, 0.36, 0.568)
					$"Models/3".mesh = mesh
					$"Models/3".material_override = mats
					$"Models/3".position = Vector3(0.127, -0.076, -0.223)
					$"Models/3".rotation_degrees = Vector3(0, -64.2, 0)
					$"Models/3".scale = Vector3(0.461, 0.449, 0.505)
					is_instanced = true
				check_item_count()
			"ore_zinc":
				if !is_instanced:
					var mesh = load("res://models/object/basic-ore.obj")
					var mats = load("res://models/materials/ore_zinc_toon.tres")
					$"Models/1".mesh = mesh
					$"Models/1".material_override = mats
					$"Models/1".position = Vector3(0.127, 0.209, 0.156)
					$"Models/1".rotation_degrees = Vector3(0, -155.3, 0)
					$"Models/1".scale = Vector3(0.57, 0.57, 0.57)
					$"Models/2".mesh = mesh
					$"Models/2".material_override = mats
					$"Models/2".position = Vector3(-0.145, 0.105, -0.046)
					$"Models/2".rotation_degrees = Vector3(0, 62.7, 0)
					$"Models/2".scale = Vector3(0.494, 0.36, 0.568)
					$"Models/3".mesh = mesh
					$"Models/3".material_override = mats
					$"Models/3".position = Vector3(0.127, -0.076, -0.223)
					$"Models/3".rotation_degrees = Vector3(0, -64.2, 0)
					$"Models/3".scale = Vector3(0.461, 0.449, 0.505)
					is_instanced = true
				check_item_count()
			"ore_sulphur":
				if !is_instanced:
					var mesh = load("res://models/object/basic-ore.obj")
					var mats = load("res://models/materials/ore_sulphur_toon.tres")
					$"Models/1".mesh = mesh
					$"Models/1".material_override = mats
					$"Models/1".position = Vector3(0.127, 0.209, 0.156)
					$"Models/1".rotation_degrees = Vector3(0, -155.3, 0)
					$"Models/1".scale = Vector3(0.57, 0.57, 0.57)
					$"Models/2".mesh = mesh
					$"Models/2".material_override = mats
					$"Models/2".position = Vector3(-0.145, 0.105, -0.046)
					$"Models/2".rotation_degrees = Vector3(0, 62.7, 0)
					$"Models/2".scale = Vector3(0.494, 0.36, 0.568)
					$"Models/3".mesh = mesh
					$"Models/3".material_override = mats
					$"Models/3".position = Vector3(0.127, -0.076, -0.223)
					$"Models/3".rotation_degrees = Vector3(0, -64.2, 0)
					$"Models/3".scale = Vector3(0.461, 0.449, 0.505)
					is_instanced = true
				check_item_count()
			"ore_saltpetre":
				if !is_instanced:
					var mesh = load("res://models/object/basic-ore.obj")
					var mats = load("res://models/materials/ore_saltpetre_toon.tres")
					$"Models/1".mesh = mesh
					$"Models/1".material_override = mats
					$"Models/1".position = Vector3(0.127, 0.209, 0.156)
					$"Models/1".rotation_degrees = Vector3(0, -155.3, 0)
					$"Models/1".scale = Vector3(0.57, 0.57, 0.57)
					$"Models/2".mesh = mesh
					$"Models/2".material_override = mats
					$"Models/2".position = Vector3(-0.145, 0.105, -0.046)
					$"Models/2".rotation_degrees = Vector3(0, 62.7, 0)
					$"Models/2".scale = Vector3(0.494, 0.36, 0.568)
					$"Models/3".mesh = mesh
					$"Models/3".material_override = mats
					$"Models/3".position = Vector3(0.127, -0.076, -0.223)
					$"Models/3".rotation_degrees = Vector3(0, -64.2, 0)
					$"Models/3".scale = Vector3(0.461, 0.449, 0.505)
					is_instanced = true
				check_item_count()
	else:
		for child in $Models.get_children():
			if child is Node3D and not child is MeshInstance3D:
				child.hide()

func check_item_count():
	match items_count:
		0:
			$"Models/1".hide()
			$"Models/2".hide()
			$"Models/3".hide()
		1:
			$"Models/1".show()
			$"Models/2".hide()
			$"Models/3".hide()
		2:
			$"Models/1".show()
			$"Models/2".show()
			$"Models/3".hide()
		3:
			$"Models/1".show()
			$"Models/2".show()
			$"Models/3".show()
