extends Turret_Parent

func _ready():
	ready_up()

func _process(_delta):
	start_process()
	if able_shoot and !enemies_array.is_empty():
		$Models/Head/HeadModels/Barrel.rotation_degrees.x += 5
		$Models/Head/HeadModels/Barrel2.rotation_degrees.x += 5
		$Models/Head/HeadModels/Barrel3.rotation_degrees.x += 5
