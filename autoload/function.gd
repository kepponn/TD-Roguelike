extends Node

func search_regex(search_name: String, search_to):
	var regex = RegEx.new()
	regex.compile(r"^(?i)"+search_name+".*$")
	var object = regex.search(search_to)
	return object

func check_sprite(match_this, sprite_path):
	match match_this:
			"":
				sprite_path.hide()
			"ammo_box":
				sprite_path.texture = load("res://assets/icon/ingredients/ammo_box.png")
				sprite_path.show()
			"gunpowder_box":
				sprite_path.texture = load("res://assets/icon/ingredients/gunpowder_barrel.png")
				sprite_path.show()
			"bullet_box":
				sprite_path.texture = load("res://assets/icon/ingredients/bullet_case.png")
				sprite_path.show()
			"ore_copper":
				sprite_path.texture = load("res://assets/icon/ingredients/ore/ore_copper.png")
				sprite_path.show()
			"ore_saltpetre":
				sprite_path.texture = load("res://assets/icon/ingredients/ore/ore_saltpetre.png")
				sprite_path.show()
			"ore_sulphur":
				sprite_path.texture = load("res://assets/icon/ingredients/ore/ore_sulphur.png")
				sprite_path.show()
			"ore_zinc":
				sprite_path.texture = load("res://assets/icon/ingredients/ore/ore_zinc.png")
				sprite_path.show()

func check_item_model_3d(match_this, model_path, model_default_position):
	model_path.scale = Vector3(1, 1, 1)
	model_path.rotation_degrees = Vector3(0, 43.2, 0)
	model_path.position = model_default_position
	match match_this:
			"":
				model_path.hide()
			"ammo_box":
				model_path.mesh = load("res://models/object/ammo_box.obj")
				model_path.material_override = load("res://models/materials/ammo_box_toon.tres")
				model_path.scale = Vector3(1, 1, 1)
				model_path.rotation_degrees = Vector3(0, 90, 0)
				model_path.show()
			"bullet_box":
				model_path.mesh = load("res://models/object/bullet-p1.obj")
				model_path.material_override = load("res://models/materials/bullet_case_toon.tres")
				model_path.scale = Vector3(0.9, 0.9, 0.9)
				model_path.position = model_default_position - Vector3(0.140, 0, 0)
				model_path.show()
			"gunpowder_box":
				model_path.mesh = load("res://models/object/barrel.obj")
				model_path.material_override = load("res://models/materials/wood_alternative_toon.tres")
				model_path.scale = Vector3(1, 1, 1)
				model_path.show()
			"ore_copper":
				model_path.mesh = load("res://models/object/basic-ore.obj")
				model_path.material_override = load("res://models/materials/ore_copper_toon.tres")
				model_path.scale = Vector3(0.545, 0.545, 0.545)
				model_path.show()
			"ore_saltpetre":
				model_path.mesh = load("res://models/object/basic-ore.obj")
				model_path.material_override = load("res://models/materials/ore_saltpetre_toon.tres")
				model_path.scale = Vector3(0.545, 0.545, 0.545)
				model_path.show()
			"ore_sulphur":
				model_path.mesh = load("res://models/object/basic-ore.obj")
				model_path.material_override = load("res://models/materials/ore_sulphur_toon.tres")
				model_path.scale = Vector3(0.545, 0.545, 0.545)
				model_path.show()
			"ore_zinc":
				model_path.mesh = load("res://models/object/basic-ore.obj")
				model_path.material_override = load("res://models/materials/ore_zinc_toon.tres")
				model_path.scale = Vector3(0.545, 0.545, 0.545)
				model_path.show()
