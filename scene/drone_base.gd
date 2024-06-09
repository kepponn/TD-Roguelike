extends StaticBody3D

var id = "drone_base"

@onready var player = get_node('/root/Node3D/Player')
@onready var drone = $Models/Drone
@onready var drone_ammo = $Models/Drone/ammo_box
@onready var drone_light =  $Models/Drone/OmniLight3D
var base_ammo = 3 #This is the max standby and (+1 from drone carrying)
var SPEED = 5.0

var drone_isMoving = false
var drone_Tween
var drone_tween1IsFinished: bool = false
var drone_tween2IsFinished: bool = false
var drone_tween3IsFinished: bool = false
var turret_toReload: Array = []

# Models (I dont think the drone need collision shape whatsoever?)
var drone_isCarryingAmmo: bool = false

func _ready():
	drone_ammo.hide() # Hide ammo box models on drone
	$Models/ammo_box1.hide()
	$Models/ammo_box2.hide()
	$Models/ammo_box3.hide()

func _process(_delta):
	if !turret_toReload.is_empty() and !drone_isMoving and drone_isCarryingAmmo:
		drone_tweenToTarget()
	drone_model_and_ammo_calc()

func reset():
	if drone_Tween:
		drone_Tween.kill()
	drone_isMoving = false
	drone.position = Vector3(0, 1, 0) # Snap the the default position
	# Array already being cleared by the turret

func drone_tweenToTarget():
	drone_isMoving = true
	turret_toReload[0].requesting_droneReload = true
	drone_Tween = get_tree().create_tween()
	drone_Tween.tween_property(drone, "global_position:y", 2, float(5/SPEED)).as_relative()
	drone_Tween.tween_property(drone, "global_position", Vector3(turret_toReload[0].global_position.x - drone.global_position.x, 0, turret_toReload[0].global_position.z - drone.global_position.z), drone.global_position.distance_to(turret_toReload[0].global_position)/SPEED).as_relative()
	drone_Tween.tween_property(drone, "global_position:y", -(4 - turret_toReload[0].global_position.y - 1), float(5/SPEED)).as_relative()
	drone_Tween.connect("finished", on_tween_to_target_finished)
	
func on_tween_to_target_finished():
	drone_isCarryingAmmo = false
	turret_toReload[0].drone_reload()
	turret_toReload[0].requesting_droneReload = false
	#turret_toReload.pop_front()
	drone_tweenToBase()
	
func drone_tweenToBase():
	drone_Tween = get_tree().create_tween()
	drone_Tween.tween_property(drone, "global_position:y", 4 - turret_toReload[0].global_position.y - 1, float(5/SPEED)).as_relative()
	drone_Tween.tween_property(drone, "global_position", Vector3(global_position.x - drone.global_position.x, 0, global_position.z - drone.global_position.z), drone.global_position.distance_to(global_position)/SPEED).as_relative()
	drone_Tween.tween_property(drone, "global_position:y", -2, float(5/SPEED)).as_relative()
	drone_Tween.connect("finished", on_tween_to_base_finished)
	
func on_tween_to_base_finished():
	drone_isMoving = false

func drone_model_and_ammo_calc():
	# This function should not be in process, should only be called when the ammo quantity is changed
	# Calc ammo and transfer it to drone if available (max 3 on stock and 1 on drone)
	if base_ammo > 0 and !drone_isCarryingAmmo and !drone_isMoving:
		base_ammo -= 1
		drone_isCarryingAmmo = true
	# Visual for crate on drone if drone is carrying ammo
	match drone_isCarryingAmmo:
		true:
			drone_ammo.show()
			drone_light.light_color = Color("00e52a")
		false:
			drone_ammo.hide()
			drone_light.light_color = Color("da452e")
	# Visual for base for how many ammo box is left
	match base_ammo:
		0:
			$Models/ammo_box1.hide()
			$Models/ammo_box2.hide()
			$Models/ammo_box3.hide()
		1:
			$Models/ammo_box1.show()
			$Models/ammo_box2.hide()
			$Models/ammo_box3.hide()
		2:
			$Models/ammo_box1.show()
			$Models/ammo_box2.show()
			$Models/ammo_box3.hide()
		3:
			$Models/ammo_box1.show()
			$Models/ammo_box2.show()
			$Models/ammo_box3.show()

func add_ammoToBase():
	if base_ammo >= 3:
		player.player_holdedMats = "ammo_box"
		player.player_isHoldingItem = true
		print("Cannot drop ", player.player_holdedMats, ", ammo quantity is full")
	else:
		base_ammo += 1
		print("Drop ", player.player_holdedMats, " to drone station")
		player.player_holdedMats = ""
		player.player_isHoldingItem = false
	#play sfx maybe
