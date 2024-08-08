extends StaticBody3D
class_name Ore_Parent

# ore_saltpetre + ore_sulphur = gun_powder (crafted in chemical station)
# ore_copper + ore_zinc = bullet_box (crafter in forge)

var id: String # this being set by child
var price: int # just in case this will be in shops

var type: String = "ingredients" # why have a type? so player didnt need to check for stupid shit

var local_requestor # being filled by player when interacting, what happen if 2 player interact the same time?
var is_collecting: bool = false # state if true then it progress the time
var collecting_time: float = 2.0 # in seconds
var progress_time: float = 0.0 # in seconds

func reset():
	is_collecting = false
	$ProgressBar3D.hide()
	$ProgressBar3D/SubViewport/ProgressBar2D.value = 0
	$Audio/Progress.stop()
	$Audio/Break.stop()
	local_requestor = null
	progress_time = 0.0

func _process(delta):
	if is_collecting:
		$ProgressBar3D.show()
		progress_time += delta # delta is basically adding time, see at the autoload/stats.gd
		$ProgressBar3D/SubViewport/ProgressBar2D.value = progress_time
		if !$Audio/Progress.playing:
			$Audio/Progress.play()
		if progress_time >= collecting_time:
			progress_time = collecting_time
			collect_completed()
		#print(self.id, " progress: ", int((progress_time / collecting_time) * 100), " %")
	if local_requestor != null and local_requestor.player_interactedItem_Temp != self:
		stop_collecting()

func start_collecting(requestor):
	$ProgressBar3D/SubViewport/ProgressBar2D.max_value = collecting_time
	local_requestor = requestor
	if not is_collecting:
		is_collecting = true
		#progress_time = 0.0 # do not reset the progress time for collecting
		#print(self.id, " collecting started")

func stop_collecting():
	if is_collecting:
		$Audio/Progress.stop()
		is_collecting = false
		#print(self.id, " collecting stopped with progress: ", progress_time / collecting_time)

func collect_completed():
	is_collecting = false
	$ProgressBar3D.hide()
	$ProgressBar3D/SubViewport/ProgressBar2D.value = 0
	$Audio/Progress.stop()
	$Audio/Break.play()
	take(local_requestor) # Assuming the requestor is the player scene
	local_requestor = null
	progress_time = 0.0
	#print(self.id, " ore collected!")

# take function being called by player
func take(requestor):
	match id:
		"ore_saltpetre":
			requestor.player_holdedMats = "ore_saltpetre"
		"ore_sulphur":
			requestor.player_holdedMats = "ore_sulphur"
		"ore_copper":
			requestor.player_holdedMats = "ore_copper"
		"ore_zinc":
			requestor.player_holdedMats = "ore_zinc"
	requestor.player_isHoldingItem = true
	requestor.player_checkIngredientItem()
	requestor.player_ableInteract = false
	print("Ore - Picked up ", requestor.player_holdedMats)
