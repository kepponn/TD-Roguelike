extends Node3D

@onready var spark = $Spark
@onready var fire = $Fire
@onready var smoke = $Smoke
@onready var explosion_sfx = $ExplosionSFX



func _ready():
	spark.emitting = true
	fire.emitting = true
	smoke.emitting = true
	explosion_sfx.play()

func _on_smoke_finished():
	queue_free()
