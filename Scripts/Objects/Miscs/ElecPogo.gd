class_name ElecPogo
extends CharacterBody2D

@export var explosion_scale : Vector2 = Vector2.ONE
@export var explosion_damage : float = 1.0
@export_range(0.000, 10.000) var Invencibility_Given_To_Enemy :float= 0 
@export_range(0.000, 1.000) var ParticleRatioAmount : float = 1.0
@export var Particule_material : ParticleProcessMaterial = preload("res://tres/Materials/ShiningSparkles_Particles_directional.tres")
@export var pow_velocity : float = 1200.0
@export var Let_it_be_deleted_outside_viewport : bool = true

var was_trown : bool = false

@onready var elec_pogo_area: Area2D = %ElecPogoArea

func _ready() -> void:
	elec_pogo_area.body_entered.connect(kill)
	elec_pogo_area.body_entered.connect(collided_enemy)
	
func _physics_process(_delta: float) -> void:
	move_and_slide()
	
func _process(_delta: float) -> void:
	#Enable hitbox to hurt enemie only if pogo is trowned
	%ElecPogoArea.set_collision_mask_value(6, was_trown)
	
	if is_on_floor() and was_trown:
		Triggers.create_RigidVisualEffectTrigger(3, global_position - Vector2(0, 8), explosion_scale)
		call_deferred("queue_free")
	
func kill(body: Node2D) -> void:
	if was_trown and body is Enemy:
		Triggers.create_RigidVisualEffectTrigger(3, global_position - Vector2(0, 8), explosion_scale)
		call_deferred("queue_free")

func collided_enemy(body: Node2D) -> void:
	if body is Enemy:
		
		body.hitted(explosion_damage, Invencibility_Given_To_Enemy)
			
		#Fire particles# (soldador)
		if body.global_position.direction_to(global_position).x < 0:
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
	
func pow_ground() -> void:
	velocity.y += pow_velocity
	was_trown = true
	
func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	if Let_it_be_deleted_outside_viewport:
		call_deferred("queue_free")
