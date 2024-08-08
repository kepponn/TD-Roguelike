extends Control

@export var item_price: int
@export var item_name: String

@onready var ui_icon_parent = $MarginContainer/HBoxContainer/ItemImage/StatusContainer

var AttackDamageText
var AttackRangeText
var AttackSpeedText
var AmmoText
var AttackDamageBuffText
var AttackRangeBuffText
var DroneAmmoCapacityText
@onready var AttackDamageLabel = $MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackDamageBg/AttackDamageLabel
@onready var AttackRangeLabel = $MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackRangeBg/AttackRangeLabel
@onready var AttackSpeedLabel = $MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackSpeedBg/AttackSpeedLabel
@onready var AmmoLabel = $MarginContainer/HBoxContainer/ItemImage/StatusContainer/AmmoBg/AmmoLabel
@onready var AttackDamageBuffLabel = $MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackDamageBuffBg/AttackDamageBuffLabel
@onready var AttackRangeBuffLabel = $MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackRangeBuffBg/AttackRangeBuffLabel
@onready var DroneAmmoCapacityLabel = $MarginContainer/HBoxContainer/ItemImage/StatusContainer/DroneAmmoCapacityBg/DroneAmmoCapacityLabel

func reset():
	AttackDamageText = null
	AttackRangeText = null
	AttackSpeedText = null
	AmmoText = null
	AttackDamageBuffText = null
	AttackRangeBuffText = null
	DroneAmmoCapacityText = null

# using process is too slow and the timing is fucked up
func setter(item):
	Function.set_inspected_item_card(self, item)
	#if "attack_damage" in Item and Item.attack_damage != null:
		#AttackDamageText = str(Item.attack_damage)
		#if Item.buff_isEnchanted:
			#AttackDamageText = AttackDamageText + "+" + str(Item.enchanted_bonus)
	#if "attack_range" in Item:
		#AttackRangeText = str(Item.attack_range)
		#if Function.search_regex("mortar", Item.id):
			#AttackRangeText = str(Item.attack_rangeMin) + "~" + str(Item.attack_rangeMax)
		#if Item.id == "wall_spiked":
			#AttackRangeText = "1"
	#if "attack_speed" in Item:
		#AttackSpeedText = Item.attack_speed
	#if "is_mountable_occupied" in Item:
		#if Item.is_mountable_occupied:
			#AttackDamageText = str(Item.currently_mountable_item.attack_damage)
			#AttackRangeText = str(Item.currently_mountable_item.attack_range)
			#AttackSpeedText = str(Item.currently_mountable_item.attack_speed)
			#AmmoText = str(Item.currently_mountable_item.bullet_maxammo)
			#if Item.currently_mountable_item.buff_isEnchanted:
				#AttackDamageText = AttackDamageText + "+" + str(Item.currently_mountable_item.enchanted_bonus)
			#if Item.currently_mountable_item.buff_isMounted:
				#AttackRangeText = AttackRangeText + "+" + str(Item.currently_mountable_item.mounted_bonus)
	#if "bullet_maxammo" in Item:
		#AmmoText = str(Item.bullet_maxammo)
	#if "bonus_range" in Item and !Item.is_mountable_occupied:
		#AttackRangeBuffText = "+" + str(Item.bonus_range)
	#if "bonus_attack" in Item:
		#AttackDamageBuffText = "+" + str(Item.bonus_attack)
	#if "base_ammo" in Item:
		#DroneAmmoCapacityText = str(Item.max_ammo)
	
	update_UI()
	
func update_UI():
	Function.check_inspected_item_card(self)
	#if AttackDamageText != null:
		#AttackDamageLabel.text = str(AttackDamageText)
		#$MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackDamageBg.show()
	#else:
		#$MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackDamageBg.hide()
		#
	#if AttackRangeText != null:
		#AttackRangeLabel.text = str(AttackRangeText)
		#$MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackRangeBg.show()
	#else:
		#$MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackRangeBg.hide()
		#
	#if AttackSpeedText != null:
		#AttackSpeedLabel.text = "%0.2f" % float(AttackSpeedText)
		#$MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackSpeedBg.show()
	#else:
		#$MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackSpeedBg.hide()
	#
	#if AmmoText != null:
		#AmmoLabel.text = str(AmmoText)
		#$MarginContainer/HBoxContainer/ItemImage/StatusContainer/AmmoBg.show()
	#else:
		#$MarginContainer/HBoxContainer/ItemImage/StatusContainer/AmmoBg.hide()
		#
	#if AttackDamageBuffText != null:
		#AttackDamageBuffLabel.text = str(AttackDamageBuffText)
		#$MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackDamageBuffBg.show()
	#else:
		#$MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackDamageBuffBg.hide()
		#
	#if AttackRangeBuffText != null:
		#AttackRangeBuffLabel.text = str(AttackRangeBuffText)
		#$MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackRangeBuffBg.show()
	#else:
		#$MarginContainer/HBoxContainer/ItemImage/StatusContainer/AttackRangeBuffBg.hide()
	#
	#if DroneAmmoCapacityText != null:
		#DroneAmmoCapacityLabel.text = str(DroneAmmoCapacityText)
		#$MarginContainer/HBoxContainer/ItemImage/StatusContainer/DroneAmmoCapacityBg.show()
	#else:
		#$MarginContainer/HBoxContainer/ItemImage/StatusContainer/DroneAmmoCapacityBg.hide()
