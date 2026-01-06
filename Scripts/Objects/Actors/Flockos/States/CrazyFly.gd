@icon("res://Sprites/EditorTriggers/CrazyFlyIcon.png")
extends Slashs

@export_category("Velocity values")
@export var velocity_speed : float = 60

@export_category("Timers")
@export var time_adder : float = 0.1

var bounce_vector : Vector2

var x_direction = 1
var y_direction = 1

var is_adding_time : bool = false
var current_velocity : float = 0.0
var percent : float = 1.0

func enter() -> void:
	super()
	
	SoundEffects.play_sound(SoundEffects.SFX_CRAZYFLY_SAW)
	
	player.velocity *= 0
	TimerSlash = Attack_Duration
	TimerInput = Time_ToInput
	
	player.is_crazying_fly = true
	player.can_crazy_fly = false

	player.hitbox_mask.disabled = true
	
	current_velocity = velocity_speed
	
	player.is_immune = true
	%Hitbox.disable_hitboxes()
	
	#Set first velocity x movement when enter in crazyfly state
	if player.is_sprite_flipped == false:
		if not Input.is_action_pressed("Up"):
			bounce_vector = Vector2(current_velocity, current_velocity)
		else:
			bounce_vector = Vector2(current_velocity, -current_velocity)
	else:
		if not Input.is_action_pressed("Up"):
			bounce_vector = Vector2(-current_velocity, current_velocity)
		else:
			bounce_vector = Vector2(-current_velocity, -current_velocity)
	player.velocity = bounce_vector
	#Hitbox_Mask.disabled = false
	#Set default variables

func exit() -> void:
	player.impulsed_by_spring = false
	SoundEffects.stop_sound(SoundEffects.SFX_CRAZYFLY_SAW)
	
	player.is_immune = false
	
	player.velocity = Vector2.ZERO
	%Meele_Hitbox.disable_clash_areas()
	%Meele_Hitbox.disable_all_collision_shapes()
	
	player.is_crazying_fly = false
	player.can_crazy_fly = false
	player.hitbox_mask.disabled = false
	player.MeeleHitbox.is_persistent_mask_colliding = false
	
	#avoiding coyote time works in jump state
	#Hitbox_Mask.disabled = true


func physics_process(delta: float) -> StateMaker:
	
	TimerSlash = clamp(TimerSlash, 0, Attack_Duration)
	
	#Return to jump in spring:
	if player.impulsed_by_spring:
		player.velocity = player.Velocity_Impulse
		
	
	if player.Has_Air_AttackDown:
		if Input.is_action_just_pressed("Main_Attack_Input") and Input.is_action_pressed("Down") \
		and not Input.is_action_pressed("Alt_Attack_Input"):
			return player.Current_Air_AttackDown
	
	if player.is_small_area_on_water:
		"Create bubble particle"
		Triggers.create_ParticleTrigger(
		#Particle Scene
		preload("res://Scenes/Triggers/FXs/Particles/0.tscn"),
		#Particle Posiiton
		player.PivotCenter.global_position,
		#Particle Scale
		Vector2(player.sprite.scale.x, 1),
		#Particle Material
		preload("res://tres/Materials/WaterBubbleDeep.tres"),
		#Particle AmountRatio
		0.05);
		
	if player.can_be_knockbacked():
		return player.KnockBackState
	
	percent = clamp(percent, 0, velocity_speed*2)
	
	if %CrazyFly_Box.get_overlapping_bodies().size() > 0:
		TimerSlash = Attack_Duration
		#is_adding_time = true
		#increase_time(time_adder)
		#
		#if percent < (velocity_speed*2):
			#percent += 2.0 * delta
		#
		##Speed Fader
		#percent = lerp(percent, 0.50, 0.25)
#
	#else:
		#is_adding_time = false
		##Speed fader
		#percent = lerp(percent, 1.00, 0.25)

	#Countdown the timer
	if TimerSlash > 0 and is_adding_time == false:
		TimerSlash -= delta
	elif TimerSlash <= 0:
		if !player.is_on_floor():
			if self == player.CrazyFlyState:
				return player.FallState
			if self == player.DashCrazyFlyState:
				return player.DashFallState
		return player.IdleState

	if player.can_climb:
		if Input.is_action_pressed("Up") or Input.is_action_pressed("Down") and !player.is_on_floor():
			return player.ClimbState
	
	#apply movement
	var info_collision = player.move_and_collide(bounce_vector * delta * percent)
	
	if info_collision:
		bounce_vector = bounce_vector.bounce(info_collision.get_normal())
		player.velocity = bounce_vector


	return null

func increase_time(time: float) -> void:
	TimerSlash += time
	TimerSlash = clamp(TimerSlash,0 ,Attack_Duration)
