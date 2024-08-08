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

# The models used in here need to have 0 translation and have centered point (volume)
func check_item_model_3d(requestor, match_this, model_path):
	model_path.rotation_degrees = Vector3(0, 43.2, 0)
	match match_this:
			"":
				model_path.hide()
			"ammo_box":
				model_path.mesh = load("res://models/object/ammo_box.obj")
				model_path.material_override = load("res://models/materials/ammo_box_toon.tres")
				model_path.scale = Vector3(1, 1, 1)
				if Function.search_regex("player", requestor.id):
					model_path.rotation_degrees = Vector3(0, 90, 0)
				elif Function.search_regex("conveyor", requestor.id):
					model_path.rotation_degrees = Vector3(0, 0, 0)
				model_path.show()
			"bullet_box":
				model_path.mesh = load("res://models/object/bullet-p1.obj")
				model_path.material_override = load("res://models/materials/bullet_case_toon.tres")
				model_path.scale = Vector3(0.9, 0.9, 0.9)
				model_path.rotation_degrees = Vector3(0, -108.1, 0)
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

func set_inspected_item_card(requestor, item):
	if "attack_damage" in item and item.attack_damage != null:
		requestor.AttackDamageText = str(item.attack_damage)
		if item.buff_isEnchanted:
			requestor.AttackDamageText = requestor.AttackDamageText + "+" + str(item.enchanted_bonus)
	if "attack_range" in item:
		requestor.AttackRangeText = str(item.attack_range)
		if Function.search_regex("mortar", item.id):
			requestor.AttackRangeText = str(item.attack_rangeMin) + "~" + str(item.attack_rangeMax)
		if item.id == "wall_spiked":
			requestor.AttackRangeText = "1"
	if "attack_speed" in item:
		requestor.AttackSpeedText = item.attack_speed
	if "is_mountable_occupied" in item:
		if item.is_mountable_occupied:
			requestor.AttackDamageText = str(item.currently_mountable_item.attack_damage)
			requestor.AttackRangeText = str(item.currently_mountable_item.attack_range)
			requestor.AttackSpeedText = str(item.currently_mountable_item.attack_speed)
			requestor.AmmoText = str(item.currently_mountable_item.bullet_maxammo)
			if item.currently_mountable_item.buff_isEnchanted:
				requestor.AttackDamageText = requestor.AttackDamageText + "+" + str(item.currently_mountable_item.enchanted_bonus)
			if item.currently_mountable_item.buff_isMounted:
				requestor.AttackRangeText = requestor.AttackRangeText + "+" + str(item.currently_mountable_item.mounted_bonus)
	if "bullet_maxammo" in item:
		requestor.AmmoText = str(item.bullet_maxammo)
	if "bonus_range" in item and !item.is_mountable_occupied:
		requestor.AttackRangeBuffText = "+" + str(item.bonus_range)
	if "bonus_attack" in item:
		requestor.AttackDamageBuffText = "+" + str(item.bonus_attack)
	if "base_ammo" in item:
		requestor.DroneAmmoCapacityText = str(item.max_ammo)

func check_inspected_item_card(requestor):
	if requestor.AttackDamageText != null:
		requestor.get_node("MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackDamageBg/AttackDamageLabel").text = str(requestor.AttackDamageText)
		requestor.get_node("MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackDamageBg").show()
	else:
		requestor.get_node("MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackDamageBg").hide()
		
	if requestor.AttackRangeText != null:
		requestor.get_node("MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackRangeBg/AttackRangeLabel").text = str(requestor.AttackRangeText)
		requestor.get_node("MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackRangeBg").show()
	else:
		requestor.get_node("MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackRangeBg").hide()
		
	if requestor.AttackSpeedText != null:
		requestor.get_node("MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackSpeedBg/AttackSpeedLabel").text = "%0.2f" % float(requestor.AttackSpeedText)
		requestor.get_node("MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackSpeedBg").show()
	else:
		requestor.get_node("MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackSpeedBg").hide()
	
	if requestor.AmmoText != null:
		requestor.get_node("MarginContainer/HBoxContainer/ItemImage/StatusContainer/AmmoBg/AmmoLabel").text = str(requestor.AmmoText)
		requestor.get_node("MarginContainer/HBoxContainer/ItemImage/StatusContainer/AmmoBg").show()
	else:
		requestor.get_node("MarginContainer/HBoxContainer/ItemImage/StatusContainer/AmmoBg").hide()
		
	if requestor.AttackDamageBuffText != null:
		requestor.get_node("MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackDamageBuffBg/AttackDamageBuffLabel").text = str(requestor.AttackDamageBuffText)
		requestor.get_node("MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackDamageBuffBg").show()
	else:
		requestor.get_node("MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackDamageBuffBg").hide()
		
	if requestor.AttackRangeBuffText != null:
		requestor.get_node("MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackRangeBuffBg/AttackRangeBuffLabel").text = str(requestor.AttackRangeBuffText)
		requestor.get_node("MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackRangeBuffBg").show()
	else:
		requestor.get_node("MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackRangeBuffBg").hide()
	
	if requestor.DroneAmmoCapacityText != null:
		requestor.get_node("MarginContainer/HBoxContainer/ItemImage/StatusContainer/DroneAmmoCapacityBg/DroneAmmoCapacityLabel").text = str(requestor.DroneAmmoCapacityText)
		requestor.get_node("MarginContainer/HBoxContainer/ItemImage/StatusContainer/DroneAmmoCapacityBg").show()
	else:
		requestor.get_node("MarginContainer/HBoxContainer/ItemImage/StatusContainer/DroneAmmoCapacityBg").hide()
