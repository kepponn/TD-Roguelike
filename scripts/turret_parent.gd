# --------------------------------------------------------------------------
# This script are available to be extended with 'extends Turret_Parent'
# Currently this script being used by: "turret_basic.gd"
# --------------------------------------------------------------------------

extends StaticBody3D
class_name Turret_Parent

# --------------------------------------------------------------------------
# DONT FORGET TO SET THE TURRET PROPERTY IN THE INHERITED CHILD SCENE
# Call ready_up() function in _ready() in inherited scene and start_process() in _process()
# Setup the model manually in inherited scene make sure it fit $BlockGridCollision
# Setup the $Head/ProjectileSpawn into the barrel of the models (currently only one if in the future the need have 2, need to develop new state check)
# Setup the $Range/CollisionShape3D and $Range/VisibleRange of the child
# --------------------------------------------------------------------------

# ------------------ SEEDER START HERE
@export_category("Basic Information")
@export var id: String 
var price: int
@export_category("Model and Scene Assets")
@export var projectile_scene: PackedScene
@export_category("Attack Information")
var attack_damage: int
var attack_range: int
var attack_speed: float
var bullet_maxammo: int
var bullet_speed: int
# Unique status depend on item
var bullet_pierce: int
var bullet_ricochet: int
# ------------------ SEEDER END HERE

# Other information
@onready var visible_range: MeshInstance3D = $Range/VisibleRange
@onready var range_radius: CollisionShape3D = $Range/CollisionShape3D
@onready var muzzle_flash = $Models/Head/MuzzleFlash

var enemies_array: Array = []

# Buff/debuff that will affect turret status
var buff_isMounted: bool = false # affect attack range
var mounted_bonus = 0
var buff_isEnchanted: bool = false # affect attack damage
var enchanted_bonus = 0

# FINAL STATUS VARIABLE
var final_attack_damage
var final_attack_range
var final_attack_speed

# Target priority goes here
var target # Being use for turret head visual look_at and projectile direction
var target_temp # Being use to check for target availability (last_in and random)
var target_priority_enum = ["first_in", "last_in", "highest_hp", "lowest_hp", "random", "type"] # "type"
var target_priority: String = target_priority_enum[0]
var target_priority_index: int = 0 # Setter for target_priority cycle
var target_priority_type: String = "scout" # Needed for type to run but still no setter for this
var able_shoot: bool = false
var shoot_direction: Vector3
var bullet_ammo: int
var requesting_droneReload: bool = false
@onready var empty_ammoIcon = $EmptyAmmoIcon
@onready var drone_reloadIcon = $DroneReloadIcon
# This should be an optional way of reloading...
@onready var drone_station = null #get_node('/root/Scene/NavigationRegion3D/Item/Drone')

# To upgrade or downgrade the turrets we have the function ready:
# update_damage(int), update_speed(float), update_range(int)
# This still have 0 limiter whatsoever, and so you could monke upgrade it to crazy lvl
# Need to make a variable to check the max upgrade of said item

func seed_property():
	var file = FileAccess.open("res://autoload/item_db.json", FileAccess.READ)
	var file_text = file.get_as_text()
	file.close()
	# Parse JSON data to be easily modified by for loops
	var data = JSON.parse_string(file_text)
	# Check if the id exist in JSON data
	if data.has(id):
		var item_data = data[id]
		for property in item_data:
			self.set(property, item_data[property])

func ready_up():
	seed_property()
	bullet_ammo = bullet_maxammo
	# Call this function once in _ready() func of the child scene
	# Set range and attack speed according to inspector values
	# print($Range/CollisionShape3D.get_shape())
	if $Range/CollisionShape3D.get_shape().is_class("CylinderShape3D"):
		range_radius.shape.radius = attack_range
		visible_range.mesh.top_radius = attack_range
	elif $Range/CollisionShape3D.get_shape().is_class("BoxShape3D"):
		range_radius.shape.size.z = attack_range
		range_radius.position.z = -(attack_range * 0.5)
		visible_range.mesh.size.z = attack_range
		visible_range.position.z = -(attack_range * 0.5)
		# Zero idea on how to make a new mesh also for some reason this mesh porperty being applied to others...
		# visible_range.mesh.top_radius = attack_range
	visible_range.hide()
	final_attack_damage = attack_damage
	$AttackSpeed.wait_time = attack_speed
	$RayCast3D.target_position.z = -attack_range
	$RayCast3DTemp.target_position.z = -attack_range
	$RayCast3D.hide()
	$RayCast3DTemp.hide() # This being utilized in target_priority

func start_process():
	lock_on()
	target_priority_lock_on()
	shoot()
	update_range_visual()
	update_UI()

func update_status(buff: String, enable: bool = false, buff_effect: int = 0):
	var mounted_effect = 0
	var enchanted_effect = 0
	match buff:
		# MOUNTED - ATTACK RANGE
		"mounted":
			match enable:
				true:
					buff_isMounted = true
					mounted_effect = buff_effect
					mounted_bonus = buff_effect
				false: 
					buff_isMounted = false
					mounted_effect = 0
					mounted_bonus = 0
		# ENCHANTED - ATTACK DAMAGE
		"enchanted":
			match enable:
				true:
					buff_isEnchanted = true
					enchanted_effect = buff_effect
					enchanted_bonus = buff_effect
				false: 
					buff_isEnchanted = false
					enchanted_effect = 0
					enchanted_bonus = 0
	
	final_attack_damage = attack_damage + enchanted_effect
	final_attack_range = attack_range + mounted_effect
	final_attack_speed = attack_speed
	
	update_range()

func update_damage(add_or_remove_damage: int):
	# Please use this in incremental of 1 (damage)
	attack_damage += add_or_remove_damage

func update_speed(add_or_remove_speed: float):
	# Please use this in incremental of 0.1
	# This work for keep upgrading it, but didnt work to revert the upgrade..?
	attack_speed = attack_speed / (1 + add_or_remove_speed)
	$AttackSpeed.wait_time = attack_speed

#func update_range(add_or_remove_range: int):
	## Please use this in incremental of 1 (meter)
	## Add range with positive number and remove range with negative number
	#attack_range += add_or_remove_range
	#if $Range/CollisionShape3D.get_shape().is_class("CylinderShape3D"):
		#range_radius.shape.radius = attack_range
		#visible_range.mesh.top_radius = attack_range
	#elif $Range/CollisionShape3D.get_shape().is_class("BoxShape3D"):
		#range_radius.shape.size.z = attack_range
		#range_radius.position.z = -(attack_range * 0.5)
		#visible_range.mesh.size.z = attack_range
		#visible_range.position.z = -(attack_range * 0.5)
	#$RayCast3D.target_position.z = -attack_range
	#$RayCast3DTemp.target_position.z = -attack_range

func update_range():
	if $Range/CollisionShape3D.get_shape().is_class("CylinderShape3D"):
		range_radius.shape.radius = final_attack_range
		visible_range.mesh.top_radius = final_attack_range
	elif $Range/CollisionShape3D.get_shape().is_class("BoxShape3D"):
		range_radius.shape.size.z = final_attack_range
		range_radius.position.z = -(final_attack_range * 0.5)
		visible_range.mesh.size.z = final_attack_range
		visible_range.position.z = -(final_attack_range * 0.5)
	$RayCast3D.target_position.z = -final_attack_range
	$RayCast3DTemp.target_position.z = -final_attack_range

func update_range_visual():
	if $Range/VisibleRange.visible and $Range/VisibleRange.global_position.y != 0.6:
		$Range/VisibleRange.global_position.y = 0.6

func lock_on():
	if !enemies_array.is_empty(): # check array empty state
		# the target will always be the array[0]
		# The target priority filter shouldn't be in here, it should check IF ONLY something insert the area
		# Checking like this means that filter will RUN on every BULLET instance
		# Variable target will determine the look_at model and bullet projectile direction
		$RayCast3D.look_at(enemies_array[0].position) # raycast to the target
		$RayCast3D.force_raycast_update() # faster reporting for raycast
		if $RayCast3D.is_colliding(): # check does the raycast even colide with something?
			# if the collider is not child of 'Enemies' and the array have more than 1 data
			# put the array[0] data into back of the array itself and delete it (same as push_back())
			# this will force the array to re-index itself and now we have different data for array[0]
			if $RayCast3D.get_collider().get_parent().name != 'Enemies' and enemies_array.size() > 1:
				#print("Vision obstructed to " + str(enemies_array[0].name) + " pushing it to back of array")
				able_shoot = false
				#$RayCast3D.debug_shape_custom_color = Color(255,0,0)
				enemies_array.append(enemies_array[0])
				enemies_array.remove_at(0)
				#print("New array for targeting: " + str(enemies_array))
			# check if the raycast collide with 'Enemies', then execute turret movement and shoot, etc
			elif $RayCast3D.get_collider().get_parent().name == 'Enemies':
				able_shoot = true
				#$RayCast3D.show()
				# Head visual aiming to target
				if target != null:
					$Models/Head.look_at(target.position)
				else:
					$Models/Head.look_at(enemies_array[0].position)
				#print("Shooting at " + str(enemies_array[0].name))
				#print("Detecting " + str(enemies_array.size()) + " enemies")
				#$RayCast3D.debug_shape_custom_color = Color(0,255,0)
			# important fail-save for this statement, leave it with atleast something to do
			else:
				able_shoot = false
				$RayCast3D.hide()
	else:
		# Reset turret head direction to default
		$Models/Head.rotation.y = lerp_angle($Models/Head.rotation.y, 0.0, 0.1)
		$Models/Head.rotation.x = lerp_angle($Models/Head.rotation.x, 0.0, 0.1)
		$Models/Head.rotation.z = lerp_angle($Models/Head.rotation.z, 0.0, 0.1)
		$RayCast3D.hide()

func target_priority_lock_on():
	$RayCast3DTemp.force_raycast_update()
	if able_shoot and !enemies_array.is_empty():
		match target_priority:
			"last_in":
				$RayCast3DTemp.look_at(enemies_array[-1].position)
			"random":
				if target_temp != null:
					$RayCast3DTemp.look_at(target_temp.position)
			"type":
				match target_priority_type:
					"scout":
						if target_temp != null:
							$RayCast3DTemp.look_at(target_temp.position)
					"scout_little":
						if target_temp != null:
							$RayCast3DTemp.look_at(target_temp.position)

func target_priority_raycast_check(raycast_target):
	# Trying to see intended target priority to shoot
	if $RayCast3DTemp.get_collider() != null and $RayCast3DTemp.get_collider().get_parent().name == 'Enemies':
		target = raycast_target
	else: # Failed to see random enemy
		target = enemies_array[0]

func check_target_priority():
	print(self, " is targeting to : ", target_priority)
	get_node("/root/Scene/UI/Control/TurretTargetChangeAlert").text = str(self.name) + " (" + str(self.id) + ") is targeting to " + str(target_priority)

func update_target_priority():
	target_priority_index = (target_priority_index + 1) % target_priority_enum.size()
	target_priority = target_priority_enum[target_priority_index]
	print(self, " now targeting to : ", target_priority)
	get_node("/root/Scene/UI/Control/TurretTargetChangeAlert").text = str(self.name) + " (" + str(self.id) + ") now targeting to " + str(target_priority)

func target_priority_type_search(array, enemy_type):
	# This function check for the id of the enemies and return their number in the array structure
	for i in range(array.size()):
		if array[i].id == enemy_type:
			return i
	return 0 # return -1

func target_priority_check():
	match target_priority:
		# CRITICAL unexpected result because the raycasting is always to [0], for example:
		# "last_in": after see the [0] enemy, aim and shoot [-1] while still behind the wall...
		# "random": after suffle the [0] is behind walls, and yet it still shoot...
		# Therefore we're using 2nd raycast to check this, and being processed by target_priority_lock_on()
		"first_in": # First target in-area
			target = enemies_array[0]
		"last_in": # Last target in-area
			# Trying to see last array enemy
			if $RayCast3DTemp.get_collider() != null and $RayCast3DTemp.get_collider().get_parent().name == 'Enemies':
				target = enemies_array[-1]
			else: # Failed to see last array enemy
				target = enemies_array[0]
		"highest_hp": # Strongest?
			# Check for the highest max_HP in enemy, otherwise run similar to first_in if all the max_HP the same
			enemies_array.sort_custom(func(a, b): return a.max_HP > b.max_HP) # Lambda sort ver.
			target = enemies_array[0]
		"lowest_hp": # Weakest?
			# Check for the lowest max_HP in enemy, otherwise run similar to first_in if all the max_HP the same
			enemies_array.sort_custom(func(a, b): return a.max_HP < b.max_HP) # Lambda sort ver.
			target = enemies_array[0]
		"random": # Random go whatever
			# This being called in every shot
			target_temp = enemies_array.pick_random()
			target_priority_raycast_check(target_temp)
			# enemies_array[randi() % enemies_array.size()] or enemies_array.pick_random()
			# Will create a bug where the turret look at and where the bullet goes is different
			# Because this random didn't changes the array structure, therefore turret still look at [0]
		"type": # Base on enemy type, work-in-progress
			match target_priority_type:
				"scout":
					target_temp = enemies_array[target_priority_type_search(enemies_array, "scout")]
					target_priority_raycast_check(target_temp)
				"scout_little":
					target_temp = enemies_array[target_priority_type_search(enemies_array, "scout_little")]
					target_priority_raycast_check(target_temp)
						
	return (target.global_position - global_position).normalized()

func shoot():
	if drone_station != null:
		if bullet_ammo != 0 and drone_station.turret_toReload.has(self):
			drone_station.turret_toReload.erase(self)
			empty_ammoIcon.hide()
		elif bullet_ammo == 0 and !drone_station.turret_toReload.has(self):
			drone_station.turret_toReload.append(self)
			empty_ammoIcon.show()
	
	if !enemies_array.is_empty() and $AttackSpeed.time_left <= 0.0 and able_shoot and bullet_ammo != 0:
		# Remove bullet count
		bullet_ammo -= 1
		shoot_direction = target_priority_check()
		var turret_projectile = projectile_scene.instantiate()
		# Unique bullet type goes here
		if bullet_pierce > 0:
			turret_projectile.pierce_counter = bullet_pierce
		if bullet_ricochet > 0:
			turret_projectile.ricochet_counter = bullet_ricochet
			turret_projectile.ricochet_targetList.append_array(enemies_array)
		# Other fixed params for bullets
		turret_projectile.damage = final_attack_damage
		turret_projectile.speed = bullet_speed
		turret_projectile.transform = %ProjectileSpawn.global_transform #basically copy all of $"Head/Spawn Point" global transform(rotation, scale, position), to projectile
		turret_projectile.set_direction = shoot_direction #direction used to set projectile movement direction
		# Create the instance of the bullet
		get_node("/root/Scene/Temporary/Projectiles").add_child(turret_projectile, true) # if you want to shoot while still holding it maybe make projectile as unique or use absolute path to it
		# emit muzzle flash particles
		muzzle_flash.spawn_muzzle_flash()
		shoot_audio()
		$AttackSpeed.start() #restart timer so it can shoot again

func drone_reload():
	bullet_ammo = bullet_maxammo

func reload():
	if requesting_droneReload == false:
		bullet_ammo = bullet_maxammo

func default_state():
	bullet_ammo = bullet_maxammo
	empty_ammoIcon.hide()
	drone_reloadIcon.hide()
	target = null
	able_shoot = false

func update_UI():
	if bullet_ammo != bullet_maxammo:
		$AmmoBar3D.show()
	else:
		$AmmoBar3D.hide()
	$AmmoBar3D/SubViewport/AmmoBar2D.max_value = bullet_maxammo
	$AmmoBar3D/SubViewport/AmmoBar2D.value = bullet_ammo

func shoot_audio():
	var ShootSfx = $BulletSfx.get_children()
	var ShootSfxPicker = ShootSfx[randi() % ShootSfx.size()]
	ShootSfxPicker.pitch_scale = randf_range(0.8, 1.2)
	ShootSfxPicker.play()

func _on_range_body_entered(body):
	if body.get_parent().name == 'Enemies':
		#print("Append " + str(body))
		enemies_array.append(body)
		#print("Current array " + str(enemies_array))

func _on_range_body_exited(body):
	if body.get_parent().name == 'Enemies':
		#print("Erase " + str(body))
		enemies_array.erase(body)
		#print("Current array " + str(enemies_array))
