extends StaticBody3D

var projectile: PackedScene = preload("res://turret_projectile.tscn")

var enemies_inRange = []
var enemy_locked
var able_toShoot: bool = false

@export var attack_range:float

@onready var range_radius: CollisionShape3D = $Range/CollisionShape3D
@onready var raycast: RayCast3D = $RayCast3D

# Called when the node enters the scene tree for the first time.
func _ready():
	
	range_radius.shape.radius = attack_range
	raycast.target_position.z = -attack_range
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	print(enemies_inRange)
	lockon()
	shoot()

func shoot():
	#i dont know why if $"Attack Speed".time_left <= 0.3 set to <= 0.0 all code below didn't work except for $"Attack Speed".start(1)
	if enemy_locked != null and $"Attack Speed".time_left <= 0.0 and able_toShoot == true:
		
		var direction: Vector3 = (enemy_locked.position - position).normalized()
		var turret_projectile = projectile.instantiate()
		$"../../../Projectile".add_child(turret_projectile,true)
		
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
				$RayCast3D.debug_shape_custom_color = Color(174,0,0)
	else:
		able_toShoot = false
		$RayCast3D.debug_shape_custom_color = Color(174,0,0)

func _on_range_body_entered(body):
	if body.get_parent().name == 'Enemies':
		enemies_inRange.append(body)

func _on_range_body_exited(body):
	if body.get_parent().name == 'Enemies':
		enemies_inRange.erase(body)
