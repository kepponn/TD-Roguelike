extends StaticBody3D

var enemies_inRange = []
var enemy_locked

@export var range:float

@onready var range_area: CollisionShape3D = $Range/CollisionShape3D
@onready var raycast: RayCast3D = $RayCast3D

# Called when the node enters the scene tree for the first time.
func _ready():
	range_area.shape.radius = range
	raycast.target_position.z = -range
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	lockon()
	

func lockon():
	#NOTES : Raycast are not infinitly long. it's length need to be change on Raycast3D -> Inspector -> Target Position
	#and it can be changed by code by using $RayCast3D.target_position
	#if there is enemy inside attack RANGE, turret will lock into the first enemy
	if enemies_inRange.size() != 0:
		enemy_locked = enemies_inRange[0]
		#lock raycast look at to the first enemy in the enemies_inRange array
		$RayCast3D.look_at(enemy_locked.position)
		#check if raycast colliding with any 3D bodies
		if $RayCast3D.is_colliding():
			#can save any data of the collided body, in this case we only want the parent name
			var collided = $RayCast3D.get_collider().get_parent().name
			#if collided's parent name is Enemies then it mean raycast able to hit enemies successfully and
			#not blocked by any 3D body, and then make turret's $Body to look at the locked enemy
			if collided == 'Enemies':
				$Head.look_at(enemy_locked.position)
				$RayCast3D.debug_shape_custom_color = Color(0,255,0)
			else:
				$RayCast3D.debug_shape_custom_color = Color(174,0,0)
	

func _on_range_body_entered(body):
	if body.get_parent().name == 'Enemies':
		enemies_inRange.append(body)

func _on_range_body_exited(body):
	if body.get_parent().name == 'Enemies':
		enemies_inRange.erase(body)
