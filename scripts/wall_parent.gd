extends StaticBody3D
class_name Wall_Parent

@export_category("Basic Information")
# Do we need this still for the regex? or we using with StaticObject3D node name?
@export var id: String
var price: int

var mountable: bool
var spiked: bool

var attack_damage = null
var attack_speed = null

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

func ready_up():
	seed_property()
	$NeighbourWalls.show()
	%N.hide()
	%W.hide()
	%E.hide()
	%S.hide()

func _on_n_body_entered(body):
	if body.get_parent().name == 'Item' and body.is_class("StaticBody3D") and Function.search_regex("wall", body.id) or body.is_class("GridMap"):
		if self.get_parent().name == 'Item':
			#print("N show")
			%N.show()
func _on_w_body_entered(body):
	if body.get_parent().name == 'Item' and body.is_class("StaticBody3D") and Function.search_regex("wall", body.id) or body.is_class("GridMap"):
		if self.get_parent().name == 'Item':
			#print("W show")
			%W.show()
func _on_e_body_entered(body):
	if body.get_parent().name == 'Item' and body.is_class("StaticBody3D") and Function.search_regex("wall", body.id) or body.is_class("GridMap"):
		if self.get_parent().name == 'Item':
			#print("E show")
			%E.show()
func _on_s_body_entered(body):
	if body.get_parent().name == 'Item' and body.is_class("StaticBody3D") and Function.search_regex("wall", body.id) or body.is_class("GridMap"):
		if self.get_parent().name == 'Item':
			#print("S show")
			%S.show()

func _on_n_body_exited(_body):
	%N.hide()
func _on_w_body_exited(_body):
	%W.hide()
func _on_e_body_exited(_body):
	%E.hide()
func _on_s_body_exited(_body):
	%S.hide()
