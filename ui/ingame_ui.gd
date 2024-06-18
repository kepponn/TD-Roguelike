extends Control
@onready var player = get_node('/root/Scene/Player')
@onready var UI_animator = $IngameUiAnimator

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Global.preparation_phase == true:
		$MarginContainer/Control/PreparationTimeLeftBar.show()
		$MarginContainer/Control/EnemyLeftBar.hide()
	else :
		$MarginContainer/Control/PreparationTimeLeftBar.hide()
		$MarginContainer/Control/EnemyLeftBar.show()
	
	$MarginContainer/Control/Waves.text = "Waves " + str(Global.waves)
	#Enemey Bar and Label
	$MarginContainer/Control/EnemyLeftBar.max_value = Global.total_enemies
	$MarginContainer/Control/EnemyLeftBar.value = Global.enemy_left
	$MarginContainer/Control/EnemyLeftBar/Label.text = str(Global.enemy_left)
	#Preparation Bar and Label
	if Global.waves == 1:
		#$MarginContainer/Control/PreparationTimeLeftBar.max_value = Global.preparation_time
		$MarginContainer/Control/PreparationTimeLeftBar.value = $MarginContainer/Control/PreparationTimeLeftBar.max_value
		$MarginContainer/Control/PreparationTimeLeftBar/Label.text = "Press ''Space'' to Start"
	else:
		pass
		#$MarginContainer/Control/PreparationTimeLeftBar.max_value = Global.preparation_time
		#$MarginContainer/Control/PreparationTimeLeftBar.value = $"../../PreparationTimer".time_left
		#$MarginContainer/Control/PreparationTimeLeftBar/Label.text = str(int($"../../PreparationTimer".time_left))
	#Currency
	$MarginContainer/Control/TextureRect/PlayerCurrencyCount.text = str(Global.currency)

func _on_ingame_ui_animator_animation_finished(_anim_name):
	get_tree().paused = false
