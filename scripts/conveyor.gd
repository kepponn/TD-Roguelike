extends StaticBody3D

var id = "conveyor"
var price: int

@onready var area = $NextConveyor
var inv: Array = [] # for easier push and pop than string
var next_conveyor
@onready var timer = $Timer

func _ready():
	active_state(false)
	$ItemPlaceholder/ItemSprite.hide()

func active_state(enable: bool = true):
	match enable:
		true:
			area.monitoring = true
			area.monitorable = true
		false:
			area.monitoring = false
			area.monitorable = false

func _process(_delta):
	checkItemSprite()
	if !Global.preparation_phase:
		active_state(true)
	else:
		active_state(false)
	# Send item to next conveyor (timer check so it doesnt zip to end point)
	if !Global.preparation_phase and !inv.is_empty() and next_conveyor != null and $Timer.is_stopped():
		# This check for the next conveyor once (therefore if you put item in that conveyor it will stack for a while)
		$Timer.start(2)
		if next_conveyor.inv.is_empty() or !next_conveyor.timer.is_stopped():
			# This timer need to be static to allow all conveyor move at the same pace
			$Timer.start(2)

func _on_timer_timeout():
	#print("sending item to the next conveyor")
	sendItem(next_conveyor)

func sendItem(to):
	to.recieveItem(inv.pop_back())

func recieveItem(item):
	inv.push_back(item)
	print(self.name, " now have ", inv)

func takeItem():
	$Timer.stop()
	return inv.pop_back()

func checkItemSprite():
	if !inv.is_empty():
		match inv[0]:
			"ammo_box":
				$ItemPlaceholder/ItemSprite.texture = load("res://assets/icon/ammo-box.png")
				$ItemPlaceholder/ItemSprite.show()
			"gunpowder_box":
				$ItemPlaceholder/ItemSprite.texture = load("res://assets/icon/powder.png")
				$ItemPlaceholder/ItemSprite.show()
			"bullet_box":
				$ItemPlaceholder/ItemSprite.texture = load("res://assets/icon/shotgun-rounds.png")
				$ItemPlaceholder/ItemSprite.show()
	else:
		$ItemPlaceholder/ItemSprite.hide()

func _on_next_conveyor_body_entered(body):
	if body.is_class("StaticBody3D") and body.get_parent().name == 'Item':
		if Function.search_regex("conveyor", body.id):
			next_conveyor = body
			print(self.name, " the next conveyor is ", body)

func _on_next_conveyor_body_exited(body):
	if body.is_class("StaticBody3D") and body.get_parent().name == 'Item':
		if Function.search_regex("conveyor", body.id):
			next_conveyor = null
