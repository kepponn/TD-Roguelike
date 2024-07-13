extends StaticBody3D

# Concept 1:
# controlled by player_scene_rework() script
# is buyable object
# can be moved by player
# front and back of the gate cannot be blocked with any blocks or building
# can be interacted when preparation or defense phase
# can be interacted to open gate
# can be interacted to close gate ONLY IF ENEMY PATH WILL NOT BE BLOCKED IF GATE IS CLOSED
# have certain cooldown after each interaction if interacted on DEFENSE PHASE
# only 1 gate able to be opened if there is 2 or more gate
# ex : if there is gate A, B, C, and current opened gate is B, 
# after player opened gate A gate B will automatically closed
# then every single gate will be on cooldown

# Concept 2:
# is generated object for certain map
# cannot be moved by player
# front and back of the gate cannot be blocked with any blocks or building or walls
# 2.A INTERACTABLE
# controlled by player_scene_rework() script
# can be interacted when preparation or defense phase
# can be interacted to open gate
# can be interacted to close gate ONLY IF ENEMY PATH WILL NOT BE BLOCKED IF GATE IS CLOSED
# 2.B AUTOMATED
# controlled by scene_parent OR MAYBE create new door_controller node with script to control door
# can't be interacted by player
# has internal TIMER that will automatically cycle opened gate

# Currently made gate is using Concept 2.B

# changelog for changed script:
# -player_scene_rework script:
#  line 346 -> added another parameter for pickup item -> player_interactedItem_Temp.id != "gate"
#  so player can't pick up gate
#  line 365 -> added another parameter for swapping item -> player_interactedItem_Temp.id != "gate"
#  so player can't swap item with gate
#  line 515 -> added another parameter for rotating item -> player_interactedItem_Temp.id != "gate"
#  so player can't rotate gate

# -input_guide_ui script:
#  line 98 -> added another parameter for pickup item ui -> player.player_interactedItem_Temp.id != "gate"
#  line 153 -> added another parameter for rotate item ui -> player.player_interactedItem_Temp.id != "gate"


var id: String = "gate"
var price: int
var tween
@onready var gate_controller = get_node("/root/Scene/GateController")
@onready var gate = $Model/Gate

func _ready():
	gate_controller.gateList.append(self)

func close_gate():
	tween = get_tree().create_tween()
	tween.tween_property(gate, "position:y", 0, 1)
	set_collision_layer_value(1, true)
	set_collision_mask_value(1, true)
	
func open_gate():
	tween = get_tree().create_tween()
	tween.tween_property(gate, "position:y", -1, 1)
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)

func set_front_back_collision(enable: bool):
	if enable:
		$FrontCollisionChecker.disabled = false
		$BackCollisionChecker.disabled = false
	elif !enable:
		$FrontCollisionChecker.disabled = true
		$BackCollisionChecker.disabled = true

