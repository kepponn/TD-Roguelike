extends StaticBody3D

@onready var id = "shop"

func _process(_delta):
	pass

func _on_item_placeholder_body_entered(body):
	if body.name != "Shop" and !body.is_class("GridMap") and body.name != "Player":
		#print(body.name, " Entered")
		set_collision_layer_value(1,false)

func _on_item_placeholder_body_exited(body):
	if body.name != "Shop" and !body.is_class("GridMap") and body.name != "Player":
		set_collision_layer_value(1,true)
		#print(body.name, " Exited")

