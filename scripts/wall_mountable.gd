extends Wall_Parent

@onready var currently_mountable_item # This variable hold turret
@onready var is_mountable_occupied: bool = false # This is checker
@onready var mountable_pos: Vector3 = Vector3(0, 1, 0)

var bonus_range = 1

func _ready():
	ready_up()

func mount(requestor, item, enable: bool): # enable means mounting, disable mean de-mounting
	match enable:
		true: # Mounting
			if !is_mountable_occupied:
				if Function.search_regex("turret", item.id): # Filter on which item can be mounted
					currently_mountable_item = item
					# Check the requestor and clean/set them accordingly
					check_requestor(requestor)
					# Setting item property to fit mountable position
					currently_mountable_item.global_position = self.position + mountable_pos
					currently_mountable_item.global_rotation_degrees.y = round(currently_mountable_item.global_rotation_degrees.y / 90.0) * 90.0
					currently_mountable_item.reparent(self, true)
					currently_mountable_item.set_collision_layer_value(1, true)
					# Add modified range to currently mountable item
					currently_mountable_item.update_status("mounted", true, bonus_range)
					# Sets check property
					is_mountable_occupied = true
					print("Wall Mountable - Mounting "+str(currently_mountable_item)+" to "+str(self))
		false: # De-mounting
			if is_mountable_occupied:
				# Remove modified range to currently mountable item (or the buff will still be there)
				currently_mountable_item.update_status("mounted", false)
				# Check the requestor and clean/set them accordingly
				check_requestor(requestor)
				# Sets check property and flush
				is_mountable_occupied = false
				currently_mountable_item = null
				print("Wall Mountable - Taking "+str(currently_mountable_item)+" from "+str(self)+" to hand")

func check_requestor(requestor):
	if Function.search_regex("player", requestor.id):
		match is_mountable_occupied:
			false: # Run in mounting function
				requestor.player_isHoldingItem = false # cleaning
				requestor.player_placementPreview(false) # cleaning
				requestor.player_interactedItem = null # cleaning bcs player isnt holding anything anymore
			true: # Run in de-mount function
				requestor.player_isHoldingItem = true # return item
				requestor.player_interactedItem = currently_mountable_item # return item
				requestor.player_holdItem(currently_mountable_item) # return item
#
#func mount(enable: bool):
	#if enable and is_mountable:
		 ## Filter on which item can be mounted
		#if Function.search_regex("turret", player.player_interactedItem.id):
			#currently_mountable_item = player.player_interactedItem
			#print("Mounting "+str(currently_mountable_item)+" to "+str(self))
			## Basically player_putItem() + check_grid() function
			#player.player_isHoldingItem = false
			#player.player_placementPreview(false)
			#currently_mountable_item.global_position = self.position + mountable_pos
			#currently_mountable_item.global_rotation_degrees.y = round(currently_mountable_item.global_rotation_degrees.y / 90.0) * 90.0
			#currently_mountable_item.reparent(self, true)
			#currently_mountable_item.set_collision_layer_value(1, true)
			## Add modified range to currently mountable item
			##currently_mountable_item.update_range(1)
			#currently_mountable_item.update_status("mounted", true, bonus_range)
			#
			## Sets check property
			#is_mountable = false
			#is_mountable_occupied = true
		#else:
			#print("Check regex")
	#if !enable and is_mountable_occupied:
		#print("Taking "+str(currently_mountable_item)+" from "+str(self)+" to hand")
		#player.player_isHoldingItem = true
		## Remove modified range to currently mountable item
		##currently_mountable_item.update_range(-1)
		#currently_mountable_item.update_status("mounted", false)
		## Sets check property
		#is_mountable = true
		#is_mountable_occupied = false
		## Return item and set it to null
		#player.player_interactedItem = currently_mountable_item
		#player.player_holdItem(currently_mountable_item)
		#currently_mountable_item = null
