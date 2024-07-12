extends StaticBody3D
class_name Conveyor_Parent

var id: String # "conveyor" or "conveyor_grabber"
var price: int

var inv: Array = [] # for easier push and pop than string
var next_conveyor # this will be used for all conveyor to push item to the next conveyor
var grabber # only being utilized by grabber to check what item to grab from based on ids filter

var speed = 1.2

#Used for tweening and main mechanism
@onready var item_placeholder = $ItemPlaceholder
@onready var item_sprite = $ItemPlaceholder/ItemSprite

var tween
var tweening = false
var tween_finished = false

func _ready():
	active_state(false)
	$ItemPlaceholder/ItemSprite.hide()

func reset():
	if tween:
		tween.kill()
	inv.clear()
	tweening = false
	tween_finished = false
	item_sprite.global_position = item_placeholder.global_position

func active_state(enable: bool = true):
	match enable:
		true:
			$NextConveyor.monitoring = true
			$NextConveyor.monitorable = true
			$Grabber.monitoring = true
			$Grabber.monitorable = true
		false:
			$NextConveyor.monitoring = false
			$NextConveyor.monitorable = false
			$Grabber.monitoring = false
			$Grabber.monitorable = false

func _process(_delta):
	checkItemSprite()
	if !Global.preparation_phase:
		active_state(true)
	else:
		active_state(false)
		
	# Grabber to take item from the previous/back direction of this conveyor
	if !Global.preparation_phase and inv.is_empty() and grabber != null and self.id == "conveyor_grabber" and tweening == false and tween_finished == false:
		recieveItem(str(grabber.id))
		tweening = true
		tween = get_tree().create_tween()
		item_sprite.position = $Grabber.position
		tween.tween_property(item_sprite, "global_position", item_placeholder.global_position, speed)
		tween.connect("finished", _grab_is_finished)
	# Pusher to push current item to the next conveyor / Send item to next conveyor
	elif !Global.preparation_phase and !inv.is_empty() and next_conveyor != null and tweening == false and tween_finished == false:
		# This check for the next conveyor once (therefore if you put item in that conveyor it will stack for a while)
		if next_conveyor.inv.is_empty() or next_conveyor.tweening == true:
			tweening = true
			tween = get_tree().create_tween()
			tween.tween_property(item_sprite, "global_position", next_conveyor.item_placeholder.global_position, speed)
			tween.connect("finished", _tween_is_finished)
			
	if !Global.preparation_phase and !inv.is_empty() and next_conveyor != null and tween_finished == true and next_conveyor.inv.is_empty():
		sendItem(next_conveyor)
		tween_finished = false
		
func _grab_is_finished():
	tween.kill()
	tweening = false
	
func _tween_is_finished():
	tween.kill()
	tween_finished = true
	tweening = false

func sendItem(to):
	to.recieveItem(inv.pop_back())
	checkItemSprite()
	item_sprite.global_position = item_placeholder.global_position
	
func recieveItem(item):
	inv.push_back(item)
	checkItemSprite()
	#print(self.name, " now have ", inv)

func takeItem():
	if tween:
		tween.kill()
	tweening = false
	tween_finished = false
	item_sprite.global_position = item_placeholder.global_position
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
			print(self.name, " the next conveyor is ", body.name)

func _on_next_conveyor_body_exited(body):
	if body.is_class("StaticBody3D") and body.get_parent().name == 'Item':
		if Function.search_regex("conveyor", body.id):
			next_conveyor = null

func _on_grabber_body_entered(body):
	if self.id == "conveyor_grabber" and body.is_class("StaticBody3D") and body.get_parent().name == 'Item':
		# Filter for what to grab based on the ids
		if Function.search_regex("bullet_box", body.id) or Function.search_regex("gunpowder_box", body.id):
			grabber = body
			print(self.name, " is grabing resources from ", body.name)

func _on_grabber_body_exited(body):
	if self.id == "conveyor_grabber" and body.is_class("StaticBody3D") and body.get_parent().name == 'Item':
		if Function.search_regex("bullet_box", body.id) or Function.search_regex("gunpowder_box", body.id):
			grabber = null
