extends Turret_Parent

@onready var plasma_charging_particles = $Models/Head/PlasmaChargingParticlesNode/PlasmaChargingParticles

# This turret using too much exception in the parent
# Using standalone function lock_on_static() which could be mash into lock_on()
# Using id check to bypass target_priority_check() since the aim static
# Need a new flow that check for aim/static turret type, but for now this will do

func _ready():
	ready_up()

func _process(_delta):
	if $AttackSpeed.time_left <= 1.0:
		plasma_charging_particles.emitting = false
	else:
		plasma_charging_particles.emitting = true
	start_process()
