extends Area3D

var req_id: String # which turret is requesting this projectile to spawn (being use in customization)

var damage: int # the attack damage are inserted from 'turret_parent.gd'
var speed: int # the speed are inserted from 'turret_parent.gd'
var lifetime: float = 10 # timer for bullet life in second

var pierce_counter: int
var ricochet_counter: int

var set_direction

var ricochet_targetList: Array

var ricochet_targetPrev
var ricochet_targetNext

func _ready():
	$Lifetime.start(lifetime)
	# Customization to create type of bullet, skip this if you want the default one
	match req_id:
		"turret_plasma":
			$OmniLight3D.light_color = Color("d282d6")
			$CollisionShape3D.scale = Vector3(3,1,3) # To easier hitting an enemies since this turret is static
			$MeshInstance3D.material_override = load("res://models/textures/projectile_plasma.tres")

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
			if ricochet_targetList.is_empty():
				queue_free()
			elif ricochet_targetList.size() > 0:
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
		print(body)
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

