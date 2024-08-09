extends Wall_Parent

var enemies_array: Array = []

#buff/debuff
var buff_isEnchanted = false
var enchanted_bonus = 0

#FINAL STATUS
var final_attack_damage
@onready var visible_range = $Range/VisibleRange

func _ready():
	ready_up()
	visible_range.hide()
	final_attack_damage = attack_damage

func _process(_delta):
	match Global.preparation_phase:
		true:
			update_range_visual()
		false:
			attack()
	
func update_range_visual():
	if $Range/VisibleRange.visible and $Range/VisibleRange.global_position.y != 0.6:
		$Range/VisibleRange.global_position.y = 0.6

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

func attack():
	if !enemies_array.is_empty() and $AttackSpeed.time_left <= 0.0:
		print(enemies_array)
		for i in enemies_array.size(): # Hit everyone in area with this
			enemies_array[i].hit(final_attack_damage)
		#body.hit(final_attack_damage)
		$AttackSpeed.start(attack_speed)
		$SpikeSfx.play()
		var spike_Tween = get_tree().create_tween()
		spike_Tween.tween_property($Models/Spike, "scale", Vector3(1.3, 1, 1.3), 0.25)
		spike_Tween.tween_property($Models/Spike, "scale", Vector3(1, 1, 1), 0.25)

func _on_area_3d_body_entered(body):
	if body.get_parent().name == 'Enemies':
		enemies_array.append(body)

func _on_area_3d_body_exited(body):
	if body.get_parent().name == 'Enemies':
		enemies_array.erase(body)
