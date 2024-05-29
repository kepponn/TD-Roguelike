extends StaticBody3D
class_name Wall_Parent

@export_category("Basic Information")
# Do we need this still for the regex? or we using with StaticObject3D node name?
@export var id: String 
@export var price: int

@export var mountable: bool
@export var spiked: bool

func start_mountable():
	# check is mount area available (with area3d or maybe just var bool?)
		# set the hold item to mout area position
	# area is not available
		# swap the hold item with mount area item
	pass
	
func start_spiked():
	# check if enemy on area and not on cooldown
		# call hit function on enemy with static damage (1)
		# transform spike model with tween to Vector3(1.3, 1, 1.3) for feedback of hit
		# call timer for spike cooldown
	pass
