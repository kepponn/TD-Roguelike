extends StaticBody3D

@onready var id = "shop"
var step_change: bool = true

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

func purchase():
	$PurchaseSfx.play(0.05)
