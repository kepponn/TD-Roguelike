extends CharacterBody3D


const SPEED = 5.0
var accel = 10

@onready var nav: NavigationAgent3D = $NavigationAgent3D
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	var direction = Vector3()
	
	
	nav.target_position = Global.final_target
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	
	
	velocity = velocity.lerp(direction * SPEED, accel * delta)
	
	
	move_and_slide()
