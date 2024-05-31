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

@export_category("Basic Information")
# Do we need this still for the regex? or we using with StaticObject3D node name?
@export var id: String 
var price: int
@export_category("Model and Scene Assets")
# How to get the asset into the node area of $Head and $Body?
# @export var asset_head: PackedScene
# @export var asset_legs: PackedScene
@export var projectile_scene: PackedScene
# @export_category("Attack Information")
var attack_damage: int
var attack_range: int
var attack_speed: float

var bullet_speed: int
#unique status depend on item
var bullet_pierce: int
var bullet_ricochet: int
# Other information
@onready var visible_range: MeshInstance3D = $Range/VisibleRange
@onready var range_radius: CollisionShape3D = $Range/CollisionShape3D
var enemies_array: Array = []
var able_shoot: bool = false
var shoot_direction: Vector3

# Soon to be problems
# $Head/ProjectileSpawn will need to be manually sets to fit the models
# Therefore this node need to be erased from this code

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
	$AttackSpeed.wait_time = attack_speed
	$RayCast3D.target_position.z = -attack_range
	$RayCast3D.hide()

func update_range(add_or_remove_range: int):
	# Add range with positive number and remove range with negative number
	attack_range += add_or_remove_range
	if $Range/CollisionShape3D.get_shape().is_class("CylinderShape3D"):
		range_radius.shape.radius = attack_range
		visible_range.mesh.top_radius = attack_range
	elif $Range/CollisionShape3D.get_shape().is_class("BoxShape3D"):
		range_radius.shape.size.z = attack_range
		range_radius.position.z = -(attack_range * 0.5)
		visible_range.mesh.size.z = attack_range
		visible_range.position.z = -(attack_range * 0.5)

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
				#print("Vision obstructed to " + str(enemies_array[0].name) + " pushing it to back of array")
				able_shoot = false
				$RayCast3D.debug_shape_custom_color = Color(255,0,0)
				enemies_array.append(enemies_array[0])
				enemies_array.remove_at(0)
				#print("New array for targeting: " + str(enemies_array))
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
		shoot_direction = (enemies_array[0].global_position - global_position).normalized()
		var turret_projectile = projectile_scene.instantiate()
		get_node("/root/Node3D/Projectile").add_child(turret_projectile, true) # if you want to shoot while still holding it maybe make projectile as unique or use absolute path to it
		shoot_audio()
		if bullet_pierce > 0:
			turret_projectile.pierce_counter = bullet_pierce
		if bullet_ricochet > 0:
			turret_projectile.ricochet_counter = bullet_ricochet
		turret_projectile.damage = attack_damage
		turret_projectile.speed = bullet_speed
		turret_projectile.transform = $Head/ProjectileSpawn.global_transform #basically copy all of $"Head/Spawn Point" global transform(rotation, scale, position), to projectile
		turret_projectile.set_direction = shoot_direction #direction used to set projectile movement direction
		$AttackSpeed.start() #restart timer so it can shoot again

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
