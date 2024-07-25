extends Node

@onready var gate_Timer = $GateTimer
@export var gate_Timer_Time:float

var gate_List: Array = [] # Appended from gate -> _ready()
var operatable_Gate_List: Array = [] # Appended from gate

func _process(delta):
	if Input.is_action_just_pressed("DEBUG"):
		operatable_Gate_List[0].open_gate()

func operate_gate():
	if !Global.preparation_phase:
		var opened_gate_index = opened_gate_randomizer()
		# open the selected gate from randomizer, and close every not selected gate
		for gate in operatable_Gate_List:
			if gate == operatable_Gate_List[opened_gate_index]:
				gate.open_gate()
			else:
				gate.close_gate()	
		# start timer after gate is opened, so it will loop again after timer timedout
		gate_Timer.start(gate_Timer_Time)
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
		await get_tree().create_timer(0.5).timeout
		#check path of every gate
		for gate in gate_List:
				gate.check_path()
		operate_gate()

func opened_gate_randomizer():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	if operatable_Gate_List.size() != 0 :
		return rng.randi_range(0, operatable_Gate_List.size()-1)

func _on_gate_timer_timeout():
	operate_gate()
