extends StaticBody3D

var id = "extra_health"
var price

func _ready():
	seed_property()
	Global.life_array.append(self)
	
func _process(delta):
	$Models/heart.rotation_degrees.y += 60 * delta

func destroy():
	Global.life_array.erase(self)
	queue_free()

func seed_property():
	var file = FileAccess.open("res://autoload/item_db.json", FileAccess.READ)
	var file_text = file.get_as_text()
	file.close()
	# Parse JSON data to be easily modified by for loops
	var data = JSON.parse_string(file_text)
	# Check if the id exist in JSON data
	if data.has(id):
		var item_data = data[id]
		for property in item_data:
			self.set(property, item_data[property])
