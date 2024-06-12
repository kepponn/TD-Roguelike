extends Node3D


var target
var tween_h
var tween_v
var tween_time

var damage_explosion
var speed

var enemies_array: Array

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
	tween_v = get_tree().create_tween()
	tween_v.set_ease(1).set_trans(4).tween_property(self, "global_position:y", global_position.distance_to(target)*0.8, tween_time/2).as_relative()
	tween_v.set_ease(0).set_trans(4).tween_property(self, "global_position:y", -global_position.distance_to(target)*0.8 - 1, tween_time/2).as_relative()
	tween_v.connect("finished", on_tweening_y_finished)

func on_tweening_y_finished():
	$MeshInstance3D.hide()
	for enemy in enemies_array:
		enemy.hit(damage_explosion)
	queue_free()

func _on_aoe_body_entered(body):
	if body.has_method("hit"): # hit function exist in body
		enemies_array.append(body)

func _on_aoe_body_exited(body):
	if enemies_array.has(body): # hit function exist in body
		enemies_array.erase(body)


