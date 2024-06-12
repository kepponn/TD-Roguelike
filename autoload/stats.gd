extends Node

var time_elapsed: String = "00:00" #stats.gd
var time_elapsed_temp: float = 0.0 #stats.gd

var wave_cleared: int = 0 #player.gd under wave_cleared()
var total_enemy_killed: int = 0 #enemy_parent.gd under check_self()

var currency_gained: int = 0 #enemy_parent.gd under check_self()
var currency_highest_held: int = 0 #stats.gd

var life_crystal_used: int = 0 #enemy_parent.gd under _on_navigation_agent_3d_target_reached()

var shop_reroll_used: int = 0 #shop.gd under _on_reroll_button_pressed()
var shop_highest_reroll: int = 0 #shop.gd under _on_reroll_button_pressed()

var total_item_purchased: int = 0 #shop.gd under spawn_item(scene)
var turret_purchased: int = 0 #stats.gd
var wall_purchased: int = 0 #stats.gd

var total_item_destoryed: int = 0

func _process(delta):
	# Time in second based on delta, example: 24.288
	time_elapsed_temp += delta
	# Formatted time from temp with MM:SS (will expand to MMM:HH if exceed 99min)
	time_elapsed = format_time(time_elapsed_temp)
	
	if Global.currency > currency_highest_held:
		currency_highest_held = Global.currency

func format_time(seconds):
	var minutes = int(seconds) / 60
	var remaining_seconds = int(seconds) % 60
	return str(minutes).pad_zeros(2) + ":" + str(remaining_seconds).pad_zeros(2)

func enemy_killed(_enemy):
	total_enemy_killed += 1

func shop_purchased(item):
	total_item_purchased += 1
	if Function.search_regex("turret", item.id):
		turret_purchased += 1
	elif Function.search_regex("wall", item.id):
		wall_purchased += 1
