extends Marker3D

@onready var base_enemiesCount: float = 2
var total_enemies: int
var waves: int = 1

var enemies: PackedScene = preload("res://scene/enemy.tscn")

@onready var spawn_timer: Timer = $Timer
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	spawn_enemies()
	pass
	

func spawn_enemies():
	if $Timer.time_left <= 0 and total_enemies > 0 and $"../Player".preparation_phase == false:
		total_enemies = total_enemies - 1
		var enemy = enemies.instantiate()
		get_node("/root/Node3D/Enemies").add_child(enemy,true)
		enemy.transform = global_transform
		$Timer.start(randf_range(1.5,3.0))
		
		print("Enemies Left = ", total_enemies)

func count_enemies():
	total_enemies = base_enemiesCount * waves
