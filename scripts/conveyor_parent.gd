extends StaticBody3D
class_name Conveyor_Parent

var id: String # "conveyor" or "conveyor_grabber" or "conveyor_setter"
var price: int

var inv: Array = [] # for easier push and pop than string
var next_conveyor # this will be used for all conveyor to push item to the next conveyor
var grabber # only being utilized by grabber to check what item to grab from based on ids filter
var setter # only being utilized by setter to put items into other stuff

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
			$Setter.monitoring = true
			$Setter.monitorable = true
		false:
			$NextConveyor.monitoring = false
			$NextConveyor.monitorable = false
			next_conveyor = null
			$Grabber.monitoring = false
			$Grabber.monitorable = false
			grabber = null
			$Setter.monitoring = false
			$Setter.monitorable = false
			setter = null

func _process(_delta):
	checkItemSprite()
	if !Global.preparation_phase:
		active_state(true)
	else:
		active_state(false)
		
	# Grabber to take item from the previous/back direction of this conveyor
	if !Global.preparation_phase and inv.is_empty() and grabber != null and self.id == "conveyor_grabber" and tweening == false and tween_finished == false:
		if grabber.id == "bullet_box" or grabber.id == "gunpowder_box":
			recieveItem(str(grabber.id))
			_grabber_tween()
		elif grabber.id == "crafter" and grabber.prod_ammo_box == 1:
			recieveItem(grabber.conveyor_get_product())
			_grabber_tween()
		elif grabber.id == "storage_box" and grabber.items_count > 0:
			recieveItem(grabber.take(self))
			grabber.check_self()
			_grabber_tween()
	# Setter to put item into whatever needed
	elif !Global.preparation_phase and !inv.is_empty() and setter != null and self.id == "conveyor_setter" and tweening == false and tween_finished == false:
		if setter.id == "crafter":
			if inv[0] == "gunpowder_box" and setter.mats_gunpowder_box == 0:
				_setter_tween()
			elif inv[0] == "bullet_box" and setter.mats_bullet_box == 0:
				_setter_tween()
		elif setter.id == "drone_station":
			if inv[0] == "ammo_box" and setter.base_ammo < 3:
				_setter_tween()
		elif setter.id == "storage_box":
			# this will send the item to storage box if the storage is empty or if the items are the same
			if !setter.is_used or setter.items_display == inv[0] and setter.items_count < setter.items_count_max:
				_setter_tween()
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

func _setter_tween():
	tweening = true
	tween = get_tree().create_tween()
	tween.tween_property(item_sprite, "global_position", setter.global_position, speed)
	tween.connect("finished", _setter_is_finished)

func _setter_is_finished():
	tween.kill()
	tweening = false
	if setter.id == "crafter":
		if inv[0] == "gunpowder_box":
			setter.conveyor_put_ingredient(inv.pop_back())
		elif inv[0] == "bullet_box":
			setter.conveyor_put_ingredient(inv.pop_back())
	elif setter.id == "drone_station":
		if inv[0] == "ammo_box":
			setter.conveyor_put_ammo()
			inv.pop_back()
	elif setter.id == "storage_box":
		setter.put(self, inv.pop_back())
	item_sprite.global_position = item_placeholder.global_position

func _grabber_tween():
	tweening = true
	tween = get_tree().create_tween()
	item_sprite.position = $Grabber.position
	tween.tween_property(item_sprite, "global_position", item_placeholder.global_position, speed)
	tween.connect("finished", _grabber_is_finished)

func _grabber_is_finished():
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
		Function.check_sprite(inv[0], $ItemPlaceholder/ItemSprite)
	else:
		$ItemPlaceholder/ItemSprite.hide()

func _on_next_conveyor_body_entered(body):
	if body.is_class("StaticBody3D") and body.get_parent().name == 'Item':
		if Function.search_regex("conveyor", body.id):
			next_conveyor = body
			print(self.name, " the next conveyor is ", body.name)

func _on_grabber_body_entered(body):
	if self.id == "conveyor_grabber" and body.is_class("StaticBody3D") and body.get_parent().name == 'Item':
		# Filter for what to grab based on the ids
		if Function.search_regex("bullet_box", body.id) or Function.search_regex("gunpowder_box", body.id) or Function.search_regex("crafter", body.id) or Function.search_regex("storage_box", body.id):
			grabber = body
			print(self.name, " is grabing resources from ", body.name)

func _on_setter_body_entered(body):
	if self.id == "conveyor_setter" and body.is_class("StaticBody3D") and body.get_parent().name == 'Item':
		# Filter for what to grab based on the ids
		if Function.search_regex("crafter", body.id) or Function.search_regex("drone", body.id) or Function.search_regex("storage_box", body.id):
			setter = body
			print(self.name, " is able to set resources to ", body.name)
