extends Turret_Parent

@onready var plasma_charging_particles = $Models/Head/PlasmaChargingParticlesNode/PlasmaChargingParticles



func _ready():
	ready_up()

func _process(_delta):
	if $AttackSpeed.time_left <= 1.0:
		plasma_charging_particles.emitting = false
	else:
		plasma_charging_particles.emitting = true
	start_process()
