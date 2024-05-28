extends Control

@onready var testItem1 = preload("res://scene/test_item_1.tscn").instantiate()
@onready var turret_pierce = preload("res://scene/turret_pierce.tscn").instantiate()
@onready var turret_basic = preload("res://scene/turret_basic.tscn").instantiate()
@onready var shop_item = preload("res://ui/shop_item.tscn")
@onready var empty_item = preload("res://ui/shop_empty.tscn")

@onready var shop_itemList = $PanelContainer/MarginContainer/HBoxContainer/ShopBackground/MarginContainer/Shop/ScrollContainer/ShopItem
@onready var storage_itemList = $PanelContainer/MarginContainer/HBoxContainer/StorageBackground/MarginContainer/BlueprintStorage/BlueprintStorageItem


# Called when the node enters the scene tree for the first time
var reroll_price: int = 10
var mouse_input


func _ready():
	update_item()

func _process(_delta):
	update_uiText()
	update_storageItem()
	check_mouseInput()

func update_item():
	for item in shop_itemList.get_children():
			item.queue_free()
	for items in range(8):
		var item = shop_item.instantiate()
		
		var randomizer = randi_range(0,9)
		if randomizer >= 0 and randomizer < 3:
			item.find_child("Price").text = str(15) + " Gold Basic"
			item.item_price = 15
		elif randomizer >= 3 and randomizer < 6:
			item.find_child("Price").text = str(turret_basic.turret_price) + " Gold Basic"
			item.item_price = turret_basic.turret_price
		elif randomizer >= 6 and randomizer < 10:
			item.find_child("Price").text = str(turret_pierce.turret_price) + " Gold Pierce"
			item.item_price = turret_pierce.turret_price
		
		shop_itemList.add_child(item, true)
		item.pressed.connect(_on_item_button_pressed.bind(item))
	
	#for item in shop_itemList.get_children():
		##to make button enabled and able to be interacted
		##used after reroll, and will not do anything on first time
		#item.disabled = false
		#
		#var randomizer = randi_range(0,9)
		#if randomizer >= 0 and randomizer < 3:
			#pass
		#elif randomizer >= 3 and randomizer < 6:
			#item.find_child("Price").text = str(turret_basic.turret_price) + " Gold Basic"
			#item.item_price = turret_basic.turret_price
		#elif randomizer >= 6 and randomizer < 10:
			#item.find_child("Price").text = str(turret_pierce.turret_price) + " Gold Pierce"
			#item.item_price = turret_pierce.turret_price

func create_empty(nodes ,index):
	var empty = empty_item.instantiate()
	nodes.add_child(empty, true)
	nodes.move_child(empty, index)
	

func check_mouseInput():
	#check what is the last button pressed for 1 frame maybe? atleast its enough time to be used by _on_item_button_pressed(item) signal
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		mouse_input = "LMB"
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		mouse_input = "RMB"
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_NONE):
		mouse_input = ""

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
			create_empty(shop_itemList, item.get_index())
			item.queue_free()
			self.hide()
	
	#Buy Item from Storage
	elif mouse_input == "LMB" and item.get_parent().name == "BlueprintStorageItem":
		if Global.currency >= item.item_price:
			Global.currency = Global.currency - item.item_price
			item.queue_free()
			self.hide()
	
	#Move Item to Storage
	elif mouse_input == "RMB" and storage_itemList.get_child_count() < 4:
		print(item.name , " Locked")
		create_empty(shop_itemList, item.get_index())
		item.reparent(storage_itemList)
		storage_itemList.move_child(item,0)
		
func _on_close_button_pressed():
	self.hide()

func _on_reroll_button_pressed():
	if Global.currency >= reroll_price:
		Global.currency = Global.currency - reroll_price
		reroll_price = reroll_price + 10
		update_item()
		
		
