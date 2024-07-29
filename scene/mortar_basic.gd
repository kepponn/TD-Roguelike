extends Mortar_Parent


# Called when the node enters the scene tree for the first time.
func _ready():
	ready_up()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	start_process(delta)
