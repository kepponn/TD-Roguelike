extends Node

var gateList: Array = [] # Appended from gate -> _ready()
var gate_Timer

#func _ready():
	##check if there is any gate in the stage
	#if !gateList.is_empty():
		#operate_gate()
	
func operate_gate():
	var opened_gate_index = opened_gate_randomizer()
	print("Opened Gate Index: ", opened_gate_index)
	# open the selected gate from randomizer, and close every not selected gate
	for gate in gateList:
		if gate == gateList[opened_gate_index]:
			gate.open_gate()
			print("opening ", gate)
		else:
			gate.close_gate()
			print("closing ", gate)
	#bake new navigation  | using function from Scene_parent -> navigation_auto_bake()
	get_parent().navigation_auto_bake()
	# create timer after gate is opened, so it will loop again after timer timedout
	create_scene_timer()
	
func default_state(): # Called by scene_parent script -> default_state_gate()
	#default state is all door opened
	for gate in gateList:
		gate.open_gate()

func create_scene_timer():
	gate_Timer = get_tree().create_timer(randi_range(3,6))
	gate_Timer.connect("timeout", _on_gate_Timer_timeout)

func opened_gate_randomizer():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	return rng.randi_range(0, gateList.size()-1)
	
func _on_gate_Timer_timeout():
	operate_gate()
	
