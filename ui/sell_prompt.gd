extends Control

@onready var player = get_node('/root/Scene/Player')
@onready var player_holded_item = get_node('/root/Scene/Player/Node3D/Holded Item')

@onready var button = %No
@onready var text = %Label

var sell_price

func _ready():
	self.hide()

func sell_prompt(item):
	sell_price = int(item.price * 0.5)
	text.text = "Sell " + str(item.name) + "\nfor " + str(sell_price) + " currency?" 
	self.show()
	button.grab_focus()
	# Pop up with item stats and confirmation button for selling the item
	print("Player is trying to sell ", item.name ," for half-price of ", sell_price, " currency")

func _on_yes_pressed():
	player_holded_item.get_child(-1).queue_free()
	player.player_placementPreview(false)
	player.player_isHoldingItem = false
	player.player_interactedItem = null
	Global.currency += sell_price
	self.hide()
	await get_tree().create_timer(0.15).timeout
	player.player_lockInput = false

func _on_no_pressed():
	self.hide()
	await get_tree().create_timer(0.15).timeout
	player.player_lockInput = false
