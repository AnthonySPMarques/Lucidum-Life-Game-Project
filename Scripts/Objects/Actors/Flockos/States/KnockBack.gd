extends StateMaker

@export_category("Velocity_Values")
@export var aditional_gravity = 20
@export var KnockBack_X = 0
@export var KnockBack_Y = 0

@export_category("Timers")
@export var KnockBack_Time : float = 0.0

#var KnockBack : Vector2
var CurrentTimer
var time_to : float

func enter() -> void:
	super()
	
	if player.is_on_floor() and (%DownCeilRay_Left.is_colliding() or 
	%DownCeilRay_Right.is_colliding()):
		Ducking_State = true
		
	player.Hitted = true
	%FlashHitTree["parameters/playback"].travel("Knockback")
	
	%FlashHitTree["parameters/conditions/Awaken_Isnt_Full"] = false
	%FlashHitTree["parameters/conditions/Is_Not_Lighted"] = false
	%FlashHitTree["parameters/conditions/Is_Lighted"] = true
	
	SoundEffects.play_sound(SoundEffects.SFX_KNOCKBACK)
	SoundEffects.play_sound(SoundEffects.SFX_MEOW_HURT)
	
	%Trail.can_trail = false
	
	%Meele_Hitbox.disable_all_collision_shapes()
	%Meele_Hitbox.disable_clash_areas()
	
	time_to = 2.0
	
	player.is_immune = true
	player.is_wet = false
	
	GlobalEngine.change_gamespeed(0.5, 0.2)
	
	#KnockBack = Vector2(KnockBack_X, KnockBack_Y)
	
	if not (%DownCeilRay_Left.is_colliding() or 
	%DownCeilRay_Right.is_colliding()):
		player.velocity.y = -KnockBack_Y
	else:
		player.velocity = Vector2.ZERO
	#Set hit to false

	

	#Set current time of knockback, not the same time of invencibility
	CurrentTimer = KnockBack_Time
	
	#Play the shader of the hit
	#The mask is toggling from there
	
	
	player.can_flip = false
	
func exit() -> void:
	super()
	Ducking_State = false
			
	%Meele_Hitbox.disable_clash_areas()
	
	player.velocity = Vector2.ZERO
	player.can_flip = true
	
func process(_delta: float) -> StateMaker:
	if player.is_dead:
		return player.DeathState
	return null
	
func physics_process(delta: float) -> StateMaker:
	
	#Return to jump in spring:
	if player.impulsed_by_spring:
		player.velocity = player.Velocity_Impulse
		
	
	if not (%DownCeilRay_Left.is_colliding() or 
	%DownCeilRay_Right.is_colliding()):
		%FlashHitTree["parameters/playback"].travel("Knockback")
	
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
		0.02);
	
	if player.is_dead:
		return player.DeathState
	
	else:
		if time_to > 2.0:
			time_to -= delta
		else:
			player.Hitted = false
			time_to = 0
			
		player.is_sprite_flipped = !player.velocity.x < 0
		
		#knockback direction
		
		if not (%DownCeilRay_Left.is_colliding() or 
		%DownCeilRay_Right.is_colliding()):
			if player.hurt_direction != null:
				if player.hurt_direction > 0:
					player.velocity.x = -KnockBack_X
				else:
					player.velocity.x = KnockBack_X

		if not player.is_on_floor():
			player.velocity.y += (player.Gravity + aditional_gravity) * delta
			
		#Timer
		if not CurrentTimer < 0:
			CurrentTimer -= delta
		else:
			if player.is_on_floor():
				if (%DownCeilRay_Left.is_colliding() or 
				%DownCeilRay_Right.is_colliding()):
					return player.DownState
				else:
					return player.IdleState
			else:
				return player.FallState
				
		return null
	

	
	
