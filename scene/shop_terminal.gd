extends StaticBody3D

@onready var id = "shop"
var step_change: bool = true

func _process(_delta):
	if step_change:
		$Models/ScanLight.position.y -= 0.01
		$Models/ScanLine.position.y -= 0.01
		$Models/ScanLine_001.position.y += 0.01
		$Models/ScanLight_001.position.y += 0.01
		if $Models/ScanLight.position.y <= -0.98:
			step_change = false
	if !step_change:
		$Models/ScanLight.position.y += 0.01
		$Models/ScanLine.position.y += 0.01
		$Models/ScanLine_001.position.y -= 0.01
		$Models/ScanLight_001.position.y -= 0.01
		if $Models/ScanLight.position.y >= 0:
			step_change = true


