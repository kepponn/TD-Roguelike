extends Wall_Parent


func _ready():
	ready_up()

func _on_area_3d_body_entered(body):
	if body.get_parent().name == 'Enemies' and $AttackSpeed.time_left <= 0.0:
		body.hit(attack_damage)
		$AttackSpeed.start(attack_speed)
		$SpikeSfx.play()
		var spike_Tween = get_tree().create_tween()
		spike_Tween.tween_property($Models/Spike, "scale", Vector3(1.3, 1, 1.3), 0.25)
		spike_Tween.tween_property($Models/Spike, "scale", Vector3(1, 1, 1), 0.25)

func _on_area_3d_body_exited(_body):
	pass # Replace with function body.
