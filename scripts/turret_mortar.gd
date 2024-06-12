extends StaticBody3D

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
var attack_damage: int = 10
var attack_range: int
var attack_speed: float = 5

var bullet_speed: int = 6

@onready var visible_range: MeshInstance3D = $TargetPivot/Target/VisibleRange
@onready var target = $TargetPivot/Target.global_position

var controlled: bool
var able_shoot: bool = true

func _process(delta):
	update_UI()
	if Input.is_action_just_pressed("DEBUG"):
		print("SHOOT")
		shoot()
		
	if controlled:
		if Input.is_action_just_pressed("ui_up") and $TargetPivot/Target.position.z >= 5 and $TargetPivot/Target.position.z < 8:
			$TargetPivot/Target.position.z += 1
		elif Input.is_action_just_pressed("ui_down") and $TargetPivot/Target.position.z > 5 and $TargetPivot/Target.position.z <= 8:
			$TargetPivot/Target.position.z -= 1
		elif Input.is_action_pressed("ui_left"):
			$TargetPivot.rotation_degrees.y += 100 * delta
		elif Input.is_action_pressed("ui_right"):
			$TargetPivot.rotation_degrees.y -= 100 * delta
	#still bugged if interacted using same button as rotate
	if Input.is_action_just_pressed("DEBUG"):
		get_node('/root/Node3D/Player').player_lockInput = false
		controlled = false
		print("keluar")
			

func shoot():
	if able_shoot:
		able_shoot = false
		var mortar_projectile = projectile_scene.instantiate()
		mortar_projectile.target = target
		mortar_projectile.position = self.global_position + Vector3(0,1,0)
		mortar_projectile.damage_explosion = attack_damage
		mortar_projectile.speed = bullet_speed
		get_node("/root/Node3D/Projectile").add_child(mortar_projectile, true) # if you want to shoot while still holding it maybe make projectile as unique or use absolute path to it
		$ReloadTimer.start(attack_speed)

func update_UI():
	$ReloadTimerBar3D/SubViewport/ReloadTimerBar2D.max_value = attack_speed
	$ReloadTimerBar3D/SubViewport/ReloadTimerBar2D.value = attack_speed - $ReloadTimer.time_left
	
	if $ReloadTimer.time_left != 0:
		$ReloadTimerBar3D.show()

func _on_reload_timer_timeout():
	able_shoot = true
	$ReloadTimerBar3D.hide()


