extends Marker3D



var enemies: PackedScene = preload("res://scene/enemy.tscn")

@onready var spawn_timer: Timer = $Timer
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	spawn_enemies()
	pass
	

func spawn_enemies():
	if $Timer.time_left <= 0 and Global.enemy_left > 0 and Global.preparation_phase == false:
		Global.enemy_left = Global.enemy_left - 1
		var enemy = enemies.instantiate()
		get_node("/root/Node3D/Enemies").add_child(enemy,true)
		enemy.transform = global_transform
		$Timer.start(randf_range(1.5,3.0))
		
		print("Enemies Left = ", Global.enemy_left)

func count_enemies():
	#W 0:00:03:0280   Narrowing conversion (float is converted to int and loses precision).
	Global.total_enemies = Global.base_enemiesCount * Global.waves
	Global.enemy_left = Global.total_enemies
