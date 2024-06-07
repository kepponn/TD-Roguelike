extends StaticBody3D

var id = "drone_base"

@onready var drone = $Models/Drone
@onready var drone_ammo = $Models/Drone/ammo_box
@onready var drone_light =  $Models/Drone/OmniLight3D
var base_ammo = 0 #This is the max standby and (+1 from drone carrying)
var turret_inRange: Array 
var turret_toReload: Array
var reload_target
var drone_isMoving = false
var drone_Tween
var drone_tween1IsFinished: bool = false
var drone_tween2IsFinished: bool = false
var drone_tween3IsFinished: bool = false

# Models (I dont think the drone need collision shape whatsoever?)
var drone_isCarryingAmmo: bool = false

func _ready():
	drone_ammo.hide() # Hide ammo box models on drone
	$Models/ammo_box1.hide()
	$Models/ammo_box2.hide()
	$Models/ammo_box3.hide()

func _process(delta):
	drone_model_and_ammo_calc()
	#if there is turret in range
	if !turret_inRange.is_empty():
		for item in turret_inRange.size():
			if turret_inRange[item].bullet_ammo == 0:
				#print(turret_inRange[item].id, " is out of ammo")
				turret_toReload.append(turret_inRange[item])
				turret_inRange.erase(turret_inRange[item])
				break
				
	if !turret_toReload.is_empty():
		reload_target = turret_toReload[0]
		for item in turret_toReload.size():
			if turret_toReload[item].bullet_ammo != 0:
				# THIS BEING CALLED EVERYTIME??!!
				print(turret_toReload[item].id, " has been reloaded by player")
				turret_inRange.append(turret_toReload[item])
				turret_toReload.erase(turret_toReload[item])
				# This still being called even in "normal" circumstance of drone-reloading?
				#back_toBase()
				break
				
	drone_moveToTarget()
	
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

func _on_area_3d_body_entered(body):
	if body.get_parent().name == "Item" and body.name != "DroneBase" and Function.search_regex("turret", body.id):
		turret_inRange.append(body)
		
func drone_reload():
	print("Drone reloaded ",reload_target.id)
	drone_isCarryingAmmo = false
	turret_toReload.erase(reload_target)
	turret_inRange.append(reload_target)
	#print("Turret left to be reloaded ", turret_toReload)
	reload_target.bullet_ammo = reload_target.bullet_maxammo
	reload_target = null
	
func drone_moveToTarget():
	# ONLY CHECK FOR drone_isCarryingAmmo CALCULATION IS ALREADY BEING HANDLED
	if drone_isCarryingAmmo and !drone_isMoving and !turret_toReload.is_empty():
		#base_ammo -= 1 # Being handled by drone_isCarryingAmmo variable
		#print("Drone Delivering Ammo, base ammo left: ", base_ammo)
		drone_isMoving = true
		drone_Tween = get_tree().create_tween()
		drone_Tween.tween_property(drone,"global_position", Vector3(drone.global_position.x, 5, drone.global_position.z),1)
		drone_Tween.tween_property(self, "drone_tween1IsFinished", true, 0)
		drone_Tween.tween_property(drone,"global_position", Vector3(reload_target.global_position.x, 5, reload_target.global_position.z), drone.global_position.distance_to(reload_target.global_position)/5)
		drone_Tween.tween_property(self, "drone_tween2IsFinished", true, 0)
		drone_Tween.tween_property(drone,"global_position", Vector3(reload_target.global_position.x, drone.global_position.y, reload_target.global_position.z),1)
		drone_Tween.tween_property(self, "drone_tween3IsFinished", true, 0)
		drone_Tween.connect("finished", on_tween_to_target_finished)
		
		
func back_toBase():
	drone_Tween.kill()
	drone_Tween = get_tree().create_tween()
	
	if !drone_tween1IsFinished:
		drone_Tween.tween_property(drone,"global_position", Vector3(drone.global_position.x,2, drone.global_position.z),1)
	elif !drone_tween2IsFinished:
		drone_Tween.tween_property(drone,"global_position", Vector3(global_position.x, 5, global_position.z), drone.global_position.distance_to(global_position)/5)
		drone_Tween.tween_property(drone,"global_position", Vector3(global_position.x, 2 ,global_position.z),1)
	elif !drone_tween3IsFinished:
		drone_Tween.tween_property(drone,"global_position", Vector3(drone.global_position.x,5, drone.global_position.z),1)
		drone_Tween.tween_property(drone,"global_position", Vector3(global_position.x, 5, global_position.z), drone.global_position.distance_to(global_position)/5)
		drone_Tween.tween_property(drone,"global_position", Vector3(global_position.x, 2 ,global_position.z),1)
	drone_tween1IsFinished = false
	drone_tween2IsFinished = false
	drone_tween3IsFinished = false
	#drone_Tween.tween_property(self, "base_ammo", base_ammo+1, 0)
	drone_Tween.connect("finished", on_tween_to_base_finished)
		
func on_tween_to_target_finished():
	drone_reload()
	drone_moveToBase()
	
func drone_moveToBase():
	drone_Tween = get_tree().create_tween()
	drone_Tween.tween_property(drone,"global_position", Vector3(drone.global_position.x,5, drone.global_position.z),1)
	drone_Tween.tween_property(drone,"global_position", Vector3(global_position.x, 5, global_position.z), drone.global_position.distance_to(global_position)/5)
	drone_Tween.tween_property(drone,"global_position", Vector3(global_position.x, 2 ,global_position.z),1)
	drone_Tween.connect("finished", on_tween_to_base_finished)
	
func on_tween_to_base_finished():
	drone_isMoving = false
	
func add_ammoToBase():
	base_ammo += 1
	#play sfx maybe
