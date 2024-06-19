extends Enemy_Parent

var id: String = "scout_little"
var step_change: bool = true

func _ready():
	HP = 10
	SPEED = 10
	ready_up()

func _process(_delta):
	check_self(_delta)

func _physics_process(delta):
	run_navigation(delta)
	enemy_model()
	
func enemy_model():
	var rotate_look = nav.get_next_path_position()
	# Get the next path position and look at it while only rotating y axis (and not flipping like crazy)
	rotate_look.y = $Models.global_transform.origin.y
	$Models.look_at(rotate_look)
	if step_change:
		$Models/LegR.rotation_degrees.x += 1.2
		$Models/LegL.rotation_degrees.x -= 1.2
		if $Models/LegR.rotation_degrees.x >= 20:
			step_change = false
	if !step_change:
		$Models/LegR.rotation_degrees.x -= 1.2
		$Models/LegL.rotation_degrees.x += 1.2
		if $Models/LegR.rotation_degrees.x <= -20:
			step_change = true
