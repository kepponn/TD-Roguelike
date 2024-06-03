extends Marker3D

var enemies: PackedScene = preload("res://scene/enemy.tscn")

@onready var spawn_timer: Timer = $Timer
@onready var nav: NavigationAgent3D = $NavigationAgent3D
var direction
var velocity

func _ready():
	pass

func _process(_delta):
	spawn_enemies()
	check_path()

func check_path():
	nav.target_position = Global.final_target
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	
	if nav.is_target_reachable() == true :
		Global.is_pathReachable = true
		#print("path is ok")
	elif nav.is_target_reachable() == false :
		Global.is_pathReachable = false
		#print("path is blocked")
	
func spawn_enemies():
	if $Timer.time_left <= 0 and Global.enemy_spawned != Global.total_enemies and Global.preparation_phase == false:
		Global.enemy_spawned = Global.enemy_spawned + 1
		var enemy = enemies.instantiate()
		get_node("/root/Node3D/Enemies").add_child(enemy,true)
		enemy.transform = global_transform
		$Timer.start(randf_range(1.5,3.0))
		print("Enemies Spawned = ", Global.enemy_spawned)
		
func enemy_spawn():
	$Audio/SpawnSfx.play()
	
func enemy_died():
	$Audio/DeathSfx.play()

func count_enemies():
	#W 0:00:03:0280   Narrowing conversion (float is converted to int and loses precision).
	Global.total_enemies = Global.base_enemiesCount * Global.waves
	Global.enemy_left = Global.total_enemies
	Global.enemy_spawned = 0
