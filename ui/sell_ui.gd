extends Control

@onready var button = %No
@onready var text = %Label

var sell_price
var local_requestor # this is temp variable for requestor since it needed for automatic signal from button

func _ready():
	self.hide()

func sell_ui(requestor, item):
	local_requestor = requestor
	$InspectedItemUI.setter(item)
	# Check the price make it half price to sell or 0 if it have no price
	if "price" in item:
		sell_price = int(item.price * 0.5)
		text.text = "Sell " + str(item.name) + "\nfor " + str(sell_price) + " currency?" 
		print("Player is trying to sell ", item.name ," for half-price of ", sell_price, " currency")
	else:
		sell_price = 0
		text.text = "Destroy " + str(item.name) + "?"
		print("Player is trying to destory ", item.name)
	# Pop up with item stats and confirmation button for selling the item
	self.show()
	button.grab_focus()

func _on_yes_pressed():
	local_requestor.holded_item.get_child(-1).queue_free()
	local_requestor.player_placementPreview(false)
	local_requestor.player_isHoldingItem = false
	local_requestor.player_interactedItem = null
	Global.currency += sell_price
	quit_and_flush_requestor()

func _on_no_pressed():
	quit_and_flush_requestor()

func quit_and_flush_requestor():
	$InspectedItemUI.reset()
	self.hide()
	await get_tree().create_timer(0.15).timeout
	local_requestor.player_lockInput = false
	local_requestor = null
