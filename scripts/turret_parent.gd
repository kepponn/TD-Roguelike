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
# --------------------------------------------------------------------------

@export_category("Basic Information")
# Do we need this still for the regex? or we using with StaticObject3D node name?
@export var turret_name: String 
@export_category("Model and Scene Assets")
# How to get the asset into the node area of $Head and $Body?
# @export var asset_head: PackedScene
# @export var asset_legs: PackedScene
@export var projectile_scene: PackedScene
@export_category("Attack Information")
@export var attack_damage: int
@export var attack_range: int
@export var attack_speed: float
# Other information
@onready var visible_range: MeshInstance3D = $Range/VisibleRange
@onready var range_radius: CollisionShape3D = $Range/CollisionShape3D
var enemies_array: Array = []
var able_shoot: bool = false
var shoot_direction: Vector3

# Soon to be problems
# $Head/ProjectileSpawn will need to be manually sets to fit the models
# Therefore this node need to be erased from this code

func ready_up():
	# Call this function once in _ready() func of the child scene
	# Set range and attack speed according to inspector values
	range_radius.shape.radius = attack_range
	visible_range.mesh.top_radius = attack_range
	$RayCast3D.target_position.z = -attack_range
	$AttackSpeed.wait_time = attack_speed
	$RayCast3D.hide()

func start_process():
	lock_on()
	shoot()

func lock_on():
	if !enemies_array.is_empty(): # check array empty state
		# the target will always be the array[0]
		$RayCast3D.look_at(enemies_array[0].position) # raycast to the target
		$RayCast3D.force_raycast_update() # faster reporting for raycast
		if $RayCast3D.is_colliding(): # check does the raycast even colide with something?
			# if the collider is not child of 'Enemies' and the array have more than 1 data
			# put the array[0] data into back of the array itself and delete it (same as push_back())
			# this will force the array to re-index itself and now we have different data for array[0]
			if $RayCast3D.get_collider().get_parent().name != 'Enemies' and enemies_array.size() > 1:
				print("Vision obstructed to " + str(enemies_array[0].name) + " pushing it to back of array")
				able_shoot = false
				$RayCast3D.debug_shape_custom_color = Color(255,0,0)
				enemies_array.append(enemies_array[0])
				enemies_array.remove_at(0)
				print("New array for targeting: " + str(enemies_array))
			# check if the raycast collide with 'Enemies', then execute turret movement and shoot, etc
			elif $RayCast3D.get_collider().get_parent().name == 'Enemies':
				able_shoot = true
				$RayCast3D.show()
				$Head.look_at(enemies_array[0].position)
				#print("Shooting at " + str(enemies_array[0].name))
				#print("Detecting " + str(enemies_array.size()) + " enemies")
				$RayCast3D.debug_shape_custom_color = Color(0,255,0)
			# important fail-save for this statement, leave it with atleast something to do
			else:
				able_shoot = false
				$RayCast3D.hide()
	else:
		$RayCast3D.hide()

func shoot():
	if !enemies_array.is_empty() and $AttackSpeed.time_left <= 0.0 and able_shoot:
		shoot_direction = (enemies_array[0].position - position).normalized()
		var turret_projectile = projectile_scene.instantiate()
		get_node("/root/Node3D/Projectile").add_child(turret_projectile, true) # if you want to shoot while still holding it maybe make projectile as unique or use absolute path to it
		turret_projectile.transform = $Head/ProjectileSpawn.global_transform #basically copy all of $"Head/Spawn Point" global transform(rotation, scale, position), to projectile
		turret_projectile.set_direction = shoot_direction #direction used to set projectile movement direction
		$AttackSpeed.start() #restart timer so it can shoot again

func _on_range_body_entered(body):
	if body.get_parent().name == 'Enemies':
		print("Append " + str(body))
		enemies_array.append(body)
		print("Current array " + str(enemies_array))

func _on_range_body_exited(body):
	if body.get_parent().name == 'Enemies':
		print("Erase " + str(body))
		enemies_array.erase(body)
		print("Current array " + str(enemies_array))
