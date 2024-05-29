extends Turret_Parent

func _ready():
	ready_up()

func _process(_delta):
	start_process()
	if able_shoot and !enemies_array.is_empty():
		$Head/turret_head_gatling.rotation_degrees.x += 5
