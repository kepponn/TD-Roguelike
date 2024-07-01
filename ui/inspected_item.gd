extends Control

@export var item_price: int
@export var item_name: String

var AttackDamageText
var AttackRangeText
var AttackSpeedText
var AmmoText
@onready var AttackDamageLabel = $MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackDamageBg/AttackDamageLabel
@onready var AttackRangeLabel = $MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackRangeBg/AttackRangeLabel
@onready var AttackSpeedLabel = $MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackSpeedBg/AttackSpeedLabel
@onready var AmmoLabel = $MarginContainer/HBoxContainer/ItemImage/StatusContainer/AmmoBg/AmmoLabel


func _process(_delta):
	if AttackDamageText != null:
		AttackDamageLabel.text = str(AttackDamageText)
		$MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackDamageBg.show()
	else:
		$MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackDamageBg.hide()
		
	if AttackRangeText != null:
		AttackRangeLabel.text = str(AttackRangeText)
		$MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackRangeBg.show()
	else:
		$MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackRangeBg.hide()
		
	if AttackSpeedText != null:
		AttackSpeedLabel.text = "%0.2f" % AttackSpeedText
		$MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackSpeedBg.show()
	else:
		$MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackSpeedBg.hide()
	
	if AmmoText != null:
		AmmoLabel.text = str(AmmoText)
		$MarginContainer/HBoxContainer/ItemImage/StatusContainer/AmmoBg.show()
	else:
		$MarginContainer/HBoxContainer/ItemImage/StatusContainer/AmmoBg.hide()

