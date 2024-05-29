extends StaticBody3D

#var regex = RegEx.new()
#var pattern = r"^(?i)turret.*$"

#func _ready():
	#regex.compile(pattern)

func _process(_delta):
	pass

#func collision(enable: bool):
	#match enable:
		#true:
			#$CollisionShape3D.disabled = true
		#false:
			#$CollisionShape3D.disabled = false

func _on_item_placeholder_body_entered(body):
	if body.name != "Shop" and !body.is_class("GridMap") and body.name != "Player":
		print(body.name, " Entered")
		set_collision_layer_value(1,false)

func _on_item_placeholder_body_exited(body):
	if body.name != "Shop" and !body.is_class("GridMap") and body.name != "Player":
		set_collision_layer_value(1,true)
		print(body.name, " Exited")

