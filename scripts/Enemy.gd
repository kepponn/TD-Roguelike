extends CharacterBody3D


@export var SPEED = 200
@export var HP: int = 3
var step_change: bool = true

var direction = Vector3()

@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var spawn = get_node('/root/Node3D/Spawn')

func _ready():
	call_deferred("nav_setup")
	spawn.enemy_spawn()

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
	velocity = velocity.lerp(direction * SPEED * (0.2 + delta), 0.15)
	move_and_slide()
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
	
func hit(damage):
	HP = HP - damage
	if HP <= 0:
		Global.currency = Global.currency + 5
		Global.enemy_left = Global.enemy_left - 1
		spawn.enemy_died()
		queue_free()

func _on_navigation_agent_3d_target_reached():
	if Global.life_array.is_empty():
		get_tree().change_scene_to_file("res://ui/main_menu.tscn")
	if Global.life_array.size() > 0:
		Global.life_array[0].destroy()
	Global.enemy_left = Global.enemy_left - 1
	queue_free()
	
