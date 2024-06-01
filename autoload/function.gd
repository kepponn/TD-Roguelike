extends Node

func search_regex(search_name: String, search_to):
	var regex = RegEx.new()
	regex.compile(r"^(?i)"+search_name+".*$")
	var object = regex.search(search_to)
	return object
