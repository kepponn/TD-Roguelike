extends CharacterBody3D


@export var SPEED = 2.5
@export var HP = 3

var accel = 10
var direction = Vector3()



@onready var nav: NavigationAgent3D = $NavigationAgent3D
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	call_deferred("nav_setup")

func nav_setup():
	# await for 1 frame in process and nav error gone, wizard programming
	#if needed there is baking_finished() signal on NavigationRegion3D
	await get_tree().physics_frame
	
	
	nav.target_position = Global.final_target
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()

func _physics_process(delta):
	nav_setup()
	velocity = velocity.lerp(direction * SPEED, accel * delta)
	move_and_slide()
	
func hit(damage):
	HP = HP - damage
	if HP <= 0:
		queue_free()



