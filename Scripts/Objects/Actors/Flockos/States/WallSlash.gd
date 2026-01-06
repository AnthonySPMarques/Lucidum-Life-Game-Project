extends Slashs

@export var Gravity_Divider : float = 0.5
var is_animation_finished : bool = false

func enter() -> void:
	super()
	
	%Hitbox.enable_WallHitbox()
	
	if player.is_small_area_on_water:
		"Create bubble particle"
		Triggers.create_ParticleTrigger(
		#Particle Scene
		preload("res://Scenes/Triggers/FXs/Particles/0.tscn"),
		#Particle Posiiton
		player.PivotCenter.global_position + Vector2(-32*player.sprite.scale.x, 0),
		#Particle Scale
		Vector2(-player.sprite.scale.x, 1),
		#Particle Material
		preload("res://tres/Materials/WaterBubbleDeepBlown.tres"),
		#Particle AmountRatio
		1.0);
	
	%Animation_Traveler.get("parameters/WallSlide/playback").travel("WallSlash")
	
	TimerSlash = Attack_Duration
	player.can_flip = false
	#Hitbox_Mask.disabled = false

func play_sound() -> void:
	SoundEffects.play_sound(SoundEffects.SFX_SLASHBITE)

func exit() -> void:
	is_animation_finished = false
	player.can_flip = true
	%Meele_Hitbox.disable_clash_areas()
	%Meele_Hitbox.disable_all_collision_shapes()
	#Hitbox_Mask.disabled = true

func process(_delta: float) -> StateMaker:
	if player.can_be_knockbacked():
		return player.KnockBackState
	return null

func physics_process(delta: float) -> StateMaker:
	
	#Return to jump in spring:
	if player.impulsed_by_spring:
		player.velocity = player.Velocity_Impulse
		
	
	if player.is_immune == false:
		%Hitbox.enable_WallHitbox()
	
	if player.is_on_floor(): #player.prefloor_colliding():
		return player.IdleState
	
	if Input.is_action_just_pressed("Jump"):
		return player.WallJumpState
	
	#Apply Gravity
	if not Input.is_action_pressed("Up"):
		player.velocity.y = player.Gravity / Gravity_Divider * delta
	else:
		player.velocity.y = 0

	#Countdown the timer
	if is_animation_finished:
		return player.WallSlideState
	return null

func set_animation_to_finished() -> void:
	is_animation_finished = true
