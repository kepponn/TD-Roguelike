extends Marker3D

var enemies_spawn_rate

var enemies_seeder_array_weight: Array = []
var enemies_scene_node
var enemy_scout: PackedScene = preload("res://scene/enemy_scout.tscn")
var enemy_scout_little: PackedScene = preload("res://scene/enemy_scout_little.tscn")
var enemy_flying_test: PackedScene = preload("res://scene/enemy_flying.tscn")

var direction
var velocity
@onready var nav: NavigationAgent3D = $SpawnLocation/NavigationAgent3D
@onready var spawn_timer: Timer = $Timer

var path_runner_green = preload("res://scene/path_runner_green.tscn")
var path_runner_red = preload("res://scene/path_runner_red.tscn")
var path_runner_yellow = preload("res://scene/path_runner_yellow.tscn")

var count_enemy_scout: int = 0
var count_enemy_scout_little: int = 0


# The flow of the spawner:
# ------------ CALLED IN PREP STAGE OF THE WAVE
# seed_enemies_weight() - this will seed the enemies based on their weight and show in the incoming wave panel
# count_enemies() - this to get the data on how many enemies will be spawn on this wave and setter for next wave
# ------------ CALLED IN THE DEFEND STAGE OF THE WAVE
# spawn_enemies() - this will take seed_enemies() result and get the data and spawn it 1 by 1 in back-to-front

func _ready():
	pass

func _process(delta):
	$SpawnLocation/Models/Orb.rotation_degrees.y += 10 * delta
	spawn_enemies()
	check_path()

func count_enemies(): # This should be calculate in prep phase
	#Global.total_enemies = Global.base_enemiesCount * Global.waves
	Global.enemy_left = Global.total_enemies
	Global.enemy_spawned = 0
	Global.wave_weight_limit += 2 # this being used for weight calc by seed_enemies_weight()

func randomize_enemiesType():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var weight_sum = 0
	var first_num = 0
	var second_num = 0
	
	#sum all of the weight
	for n in enemies_spawn_rate:
		weight_sum = weight_sum + enemies_spawn_rate[n]
		
	#choose a random number between 0 to total weight
	var random_number = rng.randi_range(1,weight_sum)
	#print("your random generated number is : ", random_number)
	
	for n in enemies_spawn_rate:
		first_num = second_num
		second_num = second_num  + enemies_spawn_rate[n]
		if random_number > first_num and random_number <= second_num:
			#print("your number are between: ", first_num, " and ", second_num)
			#print("therefore spawned item will be: ", n)
			return n

func seed_enemies_weight():
	var enemies_weight = {
		"enemy_scout": 2,
		"enemy_scout_little": 1,
		"enemy_flying_test": 1
	}
	
	#var count_enemy_scout: int = 0
	#var count_enemy_scout_little: int = 0
	count_enemy_scout = 0
	count_enemy_scout_little = 0
	var wave_weight_current: int = 0
	var total_enemies: int = 0
	
	# This will run loop until wave_weight_current
	while wave_weight_current < Global.wave_weight_limit:
		#print(wave_weight_current)
		# Check to json if anything can be added that still satisfy the limit
		if wave_weight_current + enemies_weight.values().min() > Global.wave_weight_limit:
			break
			
		var enemy_spawned = randomize_enemiesType()
		# Check if the enemy weight still fit in Global.weight or not, you better have it less than weight than over by 1..
		if wave_weight_current + enemies_weight[enemy_spawned] <= Global.wave_weight_limit:
			enemies_seeder_array_weight.append(enemy_spawned)
			wave_weight_current += enemies_weight[enemy_spawned]
			total_enemies += 1
		#--------------------------------------------------------------------------------------------------------------------------------------------
		# 1. 
		#idk why but 
			#count_enemy_scout = 0
			#count_enemy_scout_little = 0
		#these 2 need to be declared for whole spawner at line 19 and 20, otherwise set("count_"+enemy_spawned, +1) doesn't work
		
		#this set still broken because it won't add 1 value to selected property, but it set the property to +1 (positive 1)
		#set("count_" + enemy_spawned, +1)
		#--------------------------------------------------------------------------------------------------------------------------------------------
		# 2.
		#this is brute force one but work fine, but will be annoying if there will be many type of enemies
		#if enemy_spawned == "enemy_scout":
			#count_enemy_scout += 1
		#elif enemy_spawned == "enemy_scout_little":
			#count_enemy_scout_little += 1
		#--------------------------------------------------------------------------------------------------------------------------------------------
		# 3.
		#another alternative: using count(), but have same problem as the NO.2 because we need to add new lines for every enemy types in the future
		#if we are going to use this, then move this to line 130 before "Global.total_enemies = total_enemies"
		#OR put this inside line 134 and we can get rid of count_enemy_scout and count_enemy_scout_little variable and any possible new enemy count variable in the future
		count_enemy_scout = enemies_seeder_array_weight.count("enemy_scout")
		count_enemy_scout_little = enemies_seeder_array_weight.count("enemy_scout_little")
		#--------------------------------------------------------------------------------------------------------------------------------------------
		
		#if randi_range(0, 1) == 0:
			#if wave_weight_current + enemies_weight["enemy_scout"] <= Global.wave_weight_limit:
				#enemies_seeder_array_weight.append("enemy_scout")
				#count_enemy_scout += 1
				#total_enemies += 1
				#wave_weight_current += enemies_weight["enemy_scout"]
				##print("Add 2 weight inserting scout")
		#else:
			#if wave_weight_current + enemies_weight["enemy_scout_little"] <= Global.wave_weight_limit:
				#enemies_seeder_array_weight.append("enemy_scout_little")
				#count_enemy_scout_little += 1
				#total_enemies += 1
				#wave_weight_current += enemies_weight["enemy_scout_little"]
				##print("Add 1 weight inserting scout little")
	Global.total_enemies = total_enemies
	print("Weight used ", wave_weight_current, " on global weight ", Global.wave_weight_limit)
	print("Seed enemies with weight done ", enemies_seeder_array_weight)
	get_node("/root/Scene/UI/Control/IncomingWavePanelAlert").text = "Incoming Wave Panel\n - " + str(count_enemy_scout) + "x Scout \n - " + str(count_enemy_scout_little) + "x Scout Little"

func spawn_enemies():
	if $Timer.time_left <= 0 and Global.enemy_spawned != Global.total_enemies and Global.preparation_phase == false:
		Global.enemy_spawned = Global.enemy_spawned + 1
		var enemy 
		# This randomize will give an example of how enemy will behave in queue
		# Please do check if this will make the enemy somehow DEADLOCK/STUCK together
		match enemies_seeder_array_weight.pop_back(): # Remove and get last array data simultaneously
			"enemy_scout":
				enemy = enemy_scout.instantiate()
			"enemy_scout_little":
				enemy = enemy_scout_little.instantiate()
			"enemy_flying_test":
				enemy = enemy_flying_test.instantiate()
		# Get spawner seed to spawn what needed to be spawned
		enemy.transform = $SpawnLocation.global_transform
		enemies_scene_node.add_child(enemy,true)
		#$Timer.start(randf_range(1.5,3.0))
		$Timer.start(1)
		print("Enemies Spawned = ", Global.enemy_spawned, ". Seeder left: ", enemies_seeder_array_weight)

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
	$PreviewPath/PreviewTimer.start(3)

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

#var path_points = []
#var path_points_red = preload("res://scene/path_direction_red.tscn")
#var path_lines_red = preload("res://scene/path_lines_red.tscn")
#var path_points_green = preload("res://scene/path_direction_green.tscn")
#var path_lines_green = preload("res://scene/path_lines_green.tscn")
#var green_opacity = load("res://assets/shaders/green_opacity.tres")
#var red_opacity = load("res://assets/shaders/red_opacity.tres")

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
