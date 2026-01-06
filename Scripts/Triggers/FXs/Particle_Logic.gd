class_name ParticleLogic extends GPUParticles2D

@export var auto_set_oneshot : bool = true
@export var auto_emit : bool = true

func _enter_tree() -> void:
	emitting = auto_emit
	if name != "Aura_Orbs": #Avoid to emit when intro state
		restart()
	
func _ready() -> void:
	if name != "Aura_Orbs":
		restart()
	
	#prints("my name is", name, "and I am in", global_position)
	
	if GameSettings.ConfigurationManager.GameplaySettings.Game_Configurations_Dictionary.Disable_Particles:
		emitting = false
		kill()
	
	else:
		#Bug de merda
		if auto_set_oneshot == true:
			one_shot = true
		if not finished.is_connected(kill):
			finished.connect(kill)
	
func kill() -> void:
	#print("killed")
	call_deferred("queue_free")
