extends Label

func _ready():
	self.hide()

func _process(_delta):
	if Global.is_pathReachable:
		self.hide()
	else:
		self.show()
