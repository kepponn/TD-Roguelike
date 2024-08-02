extends Control

var local_requestor # temp for player, data is given in from shop_terminal.gd
var shop # being set from shop itself

@onready var shop_item = preload("res://ui/shop_item.tscn")
@onready var empty_item = preload("res://ui/shop_empty.tscn")

@onready var shop_itemList = $PanelContainer/MarginContainer/HBoxContainer/ShopBackground/MarginContainer/Shop/ScrollContainer/ShopItem
@onready var storage_itemList = $PanelContainer/MarginContainer/HBoxContainer/StorageBackground/MarginContainer/BlueprintStorage/BlueprintStorageItem

var reroll_price: int = 0
var mouse_input

var item_rate = {
	"wall_basic" = 100,
	"wall_mountable" = 15,
	"wall_spiked" = 20,
	"mortar_basic" = 10,
	"mortar_pyro" = 10,
	"mortar_cryo" = 10,
	"turret_basic" = 60,
	"turret_pierce" = 30,
	"turret_gatling" = 15,
	"turret_plasma" = 25,
	"enhancement" = 10,
	"extra_health" = 5,
	"drone_station" = 5
}

var focused

func _ready():
	self.hide()
	update_item()

func _process(_delta):
	update_ui()
	update_storageItem()
	check_keyboardInput()
	check_mouseInput()
	check_controllerInput()

func spawn_item(scene):
	shop.purchase(scene)

func seed_item(seeder, property): # property are taken from item_rate where it MUST match an item.id
	# Need to seed image placeholder and name property into shop_item.gd
	var path_temp: String = "res://scene/"+str(property)+".tscn"
	seeder.item_scene = load(path_temp)
	var property_temp = load(path_temp).instantiate()
	property_temp.seed_property()
	# need to instantiate once to get property
	seeder.find_child("Price").text = str(property_temp.price)
	seeder.item_name = str(property_temp.id)
	seeder.item_price = property_temp.price
	
	if "attack_damage" in property_temp:
		seeder.AttackDamageText = property_temp.attack_damage
	if "attack_range" in property_temp:
		seeder.AttackRangeText = property_temp.attack_range
		if property_temp.id == "mortar":
			seeder.AttackRangeText = str(property_temp.attack_rangeMin) + "~" + str(property_temp.attack_rangeMax)
		if property_temp.id == "wall_spiked":
			seeder.AttackRangeText = "1"
	if "attack_speed" in property_temp:
		seeder.AttackSpeedText = property_temp.attack_speed
	if "bullet_maxammo" in property_temp:
		seeder.AmmoText = property_temp.bullet_maxammo
	if "bonus_range" in property_temp:
		seeder.AttackRangeBuffText = "+" + str(property_temp.bonus_range)
	if "bonus_attack" in property_temp:
		seeder.AttackDamageBuffText = "+" + str(property_temp.bonus_attack)
	if "base_ammo" in property_temp:
		seeder.DroneAmmoCapacityText = property_temp.max_ammo
		
	
	#if Function.search_regex("turret", property_temp.id):
		#seeder.AttackDamageText = property_temp.attack_damage
		#seeder.AttackRangeText = property_temp.attack_range
		#seeder.AttackSpeedText = property_temp.attack_speed
		#seeder.AmmoText = property_temp.bullet_maxammo
	#if Function.search_regex("mortar", property_temp.id):
		#seeder.AttackDamageText = property_temp.attack_damage
		#seeder.AttackRangeText = str(property_temp.attack_rangeMin) + "-" + str(property_temp.attack_rangeMax)
		#seeder.AttackSpeedText = property_temp.attack_speed
	#match property_temp.id:
		#"wall_spiked":
			#seeder.AttackDamageText = property_temp.attack_damage
			#seeder.AttackRangeText = "1"
			#seeder.AttackSpeedText = property_temp.attack_speed
		#"wall_mountable":
			#seeder.AttackRangeBuffText = "+1"
		#"enhancement":
			#seeder.AttackDamageBuffText = property_temp.bonus_attack
		#"drone_station":
			#seeder.AttackRangeText = property_temp.area_range
			#seeder.DroneAmmoCapacityText = property_temp.base_ammo

func randomize_shopItem():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var weight_sum = 0
	var first_num = 0
	var second_num = 0
	
	#sum all of the weight
	for n in item_rate:
		weight_sum = weight_sum + item_rate[n]
		
	#choose a random number between 0 to total weight
	var random_number = rng.randi_range(1,weight_sum)
	#print("your random generated number is : ", random_number)
	
	for n in item_rate:
		first_num = second_num
		second_num = second_num  + item_rate[n]
		if random_number > first_num and random_number <= second_num:
			#print("your number are between: ", first_num, " and ", second_num)
			#print("therefore spawned item will be: ", n)
			return n

func update_item():
	for item in shop_itemList.get_children():
			item.queue_free()
	for items in range(8):
		var item = shop_item.instantiate()
		seed_item(item, randomize_shopItem())
		shop_itemList.add_child(item, true)
		item.pressed.connect(_on_item_button_pressed.bind(item))
		item.mouse_entered.connect(_on_button_mouse_entered.bind(item))

func create_empty(nodes ,index):
	var empty = empty_item.instantiate()
	nodes.add_child(empty, true)
	nodes.move_child(empty, index)
	
func check_keyboardInput():
	var focused_button = get_viewport().gui_get_focus_owner()
	if local_requestor != null and local_requestor.player_lockInput and focused_button != null:
		# This dedicated for the following action: buy, reroll, close (all in ui button focus form)
		if Input.is_action_just_pressed("interact"):
			mouse_input = "LMB"
			focused_button.emit_signal("pressed")
			print(focused_button)
		# This dedicated for only shop item to reserve/save the item blueprint
		elif Input.is_action_just_pressed("inspect") and focused_button.get_parent().name == "ShopItem":
			mouse_input = "RMB"
			focused_button.emit_signal("pressed")
			print(focused_button)
	
func check_mouseInput():
	if local_requestor != null and local_requestor.player_lockInput:
		#check what is the last button pressed for 1 frame maybe? atleast its enough time to be used by _on_item_button_pressed(item) signal
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			mouse_input = "LMB"
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			mouse_input = "RMB"
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_NONE):
			mouse_input = ""

func check_controllerInput(): # use requestor param?
	var focused_button = get_viewport().gui_get_focus_owner()
	if local_requestor != null and local_requestor.player_lockInput and focused_button != null:
		# This dedicated for the following action: buy, reroll, close (all in ui button focus form)
		if Input.is_action_just_pressed("controller_A"):
			mouse_input = "LMB"
			focused_button.emit_signal("pressed")
			print(focused_button)
		# This dedicated for only shop item to reserve/save the item blueprint
		elif Input.is_action_just_pressed("controller_X") and focused_button.get_parent().name == "ShopItem":
			mouse_input = "RMB"
			focused_button.emit_signal("pressed")
			print(focused_button)
		elif Input.is_action_just_pressed("controller_B"):
			_on_close_button_pressed()
		elif Input.is_action_just_pressed("controller_Y"):
			_on_reroll_button_pressed()

func update_ui():
	$PanelContainer2/MarginContainer/HBoxContainer/PlayerCurrency/Label.text = "Player Currency : " + str(Global.currency)
	if reroll_price <= 50:
		$PanelContainer2/MarginContainer/HBoxContainer/RerollButton/Label.text = "Reroll : " + str(reroll_price) + " Gold"
		$PanelContainer2/MarginContainer/HBoxContainer/RerollButton/Label.self_modulate = Color("#ffffff")
		$PanelContainer2/MarginContainer/HBoxContainer/RerollButton.disabled = false
	else :
		$PanelContainer2/MarginContainer/HBoxContainer/RerollButton/Label.text = "Reroll Unavailable"
		$PanelContainer2/MarginContainer/HBoxContainer/RerollButton/Label.self_modulate = Color("#858585")
		$PanelContainer2/MarginContainer/HBoxContainer/RerollButton.disabled = true

func update_storageItem():
	#always show 1st and 2nd child
	storage_itemList.get_child(0).show()
	storage_itemList.get_child(1).show()
	#always hide 3rd if there is 3 child and hide 3rd and 4th child if there if 4 child
	if storage_itemList.get_child_count() == 3:
		storage_itemList.get_child(2).hide()
	elif storage_itemList.get_child_count() == 4:
		storage_itemList.get_child(2).hide()
		storage_itemList.get_child(3).hide()

func _on_item_button_pressed(item):
	#Buy Item from Shop
	if mouse_input == "LMB" and item.get_parent().name == "ShopItem":
		if Global.currency >= item.item_price:
			Global.currency = Global.currency - item.item_price
			spawn_item(item.item_scene)
			create_empty(shop_itemList, item.get_index())
			item.queue_free()
			_on_close_button_pressed()
	
	#Buy Item from Storage
	elif mouse_input == "LMB" and item.get_parent().name == "BlueprintStorageItem":
		if Global.currency >= item.item_price:
			Global.currency = Global.currency - item.item_price
			spawn_item(item.item_scene)
			item.queue_free()
			_on_close_button_pressed()
	
	#Move Item to Storage
	elif mouse_input == "RMB" and storage_itemList.get_child_count() < 4 and item.get_parent().name == "ShopItem":
		print(item.name , " Locked")
		create_empty(shop_itemList, item.get_index())
		item.reparent(storage_itemList)
		storage_itemList.move_child(item,0)
		storage_itemList.get_child(0).grab_focus()

func _on_button_mouse_entered(item):
	print(item)
	item.grab_focus()

func _on_close_button_pressed():
	self.hide()
	await get_tree().create_timer(0.15).timeout
	local_requestor.player_lockInput = false
	local_requestor = null
	shop = null

func _on_reroll_button_pressed():
	if Global.currency >= reroll_price and reroll_price <= 50:
		Global.currency = Global.currency - reroll_price
		Stats.shop_reroll_used += 1
		Stats.shop_highest_reroll = reroll_price
		reroll_price = reroll_price + 10
		update_item()
		$PanelContainer2/MarginContainer/HBoxContainer/RerollButton.grab_focus()

func _on_reroll_button_mouse_entered():
	$PanelContainer2/MarginContainer/HBoxContainer/RerollButton.grab_focus()

func _on_close_button_mouse_entered():
	$PanelContainer2/MarginContainer/HBoxContainer/CloseButton.grab_focus()
