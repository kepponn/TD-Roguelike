extends CharacterBody3D
class_name Enemy_Parent

@export var HP: int # = 3
@export var SPEED: float # = 10

@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var spawn = get_node('/root/Node3D/Spawn')

var max_HP: int
var direction: Vector3

func ready_up():
	max_HP = HP
	call_deferred("nav_setup")
	spawn.enemy_spawn()

func check_self(_delta):
	if HP <= 0:
		Global.currency = Global.currency + 5
		Global.enemy_left = Global.enemy_left - 1
		spawn.enemy_died()
		print("Enemy Left = ",Global.enemy_left)
		queue_free()

func run_navigation(delta):
	nav_setup()
	# This is still a wrong implementation of delta time but at lease it works
	# velocity = direction * SPEED * (0.2 + delta)
	# The use of lerp in here make that the enemy navigation dont stuck like a fucking retard
	# Please check and tweak the $NavigationRegion3D
	velocity = velocity.lerp(direction * SPEED * (0.2 + delta), 0.15)
	move_and_slide()
	update_HP()

func nav_setup():
	# await for 1 frame in process and nav error gone, wizard programming
	#if needed there is baking_finished() signal on NavigationRegion3D
	await get_tree().physics_frame
	nav.target_position = Global.final_target
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	
func hit(damage):
	HP = HP - damage

func update_HP():
	if HP != max_HP:
		$HealthBar3D.show()
		
	$HealthBar3D/SubViewport/HealthBar2D.max_value = max_HP
	$HealthBar3D/SubViewport/HealthBar2D.value = HP

func _on_navigation_agent_3d_target_reached():
	if Global.life_array.is_empty():
		get_tree().change_scene_to_file("res://ui/main_menu.tscn")
	if Global.life_array.size() > 0:
		Global.life_array[0].destroy()
	Global.enemy_left = Global.enemy_left - 1
	queue_free()
