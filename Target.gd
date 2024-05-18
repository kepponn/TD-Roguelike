extends Marker3D


# Called when the node enters the scene tree for the first time.
func _ready():
	$"../NavigationRegion3D".bake_navigation_mesh()
	Global.final_target = position
	print(Global.final_target)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Global.final_target = position
