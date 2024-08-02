extends Node3D
class_name Scene
@export_category("Basic Information")
@export var stage_id: String 

@onready var navigation = %NavigationRegion3D
var enable_navigation_auto_bake: bool = false
var await_navigation_auto_bake: bool = true
@onready var spawner = %Spawner
@onready var enemies = %Enemies
@onready var item_list = %Item

var has_defensive_structure = false

# -------------------- Setup new scene level
# 1. Put your level gridmap in child of %NavigationRegion3D
# 2. Adjust position of the following: Player, Spawner, Defend_Point and Shop accordingly

# -------------------- Ready and process below

func seed_enemiesRNGWeight():
	var file = FileAccess.open("res://autoload/stage_db_rng.json", FileAccess.READ)
	var file_text = file.get_as_text()
	file.close()
	# Parse JSON data to be easily modified by for loops
	var data = JSON.parse_string(file_text)
	# Check if the id exist in JSON data
	if data.has(stage_id):
		var stage_data = data[stage_id]
		spawner.enemies_spawn_rate = stage_data
	print("This print from Scene ",spawner.enemies_spawn_rate)

func _ready():
	seed_enemiesRNGWeight()
	# Request navigation bake
	call_deferred("navigation_initial_bake")
	# Request and setter to spawner
	spawner.enemies_scene_node = %Enemies
	spawner.seed_enemies_weight()
	spawner.count_enemies()
	default_state_gate()
	# Request audio background music
	$Audio/Preparation.play()
	# Additional setters
	# Global.currency = 300

func _process(_delta):
	# Process defense phase complete parameters
	if enemies.get_child_count() == 0 and Global.enemy_left <= 0 and Global.preparation_phase == false:
		preparation_phase()
	# Check for defensive structure to start the wave
	if !has_defensive_structure:
		for i in item_list.get_child_count():
			if Function.search_regex("turret", item_list.get_child(i).id):
					has_defensive_structure = true

# -------------------- Independent function below

func pause(): # This is being called by player
	%IngameMenu.show()
	%IngameMenu.esc()
	get_tree().paused = true

func default_state(): # Default state for items, being called only on preparation phase
	for i in item_list.get_child_count(): # Search for item to be reseted
		if Function.search_regex("turret", item_list.get_child(i).id):
			item_list.get_child(i).default_state() # Reset the turret state
			print("Flushing ", item_list.get_child(i))
		if Function.search_regex("wall_mountable", item_list.get_child(i).id) and item_list.get_child(i).is_mountable_occupied:
			item_list.get_child(i).currently_mountable_item.default_state() # Reset the turret on mounted wall state
			print("Flushing ", item_list.get_child(i).currently_mountable_item)
		if Function.search_regex("crafter", item_list.get_child(i).id):
			item_list.get_child(i).reset() # Reset the value in crafter to default state
			print("Flushing ", item_list.get_child(i))
		if Function.search_regex("drone", item_list.get_child(i).id):
			item_list.get_child(i).reset() # Reset the drone state
			print("Flushing ", item_list.get_child(i))
		if Function.search_regex("conveyor", item_list.get_child(i).id):
			item_list.get_child(i).reset()
			print("Flushing ", item_list.get_child(i))
		if Function.search_regex("mortar", item_list.get_child(i).id):
			item_list.get_child(i).default_state()
			print("Flushing ", item_list.get_child(i))
	for projectile in %Projectiles.get_child_count():
		%Projectiles.get_child(projectile).queue_free()

func default_state_gate(): # Default state for gate, being called on both phase
	# if on preparation phase -> all door will be opened
	# if on defense phase -> all door will be closed
	$GateController.default_state()

func default_state_player(): # Default state for players, being called on both phase
	$Player.default_state()

func request_defense_phase(player): # This is being called by player
	if has_defensive_structure and Global.preparation_phase and Global.is_pathReachable and !player.player_isHoldingItem and !player.player_lockInput:
		%ReadyWaveAlert.hide()
		defense_phase()
	elif !Global.is_pathReachable:
		%ReadyWaveAlert.show()
		%ReadyWaveAlert.text = "Cannot ready-up, please clear the path!"
	elif player.player_isHoldingItem:
		%ReadyWaveAlert.show()
		%ReadyWaveAlert.text = "Cannot ready-up, player is still holding items!"
	# This being run in seperate statement to make it independently check itself
	elif !has_defensive_structure:
		%ReadyWaveAlert.show()
		%ReadyWaveAlert.text = "Cannot ready-up, there is no defensive structure!"
	elif player.player_lockInput:
		%ReadyWaveAlert.show()
		%ReadyWaveAlert.text = "Cannot ready-up, player is still controlling items!"

func defense_phase(): # Run after request_defense_phase(player) when all params check complete
	spawner.spawn_timer.start()
	default_state_player()
	Global.preparation_phase = false
	default_state_gate()
	$GateController.operate_gate()
	print("Player ready, entering defense phase wave ", Global.waves)
	%Shop.hide()
	$Audio/Preparation.stop()
	%IngameUI.UI_animator.play("Transition_toDefensePhase")
	get_tree().paused = true
	$Audio/Defending.play()

func preparation_phase(): # This is being called by self process
	Global.waves = Global.waves + 1
	Stats.wave_cleared = Global.waves - 1
	%Shop.reroll_price = 0
	%Shop.update_item()
	default_state_player()
	default_state()
	Global.preparation_phase = true
	default_state_gate()
	print("Wave cleared, entering preparation phase wave ", Global.waves)
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

