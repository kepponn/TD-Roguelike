extends Area3D

@export var damage: int = 1
@export var speed: float

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
	
