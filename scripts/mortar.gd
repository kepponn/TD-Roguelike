extends StaticBody3D

@export_category("Basic Information")
@export var id: String = "mortar"
var price: int

@export_category("Model and Scene Assets")
@export var projectile_scene: PackedScene

@export_category("Attack Information")
var attack_damage: int
var attack_rangeMin: float
var attack_rangeMax: float
var attack_speed: float
var bullet_speed: int

@onready var visible_range: MeshInstance3D = $TargetPivot/Target/VisibleRange
@onready var target = $TargetPivot/Target
var is_controlled: bool = false
var able_shoot: bool = true

#buff/debuff
var buff_isEnchanted = false
var enchanted_bonus = 0

#FINAL STATUS
var final_attack_damage

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

func _ready():
	seed_property()
	final_attack_damage = attack_damage
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

func update_status(buff: String, enable: bool = false, buff_effect: int = 0):
	var enchanted_effect = 0
	match buff:
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
