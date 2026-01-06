extends Kinematic_Projectiles

var ParticleLeft = preload("res://Scenes/Triggers/FXs/Particles/GiantSlashBiteParticles_Left.tscn")
var ParticleRight = preload("res://Scenes/Triggers/FXs/Particles/GiantSlashBiteParticles_Right.tscn")

func _ready() -> void:
	
	if direction == -1:
		Triggers.create_ParticleTrigger(ParticleLeft, 
		$Center.global_position,
		Vector2i(1, 1),
		null,
		1.0)
		
	elif direction == 1:
		Triggers.create_ParticleTrigger(ParticleRight, 
		$Center.global_position,
		Vector2i(1, 1),
		null,
		1.0)
		
	#var Part_Inst = Particle.instantiate() as ParticleLogic
	#Part_Inst.global_position = $Center.global_position
	#Part_Inst.set_as_top_level(true)
	#Part_Inst.rotation_degrees = -180
	
	#LazerParticlesInstance.scale.x = direction
	
	$Slash.scale.x = direction
	$HitBox.body_entered.connect(slashbite_damage)
	$HitBox.body_exited.connect(exited_body)

func _physics_process(_delta: float) -> void:
	_Bullet_Behavior(direction)
	
	
func slashbite_damage(body: Node2D) -> void:
	
	if body != null:
		if is_instance_valid(body):
			if body.is_in_group("Enemies") or body is Enemy:
				body.hitted(Damage)
				GlobalEngine.change_gamespeed(0.1, 0.03)
				SpeedRatio = 0.4
				#Func inside enemie's script logic
			
			if body.call_deferred("is_in_group", "Enemies") or body is Enemy:
				while body.call_deferred("is_in_group", "Enemies") or body is Enemy:
						
					Triggers.create_ParticleTrigger(
					preload("res://Scenes/Triggers/FXs/Particles/3.tscn"), 
					body.global_position,
					Vector2i(-direction, 1),
					preload("res://tres/Materials/ShiningSparkles_Particles_directional.tres"),
					1.0)
					##TIMER##
					var timer_caseiro = Timer.new()
					TemporaryNodes.add_child(timer_caseiro)
					timer_caseiro.one_shot = true
					timer_caseiro.start(0.05)
					await timer_caseiro.timeout
					print("timer_caseiro from ", name ," is finished")
					timer_caseiro.queue_free()
					if is_instance_valid(body):
						if (not body.is_in_group("Enemies") and not body is Enemy) or $HitBox.get_overlapping_bodies().size() == 0:
							break
					else:
						break
func exited_body(body: Node2D) -> void:
	if body.is_in_group("Enemies") or body is Enemy:
		SpeedRatio = 1
	
