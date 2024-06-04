extends Marker3D

# Love letter from debugger <3
# Fixed by changing the requirement of 'cell_size' in Project > Navigation > 3D
# But did nothing new to existing navigation pathing what so ever, classic debugger
# modules/navigation/nav_region.cpp:128 - Navigation map synchronization error. 
# Attempted to update a navigation region with a navigation mesh that uses a `cell_size` of 0.10000000149012 
# while assigned to a navigation map set to a `cell_size` of 0.25. 
# The cell size for navigation maps can be changed by using the NavigationServer map_set_cell_size() function. 
# The cell size for default navigation maps can also be changed in the ProjectSettings.

# You could either bake the navigation from $"../NavigationRegion3D" or $"../NavigationRegion3D/Environtment"?

func _ready():
	# Would this be dynamic in the future? if so then the process flow is: (just-in-case)
	# Check for changes and signal it back to here to do bake process and reroute the nav-process into new location target
	# How? just call this_node._ready() and nav_node._ready()
	
	#$"../NavigationRegion3D".bake_navigation_mesh()
	
	Global.final_target = position
	#print("Current target position: " + str(Global.final_target))
	
func _process(_delta):
	$Models/Orb.rotation_degrees.y += 1
