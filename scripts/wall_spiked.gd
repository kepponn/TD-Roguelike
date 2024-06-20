extends Wall_Parent

#buff/debuff
var buff_isEnchanted = false
var enchanted_bonus = 0

#FINAL STATUS
var final_attack_damage

func _ready():
	ready_up()
	final_attack_damage = attack_damage

func update_status(buff: String, enable: bool = false, buff_effect: int = 0):
	var mounted_effect = 0
	var enchanted_effect = 0
	match buff:
		# ENCHANTED - ATTACK DAMAGE
		"enchanted":
			match enable:
				true:
					buff_isEnchanted = true
					enchanted_effect = buff_effect
				false: 
					buff_isEnchanted = false
					enchanted_effect = 0
	final_attack_damage = attack_damage + enchanted_effect

func _on_area_3d_body_entered(body):
	if body.get_parent().name == 'Enemies' and $AttackSpeed.time_left <= 0.0:
		body.hit(final_attack_damage)
		$AttackSpeed.start(attack_speed)
		$SpikeSfx.play()
		var spike_Tween = get_tree().create_tween()
		spike_Tween.tween_property($Models/Spike, "scale", Vector3(1.3, 1, 1.3), 0.25)
		spike_Tween.tween_property($Models/Spike, "scale", Vector3(1, 1, 1), 0.25)

func _on_area_3d_body_exited(_body):
	pass # Replace with function body.
