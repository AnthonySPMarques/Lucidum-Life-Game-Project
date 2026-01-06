###Attack PLUG:
##Makes the plugged body hurtable to a
##specific target
##example : Explosion from ElecPogo
extends Plugger
class_name AttackPlug

@export_category("Attack track")
@export
var Damage : float = 100.0
@export_range(0.000, 10.000)
var Invencibility_Given_To_Target :float= 0
@export
var Enable_Particles : bool = false
@export_range(0.000, 1.000)
var ParticleRatioAmount : float = 1.0
@export 
var Particule_material : ParticleProcessMaterial = preload("res://tres/Materials/ShiningSparkles_Particles_directional.tres")

#Node_getter
var Area_Attack : Area2D

func _ready() -> void:
	Area_Attack = Node_To_PlugIn
	Area_Attack.body_entered.connect(collided_enemy)
	
func collided_enemy(body: Node2D) -> void:
	#print(body)
	
	if body is Enemy:
		
		body.hitted(Damage, Invencibility_Given_To_Target)
		
		if Enable_Particles:
			#Fire particles# (soldador)
			if body.global_position.direction_to(Area_Attack.global_position).x < 0:
				Triggers.create_ParticleTrigger(
					preload("res://Scenes/Triggers/FXs/Particles/3.tscn"), 
					body.global_position,
					Vector2i(1, 1),
					Particule_material,
					ParticleRatioAmount)
			else:
				Triggers.create_ParticleTrigger(
					preload("res://Scenes/Triggers/FXs/Particles/3.tscn"), 
					body.global_position,
					Vector2i(-1, 1),
					Particule_material,
					ParticleRatioAmount)
		
	
