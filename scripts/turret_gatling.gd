extends Turret_Parent

func _ready():
	ready_up()

func _process(delta):
	start_process()
	var rotate_speed = 200 * delta
	if able_shoot and !enemies_array.is_empty() and bullet_ammo != 0:
		$Models/Head/HeadModels/Barrel.rotation_degrees.x += rotate_speed
		$Models/Head/HeadModels/Barrel2.rotation_degrees.x += rotate_speed
		$Models/Head/HeadModels/Barrel3.rotation_degrees.x += rotate_speed
