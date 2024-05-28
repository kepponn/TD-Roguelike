extends StaticBody3D

var regex = RegEx.new()
var pattern = r"^(?i)turret.*$"

func _ready():
	regex.compile(pattern)

func _process(_delta):
	pass

func collision(enable: bool):
	match enable:
		true:
			$CollisionShape3D.disabled = true
		false:
			$CollisionShape3D.disabled = false

func _on_item_placeholder_body_entered(body):
	if body.is_class("StaticBody3D") and body.get_parent().name == 'Item' and regex.search(body.name) != null:
		#set_collision_layer_value(1, false)
		print("col off omg so good")

#func _on_item_placeholder_body_exited(body):
	#print(body)
	#set_collision_layer_value(1, true)
	#print("col on")
