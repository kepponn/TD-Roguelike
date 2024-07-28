extends Enemy_Parent

var id: String = "enemy_flying_test"
var step_change: bool = true

func _ready():
	HP = 50
	SPEED = 7
	ready_up()

func _process(delta):
	#check_self()
	$Models/Rotor.rotation_degrees.y += 320 * delta

func _physics_process(delta):
	run_navigation(delta)
	enemy_model()
	
func enemy_model():
	var rotate_look = nav.get_next_path_position()
	# Get the next path position and look at it while only rotating y axis (and not flipping like crazy)
	rotate_look.y = $Models.global_transform.origin.y
	$Models.look_at(rotate_look)
