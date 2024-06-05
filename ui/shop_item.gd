extends Button

@export var item_price: int
@export var item_name: String

var AttackDamageText
var AttackRangeText
var AttackSpeedText
var AmmoText

@onready var AttackDamageLabel = %AttackDamageLabel
@onready var AttackRangeLabel = %AttackRangeLabel
@onready var AttackSpeedLabel = %AttackSpeedLabel
@onready var AmmoLabel = %AmmoLabel

var item_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	if AttackDamageText != null:
		AttackDamageLabel.text = str(AttackDamageText)
		$MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackDamageBg.show()
	if AttackRangeText != null:
		AttackRangeLabel.text = str(AttackRangeText)
		$MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackRangeBg.show()
	if AttackSpeedText != null:
		AttackSpeedLabel.text = str(AttackSpeedText)
		$MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackSpeedBg.show()
	if AmmoText != null:
		AmmoLabel.text = str(AmmoText)
		$MarginContainer/HBoxContainer/ItemImage/StatusContainer/AmmoBg.show()
	
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

