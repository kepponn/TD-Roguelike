extends Node3D

@onready var navigation = $NavigationRegion3D
var enable_navigation_auto_bake: bool = false
var await_navigation_auto_bake: bool = true
@onready var spawner = $Spawner
@onready var item_list = %Item

# -------------------- Ready and process below

func _ready():
	# Request navigation bake
	call_deferred("navigation_initial_bake")
	# Request spawner
	spawner.seed_enemies_weight()
	spawner.count_enemies()
	# Request audio background music
	$Audio/Preparation.play()
	# Additional setters
	Global.currency = 300

func _process(_delta):
	# Process defense phase complete parameters
	if $Enemies.get_child_count() == 0 and Global.enemy_left <= 0 and Global.preparation_phase == false:
		preparation_phase()

# -------------------- Independent function below

func pause(): # This is being called by player
	%IngameMenu.show()
	%IngameMenu.esc()
	get_tree().paused = true

func default_state(): # Default state for players and items, being called on each phase
	for i in item_list.get_child_count(): # Search for item to be reseted
		if Function.search_regex("turret", item_list.get_child(i).id):
			item_list.get_child(i).default_state() # Reset the drone state
			print("Flushing ", item_list.get_child(i))
		if Function.search_regex("crafter", item_list.get_child(i).id):
			item_list.get_child(i).reset() # Reset the value in crafter to default state
			print("Flushing ", item_list.get_child(i))
		if Function.search_regex("drone", item_list.get_child(i).id):
			item_list.get_child(i).reset() # Reset the drone state
			print("Flushing ", item_list.get_child(i))

func default_state_player():
	$Player.default_state() # sets for all player goes here

func defense_phase(): # This is being called by player
	spawner.spawn_timer.start()
	default_state_player()
	Global.preparation_phase = false
	print("Player Ready, Entering Wave ", Global.waves, " Defense Phase")
	%Shop.hide()
	$Audio/Preparation.stop()
	%IngameUI.UI_animator.play("Transition_toDefensePhase")
	get_tree().paused = true
	$Audio/Defending.play()

func preparation_phase(): # This is being called by self process
	Global.waves = Global.waves + 1
	Stats.wave_cleared = Global.waves - 1
	%Shop.update_item()
	default_state_player()
	default_state()
	Global.preparation_phase = true
	print("Wave_Cleared, Entering Prep Phase")
	spawner.seed_enemies_weight()
	spawner.count_enemies()
	$Audio/Defending.stop()
	await get_tree().create_timer(0.5).timeout
	%IngameUI.UI_animator.play("Transition_toPreparationPhase")
	get_tree().paused = true
	$Audio/Preparation.play()

# -------------------- Signals below

func navigation_initial_bake():
	navigation.bake_navigation_mesh()

func _on_navigation_region_3d_bake_finished():
	if !enable_navigation_auto_bake:
		enable_navigation_auto_bake = true
		print("Navigation - Initial bake finished")
	await_navigation_auto_bake = false

func _on_item_child_entered_or_exiting_tree(_node):
	navigation_auto_bake()

func navigation_auto_bake():
	if enable_navigation_auto_bake and !await_navigation_auto_bake:
		await get_tree().create_timer(0.2).timeout
		print("Navigation - Auto bake finished")
		navigation.bake_navigation_mesh()
