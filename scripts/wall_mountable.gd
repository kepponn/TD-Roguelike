extends Wall_Parent

@onready var is_mountable: bool = true
@onready var is_mountable_occupied: bool = false
@onready var mountable_pos: Vector3 = Vector3(0, 1, 0)
@onready var currently_mountable_item

@onready var player = get_node('/root/Scene/Player')

var bonus_range = 1

func _ready():
	ready_up()

func mount(enable: bool):
	if enable and is_mountable:
		 # Filter on which item can be mounted
		if Function.search_regex("turret", player.player_interactedItem.id):
			currently_mountable_item = player.player_interactedItem
			print("Mounting "+str(currently_mountable_item)+" to "+str(self))
			# Basically player_putItem() + check_grid() function
			player.player_isHoldingItem = false
			player.player_placementPreview(false)
			currently_mountable_item.global_position = self.position + mountable_pos
			currently_mountable_item.global_rotation_degrees.y = round(currently_mountable_item.global_rotation_degrees.y / 90.0) * 90.0
			currently_mountable_item.reparent(self, true)
			currently_mountable_item.set_collision_layer_value(1, true)
			# Add modified range to currently mountable item
			#currently_mountable_item.update_range(1)
			currently_mountable_item.update_status("mounted", true, bonus_range)
			
			# Sets check property
			is_mountable = false
			is_mountable_occupied = true
		else:
			print("Check regex")
	if !enable and is_mountable_occupied:
		print("Taking "+str(currently_mountable_item)+" from "+str(self)+" to hand")
		player.player_isHoldingItem = true
		# Remove modified range to currently mountable item
		#currently_mountable_item.update_range(-1)
		currently_mountable_item.update_status("mounted", false)
		# Sets check property
		is_mountable = true
		is_mountable_occupied = false
		# Return item and set it to null
		player.player_interactedItem = currently_mountable_item
		player.player_holdItem(currently_mountable_item)
		currently_mountable_item = null
