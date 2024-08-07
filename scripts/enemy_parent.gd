extends CharacterBody3D
class_name Enemy_Parent

@export var HP: int # = 3
@export var SPEED: float # = 10

# Navigation
@onready var nav: NavigationAgent3D = $NavigationAgent3D

# Particles
@onready var explosion_effect = preload("res://scene/explosion_effect.tscn")

# Effect Section - Slow / Burned DoT
var burn_damage
@onready var burn_linger_timer = $EffectTimer/BurnLingerTimer
@onready var burn_tick_timer = $EffectTimer/BurnTickTimer

var slow_multiplier = 0
@onready var slow_linger_timer = $EffectTimer/SlowLingerTimer

var max_HP: int
var direction: Vector3

var damage_info_tween
var damage_info_tween_position

# This is actually fucked up...
# CollisionShape3D difference WILL affect how the navigation is processed
# Default: CapluseSpahe3D, Radius: 0.45m, Height: 1.95m

func ready_up():
	max_HP = HP
	call_deferred("nav_setup")
	$Audio/SpawnSfx.play()
	$DamageInfo3D.hide()
	damage_info_tween_position = $DamageInfo3D.position

func check_self():
	if HP <= 0:
		var explosion = explosion_effect.instantiate()
		get_node("/root/Scene/Temporary/Projectiles").add_child(explosion, true)
		explosion.global_position = global_position
		var tween = get_tree().create_tween()
		tween.tween_property(Global, "currency", Global.currency + 5, 1)
		print(Global.currency)
		#Global.currency = Global.currency + 5
		Stats.currency_gained += 5
		Global.enemy_left = Global.enemy_left - 1
		Stats.enemy_killed(self.id)
		$Audio/DeathSfx.play()
		print("Enemy Left = ",Global.enemy_left)
		queue_free()

func run_navigation(delta):
	nav_setup()
	# This is still a wrong implementation of delta time but at lease it works
	# velocity = direction * SPEED * (0.2 + delta)
	# The use of lerp in here make that the enemy navigation dont stuck like a fucking retard
	# Please check and tweak the $NavigationRegion3D
	velocity = velocity.lerp(direction * SPEED* (1 - slow_multiplier) * (0.2 + delta), 0.15)
	move_and_slide()
	update_HP()

func nav_setup():
	# await for 1 frame in process and nav error gone, wizard programming
	#if needed there is baking_finished() signal on NavigationRegion3D
	await get_tree().physics_frame
	nav.target_position = Global.final_target
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	
func hit(damage, damage_type: String = "normal"):
	damage_info(damage, damage_type)
	HP = HP - damage
	check_self()
	
func damage_info(damage, damage_type: String = "normal"):
	$DamageInfo3D.show()
	$DamageInfo3D/SubViewport/Label.text = str(damage)
	match damage_type: # add unique damage effect here!
		"normal":
			$DamageInfo3D/SubViewport/Label.self_modulate = Color("ffffffff")
		"burn":
			$DamageInfo3D/SubViewport/Label.self_modulate = Color("ff3610")
		"cold":
			$DamageInfo3D/SubViewport/Label.self_modulate = Color("00ddf5")
	if damage_info_tween:
		damage_info_tween.kill()
		$DamageInfo3D.position = damage_info_tween_position
		$DamageInfo3D.modulate = Color("ffffffff")
	damage_info_tween = get_tree().create_tween()
	damage_info_tween.parallel().tween_property($DamageInfo3D, "position", $DamageInfo3D.position + Vector3(0.3, 0.7, 0), 0.6)
	damage_info_tween.parallel().tween_property($DamageInfo3D, "modulate", Color("ffffff00"), 0.6)
	
#--------------------------------------------------------- EFFECT ------------------------------------------------------------
# BURN EFFECT
func burned(damage, ticktime):
	print(self.name, " is just burned")
	burn_damage = damage
	burn_tick_timer.wait_time = ticktime
	burn_tick_timer.start(ticktime)

func _on_burn_tick_timer_timeout():
	HP = HP - burn_damage
	damage_info(burn_damage, "burn")
	check_self()
	print(self.name, " is taking burn damage")
	burn_tick_timer.start()

func _on_burn_linger_timer_timeout():
	print(self.name, " is not burned anymore")
	burn_tick_timer.stop()

# SLOW EFFECT
func slowed(multiplier):
	print(self.name, " is just slowed")
	slow_multiplier = multiplier

func _on_slow_linger_timer_timeout():
	print(self.name, " is not slowed anymore")
	slow_multiplier = 0
	
#-------------------------------------------------------------------------------------------------------------------------------
func update_HP():
	if HP != max_HP:
		$HealthBar3D.show()
		
	$HealthBar3D/SubViewport/HealthBar2D.max_value = max_HP
	$HealthBar3D/SubViewport/HealthBar2D.value = HP

func _on_navigation_agent_3d_target_reached():
	if Global.life_array.is_empty(): # Which mean game over
		get_tree().change_scene_to_file("res://ui/game_over.tscn")
	if Global.life_array.size() > 0:
		Global.life_array[0].destroy()
		Stats.life_crystal_used += 1
	Global.enemy_left = Global.enemy_left - 1
	queue_free()




