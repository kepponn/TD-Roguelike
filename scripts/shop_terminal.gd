extends StaticBody3D

@onready var id = "shop"
var step_change: bool = true

@onready var spawn_area = $SpawnArea
@onready var shop_ui = get_node('/root/Scene/UI/Control/Shop')
@onready var shop_ui_button = get_node('/root/Scene/UI/Control/Shop/PanelContainer2/MarginContainer/HBoxContainer/CloseButton')

func _process(delta):
	var process_speed = 0.4 * delta
	if step_change:
		$Models/ScanLight.position.y -= process_speed
		$Models/ScanLine.position.y -= process_speed
		$Models/ScanLine_001.position.y += process_speed
		$Models/ScanLight_001.position.y += process_speed
		if $Models/ScanLight.position.y <= -0.98:
			step_change = false
	if !step_change:
		$Models/ScanLight.position.y += process_speed
		$Models/ScanLine.position.y += process_speed
		$Models/ScanLine_001.position.y -= process_speed
		$Models/ScanLight_001.position.y -= process_speed
		if $Models/ScanLight.position.y >= 0:
			step_change = true

func open_shop(requestor):
	requestor.player_lockInput = true
	shop_ui.show()
	shop_ui.shop = self
	shop_ui.local_requestor = requestor
	shop_ui_button.grab_focus()

func purchase(scene):
	var item = scene.instantiate()
	print("Purchased ", item)
	Stats.shop_purchased(item)
	$PurchaseSfx.play(0.05)
	# Since only 1 shop right now this is not an issues, if there going to be more shop then need to check for shop in node and check for parameter
	# thii issues is fixed because every interaction it will send the shop data into ui and back to shop to spawn and etc
	item.position = spawn_area.global_position
	%Item.add_child(item, true)
	# Set data for player to pickup the purchased item if needed, this result in item being blinked
	#player.player_interactedItem = item
	#player.player_interactedItem_Temp = item
	#player.player_ableInteract = true
	
