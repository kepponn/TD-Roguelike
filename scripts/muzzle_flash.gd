extends Node3D

@onready var muzzle_flash = $MuzzleFlashGPUParticles

# Called every frame. 'delta' is the elapsed time since the previous frame.
func spawn_muzzle_flash():
	$MuzzleFlashGPUParticles.emitting = true
