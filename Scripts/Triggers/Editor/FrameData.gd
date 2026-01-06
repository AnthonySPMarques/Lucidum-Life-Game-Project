@icon("res://icon.png")
class_name FrameData extends Node2D

@export_category("Animation")
@export var Attack_Speed : float = 1.0

@export_category("Data")
@export var Damage_Force : float = 1.0
@export var Minimum_Damage_Chance : int = 1
@export var Maximum_Damage_Chance : int = 1
#@export var Snap_Damage_Range : float = 1.0
@export_range(0.000, 1.000) var ParticleRatioAmount : float = 1.0
@export var Particule_material : ParticleProcessMaterial = preload("res://tres/Materials/ShiningSparkles_Particles_directional.tres")
@export var SlowGame_Speed : float = 1.0
@export var SlowGame_Duration : float = 0.3

@export_category("Timers")
@export_range(0.000, 10.000) var Invencibility_Given_To_Enemy :float= 0 

@export_category("Bools")
@export var slow_when_clash : bool = false
@export var randomic_damage : bool = false

@export_category("NodePaths")
@export var AreaMask : Area2D = null

@onready var machine_state: Node = %Machine_State
@onready var animation_traveler: AnimationTree = %Animation_Traveler

@onready var flockos_parent: Flockos = $"../.."

var damageforce

func _ready() -> void:
	damageforce = Damage_Force
	if AreaMask != null:
		AreaMask.area_entered.connect(collided)
		AreaMask.add_to_group("Slashbite_Area")
	else:
		printerr(self.name, " has not a areamask assigned")
	
	#if get_child(0) is Area2D:
		#get_child(0).add_to_group("Meele_Hitbox")

func process_funtion() -> void:
	if %Machine_State.Default_State.is_in_group("SlashState"):
		animation_traveler["parameters/TimeScale/scale"] = Attack_Speed
	else:
		animation_traveler["parameters/TimeScale/scale"] = 1.0

func collided(area: Node2D) -> void:
	
	var body = area.get_parent().get_parent()
	print("area.owner ",area.owner)
	print("body ",body)
	
	if body is Enemy:
		var damage_applyed = 0
		
		if name == "AvoiderDown_FrameData":
			#If attack is avoiderdown increase damage based on falling speed
			damageforce += snappedf(GlobalEngine.flockos.velocity.y*0.002, 0.5)
			damage_applyed = damageforce
			print("da = ", damage_applyed)
		else:
			if randomic_damage:
				damage_applyed = randi_range(
					Minimum_Damage_Chance,
					Maximum_Damage_Chance)
			else:
				damage_applyed = damageforce
		
		if body.invencible == false:
			flockos_parent.SFX_attack_hit.play()
			get_parent().shot_timer = true
			get_parent().timer_caseiro = get_parent().time_to_fade_indicator_damage
			body.hitted(damage_applyed, Invencibility_Given_To_Enemy)
			
			
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
		
		if slow_when_clash:
			GlobalEngine.change_gamespeed(SlowGame_Speed, SlowGame_Duration)
		
		damageforce = Damage_Force
	if name == &"RunSlash_FrameData":
		flockos_parent.velocity.x *= 0.5
