extends Button

var item_price: int
var item_name: String

# Called when the node enters the scene tree for the first time.
func _ready():
	$MarginContainer/HBoxContainer/TextureRect/Price.text = str(item_price) + " Gold"
	#$MarginContainer/HBoxContainer/TextureRect.texture.load("res://.godot/imported/buttons.png-e7056a10076d4ac74fa23b5d0ee8fab6.ctex")
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(_delta):
	update_modulate()

func update_modulate():
	if disabled == true:
		modulate = Color("#636363")
	else:
		modulate = Color("#ffffff")

