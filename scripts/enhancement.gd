extends StaticBody3D

var id = "enhancement"
var bonus_attack = 5

@onready var area = $Range
@onready var visible_range = $Range/VisibleRange
# Default state is false
# Therefore need to turn on active state to use, after done then returning back to default state
func _ready():
	active_state(false)
	visible_range.hide()

func _process(_delta):
	# Could be check in here or instead check if item have change
	update_range_visual()
	if !Global.preparation_phase:
		active_state(true)
	else:
		active_state(false)

func active_state(enable: bool = true):
	# To check the new area do state change from false to true
	match enable:
		true:
			area.monitoring = true
			area.monitorable = true
			$Models/Crystal.material_override = load("res://models/textures/enemy_metalic.tres")
			$Models/Crystal2.material_override = load("res://models/textures/enemy_metalic.tres")
			$Models/Crystal3.material_override = load("res://models/textures/enemy_metalic.tres")
		false:
			area.monitoring = false
			area.monitorable = false
			$Models/Crystal.material_override = load("res://models/textures/bullet_case.tres")
			$Models/Crystal2.material_override = load("res://models/textures/bullet_case.tres")
			$Models/Crystal3.material_override = load("res://models/textures/bullet_case.tres")

func update_range_visual():
	if $Range/VisibleRange.visible and $Range/VisibleRange.global_position.y != 0.6:
		$Range/VisibleRange.global_position.y = 0.6

func _on_area_3d_body_entered(body):
	if body.is_class("StaticBody3D") and body.get_parent().name == 'Item':
		if Function.search_regex("turret", body.id):
			print("Buff(+) damage to ", body)
			#body.update_damage(5)
			body.update_status("enchanted", true, bonus_attack)
		elif Function.search_regex("wall_spiked", body.id):
			print("Buff(+) damage to ", body)
			#body.currently_mountable_item.update_damage(5)
			body.update_status("enchanted", true, bonus_attack)
		elif Function.search_regex("mortar", body.id):
			print("Buff(+) damage to ", body)
			#body.currently_mountable_item.update_damage(5)
			body.update_status("enchanted", true, bonus_attack)
		elif Function.search_regex("wall_mountable", body.id) and body.is_mountable_occupied:
			print("Buff(+) damage to mounted ", body.currently_mountable_item)
			#body.currently_mountable_item.update_damage(5)
			body.currently_mountable_item.update_status("enchanted", true, bonus_attack)
		
func _on_area_3d_body_exited(body):
	if body.is_class("StaticBody3D") and body.get_parent().name == 'Item':
		if Function.search_regex("turret", body.id):
			print("Buff(-) damage to ", body)
			#body.update_damage(-5)
			body.update_status("enchanted", false)
		elif Function.search_regex("wall_spiked", body.id):
			print("Buff(-) damage to ",body)
			#body.currently_mountable_item.update_damage(-5)
			body.update_status("enchanted", false)
		elif Function.search_regex("wall_mountable", body.id) and body.is_mountable_occupied:
			print("Buff(-) damage to mounted ", body.currently_mountable_item)
			#body.currently_mountable_item.update_damage(-5)
			body.currently_mountable_item.update_status("enchanted", false)
		
