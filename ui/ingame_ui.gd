extends Control
@onready var player = get_node('/root/Node3D/Player')
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Global.preparation_phase == true:
		$MarginContainer/Control/PreparationTimeLeftBar.show()
		$MarginContainer/Control/EnemyLeftBar.hide()
	else :
		$MarginContainer/Control/PreparationTimeLeftBar.hide()
		$MarginContainer/Control/EnemyLeftBar.show()
	
	
	#Enemey Bar and Label
	$MarginContainer/Control/EnemyLeftBar.value = Global.enemy_left
	$MarginContainer/Control/EnemyLeftBar/Label.text = str(Global.enemy_left)
	#Preparation Bar and Label
	$MarginContainer/Control/PreparationTimeLeftBar.value = player.prep_timer.time_left
	$MarginContainer/Control/PreparationTimeLeftBar/Label.text = str(int(player.prep_timer.time_left))
	#Currency
	$MarginContainer/Control/TextureRect/PlayerCurrencyCount.text = str(Global.currency)

func update():
	#Called only on Player -> func ready()
	$MarginContainer/Control/Waves.text = "Waves " + str(Global.waves)
	$MarginContainer/Control/EnemyLeftBar.max_value = Global.total_enemies
	$MarginContainer/Control/PreparationTimeLeftBar.max_value = player.preparation_time
	

	
