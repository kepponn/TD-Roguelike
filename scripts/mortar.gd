extends StaticBody3D

@export_category("Basic Information")
@export var id: String = "mortar"
var price: int

@export_category("Model and Scene Assets")
@export var projectile_scene: PackedScene

@export_category("Attack Information")
var attack_damage: int = 10
var attack_speed: float = 0.5
var attack_rangeMin: float = 5
var attack_rangeMax: float = 8
var bullet_speed: int = 6

@onready var visible_range: MeshInstance3D = $TargetPivot/Target/VisibleRange
@onready var target = $TargetPivot/Target
var is_controlled: bool = false
var able_shoot: bool = true

func _ready():
	$Models/Head/Barrel.rotation_degrees.x = 4
	$ReloadTimerBar3D.hide()
	visible_range.hide()
	visible_range.position.y = 1.2

func _process(delta):
	update_UI()
	update_range_visual()
	#print(target.global_position)
		
	if is_controlled:
		if Input.is_action_just_pressed("ui_up") and $TargetPivot/Target.position.z >= attack_rangeMin and $TargetPivot/Target.position.z < attack_rangeMax:
			$TargetPivot/Target.position.z += 1
			$Models/Head/Barrel.rotation_degrees.x += 2
		elif Input.is_action_just_pressed("ui_down") and $TargetPivot/Target.position.z > attack_rangeMin and $TargetPivot/Target.position.z <= attack_rangeMax:
			$TargetPivot/Target.position.z -= 1
			$Models/Head/Barrel.rotation_degrees.x -= 2
		elif Input.is_action_pressed("ui_left"):
			$TargetPivot.rotation_degrees.y += 100 * delta
			$Models/Head.rotation_degrees.y += 100 * delta
		elif Input.is_action_pressed("ui_right"):
			$TargetPivot.rotation_degrees.y -= 100 * delta
			$Models/Head.rotation_degrees.y -= 100 * delta
		# Press the same button again to quit the controlled state
		elif Input.is_action_just_pressed("rotate") and $InteractTimer.time_left == 0:
			controlled(false)
		# Shoot the mortar while in controlled state, because why not?
		elif Input.is_action_just_pressed("interact") and !Global.preparation_phase:
			shoot()

func shoot():
	if able_shoot:
		able_shoot = false
		print("Target", target.global_position)
		print("Spawn Point", $Models/Head/Barrel/ProjectileSpawn.global_position)
		var mortar_projectile = projectile_scene.instantiate()
		mortar_projectile.target = $TargetPivot/Target.global_position
		mortar_projectile.position = $Models/Head/Barrel/ProjectileSpawn.global_position
		mortar_projectile.damage_explosion = attack_damage
		mortar_projectile.speed = bullet_speed
		get_node("/root/Scene/Temporary/Projectiles").add_child(mortar_projectile, true) # if you want to shoot while still holding it maybe make projectile as unique or use absolute path to it
		$ReloadTimer.start(attack_speed)

func update_range_visual():
	if visible_range.visible and visible_range.global_position.y != 0.6:
		visible_range.global_position.y = 0.6

func update_UI():
	$ReloadTimerBar3D/SubViewport/ReloadTimerBar2D.max_value = attack_speed
	$ReloadTimerBar3D/SubViewport/ReloadTimerBar2D.value = attack_speed - $ReloadTimer.time_left
	
	if $ReloadTimer.time_left != 0:
		$ReloadTimerBar3D.show()

func _on_reload_timer_timeout():
	able_shoot = true
	$ReloadTimerBar3D.hide()

func controlled(enable: bool = true):
	match enable:
		true:
			get_node('/root/Scene/Player').player_lockInput = true
			is_controlled = true
			visible_range.show()
			$InteractTimer.start()
		false:
			get_node('/root/Scene/Player').player_lockInput = false
			is_controlled = false
			visible_range.hide()
