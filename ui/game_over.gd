extends Control

func _ready():
	$Audio/BackgroundMusic.play()
	$Quit.grab_focus()
	$VBoxContainer/Time.text = "Time Elapse : " + str(Stats.time_elapsed)
	$VBoxContainer/Wave.text = "Wave : " + str(Stats.wave_cleared+1)
	$GridContainer/WaveCleared.text = ": " + str(Stats.wave_cleared)
	$GridContainer/TotalEnemyKilled.text = ": " + str(Stats.total_enemy_killed)
	$GridContainer/CurrencyGained.text = ": " + str(Stats.currency_gained)
	$GridContainer/CurrencyHighest.text = ": " + str(Stats.currency_highest_held)
	$GridContainer/ShopReroll.text = ": " + str(Stats.shop_reroll_used)
	$GridContainer/ShopRerollHighest.text = ": " + str(Stats.shop_highest_reroll)
	$GridContainer/TotalItemPurchased.text = ": " + str(Stats.total_item_purchased)
	$GridContainer/TurretPurchased.text = ": " + str(Stats.turret_purchased)
	$GridContainer/WallPurchased.text = ": " + str(Stats.wall_purchased)
	$GridContainer/LifeCrystalUsed.text = ": " + str(Stats.life_crystal_used)

func _on_quit_pressed():
	$Audio/Quit.play()

func _on_quit_audio_finished():
	get_tree().quit()
