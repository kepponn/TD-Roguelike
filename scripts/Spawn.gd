extends Marker3D

var enemies: PackedScene = preload("res://scene/enemy.tscn")

@onready var spawn_timer: Timer = $Timer
@onready var nav: NavigationAgent3D = $SpawnLocation/NavigationAgent3D
var direction
var velocity

var path_runner_green = preload("res://scene/path_runner_green.tscn")
var path_runner_red = preload("res://scene/path_runner_red.tscn")
var path_runner_yellow = preload("res://scene/path_runner_yellow.tscn")

#var path_points = []
#var path_points_red = preload("res://scene/path_direction_red.tscn")
#var path_lines_red = preload("res://scene/path_lines_red.tscn")
#var path_points_green = preload("res://scene/path_direction_green.tscn")
#var path_lines_green = preload("res://scene/path_lines_green.tscn")
#var green_opacity = load("res://assets/shaders/green_opacity.tres")
#var red_opacity = load("res://assets/shaders/red_opacity.tres")

func _ready():
	pass

func _process(_delta):
	spawn_enemies()
	check_path()

func check_path():
	nav.target_position = Global.final_target
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	#path_points = nav.get_current_navigation_path()
	# This insert the path in one array?!
	# [(-8, 1, -8), (-6.988095, 1, -5.773809), (-6.75, 1, -5.25), (-4.901961, 1, -4.539216), (-3.5, 1, -4), (-3.5, 1, -4), (1, 1, -2.5), (1, 1, -1.5), (1, 1, -0.5), (0.573171, 1, 0.963415), (0.557692, 1, 1.016484), (0.143617, 1, 2.43617), (0.121076, 1, 2.513453), (0.10757, 1, 2.559761), (-0.151899, 1, 3.449367), (-0.75, 1, 5.5), (-0.5, 1, 7), (7.5, 1, 7), (8, 1, 7)]
	
	if nav.is_target_reachable() == true :
		Global.is_pathReachable = true
		#print("path is ok")
	elif nav.is_target_reachable() == false :
		Global.is_pathReachable = false
		#print("path is blocked")

func _on_preview_timer_timeout():
	await run_preview_path(Global.is_pathReachable)
	$PreviewPath/PreviewTimer.start(5)

func run_preview_path(is_reachable):
	var path_instance_arrow
	if Global.preparation_phase == true:
		for i in range(5):
			if is_reachable:
				path_instance_arrow = path_runner_green.instantiate() 
			else:
				path_instance_arrow = path_runner_red.instantiate() 
			path_instance_arrow.transform.origin = $SpawnLocation.position
			$PreviewPath.add_child(path_instance_arrow, true)
			await get_tree().create_timer(0.15).timeout
	else:
		for i in range(5):
			path_instance_arrow = path_runner_yellow.instantiate() 
			path_instance_arrow.transform.origin = $SpawnLocation.position
			$PreviewPath.add_child(path_instance_arrow, true)
			await get_tree().create_timer(0.15).timeout

func _on_navigation_agent_3d_path_changed():
	#preview_path(Global.is_pathReachable)
	pass

#func preview_path(is_reachable): # Being called manually by player with tab
	## Need to call this dynamically when paths is changed (dont put this in process)
	#for child in $PreviewPath.get_children(): # Flush points
		#child.queue_free()
	#for i in range(path_points.size() - 1): # Draw points (without the last one)
		## Still arguing to skip the first node for arrow draw...
		#var point = path_points[i]
		#var next_point = path_points[i + 1]
		## Point angle needed to angle rotation_degrees.y to next path node
		#var point_dir = (next_point - point).normalized()
		#var point_angle = atan2(point_dir.x, point_dir.z)
		#var point_range = point.distance_to(next_point)
		## Assign type of models to draw based on reachable status
		#var path_instance_arrow
		#var path_instance_lines
		#if is_reachable:
			#path_instance_arrow = path_points_green.instantiate() 
			#path_instance_lines = path_lines_green.instantiate()
		#else:
			#path_instance_arrow = path_points_red.instantiate() 
			#path_instance_lines = path_lines_red.instantiate()
		## --- Draw arrow start here ---
		#path_instance_arrow.transform.origin = point
		#path_instance_arrow.position.y = 1
		#path_instance_arrow.rotation_degrees.y = rad_to_deg(point_angle)
		#$PreviewPath.add_child(path_instance_arrow, true)
		## --- Draw arrow end here ---
		## --- Draw lines start here ---
		#path_instance_lines.transform.origin = (point + next_point) / 2  # Put this line in the middle
		#path_instance_lines.scale.z = (point_range * 4) # Scale from distance and manually add shit
		#path_instance_lines.position.y = 1
		#path_instance_lines.rotation_degrees.y = rad_to_deg(point_angle)
		#$PreviewPath.add_child(path_instance_lines, true)
		## --- Draw lines end here ---

func spawn_enemies():
	if $Timer.time_left <= 0 and Global.enemy_spawned != Global.total_enemies and Global.preparation_phase == false:
		Global.enemy_spawned = Global.enemy_spawned + 1
		var enemy = enemies.instantiate()
		get_node("/root/Node3D/Enemies").add_child(enemy,true)
		enemy.transform = $SpawnLocation.global_transform
		$Timer.start(randf_range(1.5,3.0))
		print("Enemies Spawned = ", Global.enemy_spawned)
		
func enemy_spawn():
	$Audio/SpawnSfx.play()
	
func enemy_died():
	$Audio/DeathSfx.play()

func count_enemies():
	#W 0:00:03:0280   Narrowing conversion (float is converted to int and loses precision).
	Global.total_enemies = Global.base_enemiesCount * Global.waves
	Global.enemy_left = Global.total_enemies
	Global.enemy_spawned = 0
