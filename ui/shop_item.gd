extends Button

@export var item_price: int
@export var item_name: String



#@onready var label1 = $MarginContainer/HBoxContainer/ItemImage/StatusContainer/InfoBg1/InfoLabel1
#@onready var label2 = $MarginContainer/HBoxContainer/ItemImage/StatusContainer/InfoBg2/InfoLabel2
#@onready var label3 = $MarginContainer/HBoxContainer/ItemImage/StatusContainer/InfoBg3/InfoLabel3
#@onready var label4 = $MarginContainer/HBoxContainer/ItemImage/StatusContainer/InfoBg4/InfoLabel4

var text1
var text2
var text3
var text4
@onready var label1 = %InfoLabel1
@onready var label2 = %InfoLabel2
@onready var label3 = %InfoLabel3
@onready var label4 = %InfoLabel4

#@onready var icon4 = %InfoIcon4

var item_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	if text1 != null:
		label1.text = str(text1)
		$MarginContainer/HBoxContainer/ItemImage/StatusContainer/InfoBg1.show()
	if text2 != null:
		label2.text = str(text2)
		$MarginContainer/HBoxContainer/ItemImage/StatusContainer/InfoBg2.show()
	if text3 != null:
		label3.text = str(text3)
		$MarginContainer/HBoxContainer/ItemImage/StatusContainer/InfoBg3.show()
	if text4 != null:
		label4.text = str(text4)
		$MarginContainer/HBoxContainer/ItemImage/StatusContainer/InfoBg4.show()
	
	$MarginContainer/HBoxContainer/TextureRect/Price.text = str(item_price) + " Gold"
	#$MarginContainer/HBoxContainer/TextureRect.texture.load("res://.godot/imported/buttons.png-e7056a10076d4ac74fa23b5d0ee8fab6.ctex")
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(_delta):
	update_modulate()

func update_modulate():
	if disabled == true:
		modulate = Color("#636363")
	else:
		modulate = Color("#ffffff")

