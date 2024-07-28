extends Node3D

var req_id: String # which turret is requesting this projectile to spawn (being use in customization)


var explosion_damage
var effect_areaLingerTime
var effect_burnDamage = 3
var effect_slowPower = 0.5
var enemies_array: Array

# Tween variables
var target
var tween_h
var tween_v
var tween_time
var speed




func _ready():
	tween_time = global_position.distance_to(target)/speed
	print(tween_time)
	tweening_h()
	tweening_v()

func tweening_h():
	tween_h = get_tree().create_tween()
	tween_h.set_ease(1).set_trans(0).parallel().tween_property(self, "global_position:x", target.x, tween_time)
	tween_h.set_ease(1).set_trans(0).parallel().tween_property(self, "global_position:z", target.z, tween_time)

func tweening_v():
	# Problem on tween because the location of the spawn is dynamic, and in tween we didnt consider dynamic whatsoever 
	# The prev mortar have projectile spawn location at self.global_position + Vector3(0, 1, 0)
	# The new mortar have projectile spawn that can be checked with $Models/Head/Barrel/ProjectileSpawn
	tween_v = get_tree().create_tween()
	tween_v.set_ease(1).set_trans(4).tween_property(self, "global_position:y", global_position.distance_to(target)*0.8, tween_time/2).as_relative()
	tween_v.set_ease(0).set_trans(4).tween_property(self, "global_position:y", 1, tween_time/2)
	tween_v.connect("finished", on_tweening_y_finished)

func on_tweening_y_finished():
	$CannonBall.hide()
	$LingeringEffect.show()
	$LingeringEffect/LingeringEffectTimer.start(5)
	for enemy in enemies_array:
		enemy.hit(explosion_damage)


func _on_aoe_body_entered(body):
	if body.has_method("hit"): # hit function exist in body
		if effect_burnDamage != 0:
			body.burned(effect_burnDamage)
		if effect_slowPower != 0:
			body.slowed(effect_slowPower)
		enemies_array.append(body)

func _on_aoe_body_exited(body):
	if enemies_array.has(body): # hit function exist in body
		if effect_burnDamage != 0:
			body.burned_lingerStart()
		if effect_slowPower != 0:
			body.slowed_lingerStart()
		enemies_array.erase(body)

func _on_lingering_effect_timer_timeout():
	queue_free()
