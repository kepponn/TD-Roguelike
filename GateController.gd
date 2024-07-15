extends Node

var gate_List: Array = [] # Appended from gate -> _ready()
var operatable_Gate_List: Array = [] # Appended from gate
var gate_Timer

func operate_gate():
	if !Global.preparation_phase:
		var opened_gate_index = opened_gate_randomizer()
		# open the selected gate from randomizer, and close every not selected gate
		for gate in operatable_Gate_List:
			if gate == operatable_Gate_List[opened_gate_index]:
				gate.open_gate()
			else:
				gate.close_gate()	
		# create timer after gate is opened, so it will loop again after timer timedout
		create_scene_timer()
	#bake new navigation  | using function from Scene_parent -> navigation_auto_bake()
	get_parent().navigation_auto_bake()
	
func default_state(): # Called by scene_parent script -> default_state_gate()
	if Global.preparation_phase :
		#on preparation - open all gate
		for gate in gate_List:
			gate.open_gate()
	else:
		#on defense - close all gate
		for gate in gate_List:
			gate.close_gate()

func create_scene_timer():
	gate_Timer = get_tree().create_timer(randi_range(5,5))
	gate_Timer.connect("timeout", _on_gate_Timer_timeout)

func opened_gate_randomizer():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	return rng.randi_range(0, operatable_Gate_List.size()-1)
	
func _on_gate_Timer_timeout():
	operate_gate()
	
