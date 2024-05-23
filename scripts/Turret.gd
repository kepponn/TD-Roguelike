extends StaticBody3D

var projectile: PackedScene = preload("res://scene/turret_projectile.tscn")

var enemies_inRange = []
var enemy_locked
var able_toShoot: bool = false

@export var attack_range:float

@onready var range_radius: CollisionShape3D = $Range/CollisionShape3D
@onready var raycast: RayCast3D = $RayCast3D

func _ready():
	range_radius.shape.radius = attack_range
	raycast.target_position.z = -attack_range
	$RayCast3D.hide()

func _process(_delta):
	lock_on_is_easy()
	#lockon()
	shoot()

# BOTH FUNCTION WORKING FINE, USE WHATEVER YOU WANT
# THIS IS THE MAGIC SPELL
# REMEMBER THIS WELL AND RECITE IT AFTER ME
# $RayCast3D.force_raycast_update()

# BUT... it still wont target the enemy which the closest to the target because there is currently no param to check for it

func lock_on_is_easy():
	if !enemies_inRange.is_empty(): # check array empty state
		# the target will always be the array[0]
		$RayCast3D.look_at(enemies_inRange[0].position) # raycast to the target
		$RayCast3D.force_raycast_update() # faster reporting for raycast
		if $RayCast3D.is_colliding(): # check does the raycast even colide with something?
			# if the collider is not child of 'Enemies' and the array have more than 1 data
			# put the array[0] data into back of the array itself and delete it (same as push_back())
			# this will force the array to re-index itself and now we have different data for array[0]
			if $RayCast3D.get_collider().get_parent().name != 'Enemies' and enemies_inRange.size() > 1:
				print("Vision obstructed to " + str(enemies_inRange[0].name) + " pushing it to back of array")
				able_toShoot = false
				$RayCast3D.debug_shape_custom_color = Color(255,0,0)
				enemies_inRange.append(enemies_inRange[0])
				enemies_inRange.remove_at(0)
				print("New array for targeting: " + str(enemies_inRange))
			# check if the raycast collide with 'Enemies', then execute turret movement and shoot, etc
			elif $RayCast3D.get_collider().get_parent().name == 'Enemies':
				able_toShoot = true
				$RayCast3D.show()
				$Head.look_at(enemies_inRange[0].position)
				#print("Shooting at " + str(enemies_inRange[0].name))
				#print("Detecting " + str(enemies_inRange.size()) + " enemies")
				$RayCast3D.debug_shape_custom_color = Color(0,255,0)
			# important fail-save for this statement, leave it with atleast something to do
			else:
				able_toShoot = false
				$RayCast3D.hide()
				#print("No enemies detected")
				$RayCast3D.debug_shape_custom_color = Color(255,0,0)

func shoot():
	var direction: Vector3
	#i dont know why if $"Attack Speed".time_left <= 0.3 set to <= 0.0 all code below didn't work except for $"Attack Speed".start(1)
	if (enemy_locked != null or !enemies_inRange.is_empty()) and $"Attack Speed".time_left <= 0.0 and able_toShoot == true:
		if enemy_locked != null:
			direction = (enemy_locked.position - position).normalized()
		elif !enemies_inRange.is_empty():
			direction = (enemies_inRange[0].position - position).normalized()
		var turret_projectile = projectile.instantiate()
		# if you want to shoot while still holding it maybe make projectile as unique or use absolute path to it
		#$"../../../Projectile".add_child(turret_projectile,true)
		get_node("/root/Node3D/Projectile").add_child(turret_projectile,true)
		#basically copy all of $"Head/Spawn Point" global transform(rotation, scale, position), to projectile
		turret_projectile.transform = $"Head/Spawn Point".global_transform
		
		#direction used to set projectile movement direction
		turret_projectile.set_direction = direction
		
		#restart timer so it can shoot again
		$"Attack Speed".start(1)
	

func lockon():
	#NOTES : Raycast are not infinitly long. it's length need to be change on Raycast3D -> Inspector -> Target Position
	#and it can be changed by code by using $RayCast3D.target_position
	#if there is enemy inside attack RANGE, turret will lock into the first enemy
	
	#need better targeting system, 
	
	if enemies_inRange.size() != 0:
		enemy_locked = enemies_inRange[0]
		#lock raycast look at to the first enemy in the enemies_inRange array
		$RayCast3D.look_at(enemy_locked.position)
		$RayCast3D.force_raycast_update()
		
		#check if raycast colliding with any 3D bodies
		if $RayCast3D.is_colliding() and $RayCast3D.get_collider()!= null:
			#can save any data of the collided body, in this case we only want the parent name
			#var collided = $RayCast3D.get_collider().get_parent().name
			#if collided's parent name is Enemies then it mean raycast able to hit enemies successfully and
			#not blocked by any 3D body, and then make turret's $Body to look at the locked enemy
			if $RayCast3D.get_collider().get_parent().name == 'Enemies':
				able_toShoot = true
				$Head.look_at(enemy_locked.position)
				$RayCast3D.debug_shape_custom_color = Color(0,255,0)
			else:
				able_toShoot = false
				enemies_inRange.append(enemies_inRange[0])
				enemies_inRange.remove_at(0)
				$RayCast3D.debug_shape_custom_color = Color(174,0,0)
	else:
		able_toShoot = false
		$RayCast3D.debug_shape_custom_color = Color(174,0,0)

func _on_range_body_entered(body):
	if body.get_parent().name == 'Enemies':
		print("Append " + str(body))
		enemies_inRange.append(body)
		print("Current array " + str(enemies_inRange))

func _on_range_body_exited(body):
	if body.get_parent().name == 'Enemies':
		print("Erase " + str(body))
		enemies_inRange.erase(body)
		print("Current array " + str(enemies_inRange))
