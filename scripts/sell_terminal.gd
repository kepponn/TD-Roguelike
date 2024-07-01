extends StaticBody3D

@onready var id = "sell"
var step_change: bool = true

@onready var sell_ui = get_node('/root/Scene/UI/Control/SellPrompt')

func _process(delta):
	var process_speed = 0.4 * delta
	if step_change:
		$Models/ScanLight.position.y -= process_speed
		$Models/ScanLine.position.y -= process_speed
		$Models/ScanLine_001.position.y += process_speed
		$Models/ScanLight_001.position.y += process_speed
		if $Models/ScanLight.position.y <= -0.98:
			step_change = false
	if !step_change:
		$Models/ScanLight.position.y += process_speed
		$Models/ScanLine.position.y += process_speed
		$Models/ScanLine_001.position.y -= process_speed
		$Models/ScanLight_001.position.y -= process_speed
		if $Models/ScanLight.position.y >= 0:
			step_change = true

func sell(item):
	sell_ui.sell_prompt(item)
