extends Area3D

var damage: int # the attack damage are inserted from 'turret_parent.gd'
var speed: int # the speed are inserted from 'turret_parent.gd'
var lifetime: float = 10 # timer for bullet life in second

var set_direction

func _ready():
	$Lifetime.start(lifetime)

func _process(delta):
	position += set_direction * speed * delta

func _on_body_entered(body):
	if body.has_method("hit"):
		body.hit(damage)
	else:
		queue_free()


func _on_lifetime_timeout():
	queue_free()

