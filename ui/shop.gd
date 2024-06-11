extends Control

@onready var shop = get_node('/root/Node3D/NavigationRegion3D/Item/Shop')
@onready var shop_item = preload("res://ui/shop_item.tscn")
@onready var empty_item = preload("res://ui/shop_empty.tscn")

@onready var shop_itemList = $PanelContainer/MarginContainer/HBoxContainer/ShopBackground/MarginContainer/Shop/ScrollContainer/ShopItem
@onready var storage_itemList = $PanelContainer/MarginContainer/HBoxContainer/StorageBackground/MarginContainer/BlueprintStorage/BlueprintStorageItem

var reroll_price: int = 10
var mouse_input

var item_rate = {
	#current sum = 250
	"wall_basic" = 100,
	"wall_mountable" = 20,
	"wall_spiked" = 20,
	"turret_basic" = 60,
	"turret_pierce" = 10,
	"turret_gatling" = 10,
	"turret_plasma" = 10,
	"extra_health" = 5,
}

var focused

func _ready():
	self.hide()
	update_item()

func _process(_delta):
	update_uiText()
	update_storageItem()
	check_mouseInput()
	check_controllerInput()

func spawn_item(scene):
	var item = scene.instantiate()
	print("Purchased ", item)
	# Since only 1 shop right now this is not an issues, if there going to be more shop then need to check for shop in node and check for parameter
	item.position = get_node('/root/Node3D/NavigationRegion3D/Item/Shop/SpawnArea').global_position
	%Item.add_child(item, true)
	get_node('/root/Node3D/NavigationRegion3D/Item/Shop').purchase()
	# Set data for player to pickup the purchased item
	get_node('/root/Node3D/Player').player_interactedItem = item
	get_node('/root/Node3D/Player').player_interactedItem_Temp = item
	get_node('/root/Node3D/Player').player_ableInteract = true

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
	if Function.search_regex("turret", property_temp.id):
		seeder.AttackDamageText = property_temp.attack_damage
		seeder.AttackRangeText = property_temp.attack_range
		seeder.AttackSpeedText = property_temp.attack_speed
		seeder.AmmoText = property_temp.bullet_maxammo
	match property_temp.id:
		"wall_spiked":
			seeder.AttackDamageText = property_temp.attack_damage
			seeder.AttackRangeText = "1"
			seeder.AttackSpeedText = property_temp.attack_speed
		"wall_mountable":
			seeder.AttackRangeText = "+1"

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

func create_empty(nodes ,index):
	var empty = empty_item.instantiate()
	nodes.add_child(empty, true)
	nodes.move_child(empty, index)
	
func check_mouseInput():
	if get_node('/root/Node3D/Player').player_lockInput:
		#check what is the last button pressed for 1 frame maybe? atleast its enough time to be used by _on_item_button_pressed(item) signal
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			mouse_input = "LMB"
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			mouse_input = "RMB"
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_NONE):
			mouse_input = ""

func check_controllerInput():
	var focused_button = get_viewport().gui_get_focus_owner()
	if get_node('/root/Node3D/Player').player_lockInput and focused_button != null:
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

func update_uiText():
	$PanelContainer2/MarginContainer/HBoxContainer/PlayerCurrency/Label.text = "Player Currency : " + str(Global.currency)
	$PanelContainer2/MarginContainer/HBoxContainer/RerollButton/Label.text = "Reroll : " + str(reroll_price) + " Gold"

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
		
func _on_close_button_pressed():
	self.hide()
	await get_tree().create_timer(0.15).timeout
	get_node('/root/Node3D/Player').player_lockInput = false
	
func _on_reroll_button_pressed():
	if Global.currency >= reroll_price:
		Global.currency = Global.currency - reroll_price
		reroll_price = reroll_price + 10
		update_item()
		$PanelContainer2/MarginContainer/HBoxContainer/RerollButton.grab_focus()
