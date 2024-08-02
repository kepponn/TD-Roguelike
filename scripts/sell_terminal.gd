extends StaticBody3D

@onready var id = "sell"
var step_change: bool = true

@onready var sell_ui = get_node('/root/Scene/UI/Control/Sell')

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

func sell(requestor, item):
	# Item list in Global.sellable_item
	# And make sure all the item have sell price, beucase it will be needed for calculation
	# Unpriced item will be destoryed instead of 50% currency refund
	for sellable_item_check in Global.sellable_item:
		if Function.search_regex(sellable_item_check, item.id):
			requestor.inspectedItem_UI.hide()
			requestor.player_checkItemRange(requestor.player_interactedItem, false)
			sell_ui.sell_ui(requestor, item) # sell item, pass the item parameter into sell_ui.gd
			requestor.player_lockInput = true
