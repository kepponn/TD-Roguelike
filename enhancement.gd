extends StaticBody3D

var id = "enhancement"

# Default state is false
# Therefore need to turn on active state to use, after done then returning back to default state
func _ready():
	active_state(false)

func _process(_delta):
	# Could be check in here or instead check if item have change
	if !Global.preparation_phase:
		active_state(true)
	else:
		active_state(false)

func active_state(enable: bool = true):
	# To check the new area do state change from false to true
	match enable:
		true:
			$Area3D.monitoring = true
			$Area3D.monitorable = true
			$Models/Crystal.material_override = load("res://models/textures/enemy_metalic.tres")
			$Models/Crystal2.material_override = load("res://models/textures/enemy_metalic.tres")
			$Models/Crystal3.material_override = load("res://models/textures/enemy_metalic.tres")
		false:
			$Area3D.monitoring = false
			$Area3D.monitorable = false
			$Models/Crystal.material_override = load("res://models/textures/bullet_case.tres")
			$Models/Crystal2.material_override = load("res://models/textures/bullet_case.tres")
			$Models/Crystal3.material_override = load("res://models/textures/bullet_case.tres")

func _on_area_3d_body_entered(body):
	if body.is_class("StaticBody3D") and body.get_parent().name == 'Item':
		if Function.search_regex("turret", body.id):
			print("Buff(+) damage to ", body)
			body.update_damage(5)
		elif Function.search_regex("wall_mountable", body.id) and body.is_mountable_occupied:
			print("Buff(+) damage to mounted ", body.currently_mountable_item)
			body.currently_mountable_item.update_damage(5)

func _on_area_3d_body_exited(body):
	if body.is_class("StaticBody3D") and body.get_parent().name == 'Item':
		if Function.search_regex("turret", body.id):
			print("Buff(-) damage to ", body)
			body.update_damage(-5)
		elif Function.search_regex("wall_mountable", body.id) and body.is_mountable_occupied:
			print("Buff(-) damage to mounted ", body.currently_mountable_item)
			body.currently_mountable_item.update_damage(-5)
