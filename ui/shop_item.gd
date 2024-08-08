extends Button

@export var item_price: int
@export var item_name: String

var AttackDamageText
var AttackRangeText
var AttackSpeedText
var AmmoText
var AttackDamageBuffText
var AttackRangeBuffText
var DroneAmmoCapacityText
@onready var AttackDamageLabel = %AttackDamageLabel
@onready var AttackRangeLabel = %AttackRangeLabel
@onready var AttackSpeedLabel = %AttackSpeedLabel
@onready var AmmoLabel = %AmmoLabel
@onready var AttackDamageBuffLabel = %AttackDamageBuffLabel
@onready var AttackRangeBuffLabel = %AttackRangeBuffLabel
@onready var DroneAmmoCapacityLabel = %DroneAmmoCapacityLabel

var item_scene: PackedScene

func setter(item):
	Function.set_inspected_item_card(self, item)
	update_UI()

func update_UI():
	Function.check_inspected_item_card(self)
	$MarginContainer/HBoxContainer/TextureRect/Price.text = str(item_price) + " Gold"

func _process(_delta):
	update_modulate()

func update_modulate():
	if disabled == true:
		modulate = Color("#636363")
	else:
		modulate = Color("#ffffff")

