extends Area3D

var damage: int # the attack damage are inserted from 'turret_parent.gd'
var speed: int # the speed are inserted from 'turret_parent.gd'
var lifetime: float = 5 # timer for bullet life in second

var pierce_counter: int
var ricochet_counter: int

var set_direction

var ricochet_targetList: Array

var ricochet_targetPrev
var ricochet_targetNext

func _ready():
	$Lifetime.start(lifetime)

func _process(delta):
	position += set_direction * speed * delta

func _on_body_entered(body):
	#Need IF to ignore turret body collision otherwise sometimes it will hit turret
	if body.has_method("hit"): # hit function exist in body
		if pierce_counter > 0: # pierce bullet hit
			pierce_counter -= 1
			# print("Piercing bullet, counter: " + str(pierce_counter))
			body.hit(damage)
		#ricochet still error if to-be ricocheted enemy died during ricochet process
		#because ricochet_targetList array only updated once while projectile spawned
		elif ricochet_counter > 0: # ricochet bullet hit (broken)
			#cannot ricochet to enemy outside of turret attack range
			ricochet_counter -= 1
			ricochet_targetList.erase(body)
			if ricochet_targetList.size() > 0:
				if ricochet_targetList[0] == null:
					ricochet_targetList.remove_at(0)
				set_direction = (ricochet_targetList[0].global_position - global_position).normalized()
			else:
				body.hit(damage)
				queue_free()
			body.hit(damage)
			#print("Ricochet bullet broken, check comment")
			# area3d have no bounce() function nor physics, so what? change the type of bullet into physics based
			# and apply area3d into its child? could work. but dont care rn
				
		else: # normal bullet hit
			body.hit(damage)
			queue_free()
	else: # hit function does not exist (hitting anything beside enemy)
		queue_free()
	
	# old commented code
	#if body.has_method("hit") and pierce_counter > 0:
		#pierce_counter -= 1
		#print("Piercing bullet, counter: " + str(pierce_counter))
		#body.hit(damage)
	#elif body.has_method("hit") and ricochet_counter > 0:
		#ricochet_counter -= 1
		#print("Ricochet bullet broken, check bounce() for physics")
		#body.hit(damage)
	#elif body.has_method("hit"):
		#body.hit(damage)
		#queue_free()
	#else:
		#queue_free()

func _on_lifetime_timeout():
	queue_free()

