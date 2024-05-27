extends Area3D

var damage: int # the attack damage are inserted from 'turret_parent.gd'
var speed: float = 5

var set_direction

func _ready():
	pass

func _process(delta):
	position += set_direction * speed * delta

func _on_body_entered(body):
	#print(body.name)
	#Need IF to ignore turret body collision otherwise sometimes it will hit turret
	if body.has_method("hit"):
		body.hit(damage)
		queue_free()
	else:
		queue_free()
	
