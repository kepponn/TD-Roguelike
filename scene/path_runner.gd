extends CharacterBody3D

var direction = Vector3()
@onready var nav: NavigationAgent3D = $NavigationAgent3D

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
	# This is still a wrong implementation of delta time but at lease it works
	# velocity = direction * SPEED * (0.2 + delta)
	# The use of lerp in here make that the enemy navigation dont stuck like a fucking retard
	# Please check and tweak the $NavigationRegion3D
	var rotate_look = nav.get_next_path_position()
	# Get the next path position and look at it while only rotating y axis (and not flipping like crazy)
	rotate_look.y = self.global_transform.origin.y
	self.look_at(rotate_look)
	velocity = direction * 25 * (0.2 + delta)
	move_and_slide()

func _on_navigation_agent_3d_navigation_finished():
	queue_free()
