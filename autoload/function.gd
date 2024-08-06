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
