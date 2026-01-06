@icon("res://Sprites/EditorTriggers/LightingKipeIcon.png")
extends Slashs

@export_category("Velocity_Values")
@export var impulsed_gravity : float = 1.1
@export var Jump_Height : float = 100

var brake_jump : bool = false

var is_animation_finished : bool = false

func enter() -> void:
	super()
	SoundEffects.play_sound(SoundEffects.SFX_LIGHTINGKITE)
	
	if player.is_immune == false:
		%Hitbox.enable_DefaultHitbox()
	
	#Restar trail position
	%PivotTrail.position = Vector2.ZERO
	
	%Trail.can_trail = true
	
	"Setters"
	
	
	player.can_flip = false
	
	TimerSlash = Attack_Duration
	player.velocity.x = 0
	%Hitbox.disable_hitboxes()
	#Hitbox_Mask.disabled = false

func exit() -> void:
	
	$"%Meele_Hitbox".disable_clash_areas()
	player.velocity.y = 0
	
	brake_jump = false
	player.can_flip = true
	#avoiding coyote time works in jump state
	%Hitbox.enable_DefaultHitbox()
	#Hitbox_Mask.disabled = true
	player.can_jump = false
	player.can_air_slash = false
	player.MeeleHitbox.is_persistent_mask_colliding = false
	is_animation_finished = false
	
func flyjump() -> void:
	player.velocity.y = -Jump_Height
	
	
func endjump() -> void:
	brake_jump = true

func physics_process(delta: float) -> StateMaker:
	
	if player.can_be_knockbacked():
		return player.KnockBackState
	
	if player.is_immune == false:
		%Hitbox.enable_DefaultHitbox()
	
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
		preload("res://tres/Materials/WaterBubbleDeepBlown.tres"),
		#Particle AmountRatio
		0.05);
	
		
	#Countdown the timer
	if is_animation_finished:
		if not Input.is_action_pressed("Dash"):
			return player.FallState
		else:
			return player.DashFallState
	
	if player.is_on_ceiling():
		player.velocity.y = 0
	else:
		player.velocity.y += player.Gravity * delta * impulsed_gravity
		
#	#Fade out jump
	if brake_jump:
		player.velocity.y *= 0.9
		if player.velocity.y > 0:
			player.velocity.y = 0
	
	

	if player.Has_Air_AttackDown:
		if Input.is_action_just_pressed("Main_Attack_Input") and Input.is_action_pressed("Down") \
		and not Input.is_action_pressed("Alt_Attack_Input"):
			return player.Current_Air_AttackDown

	if player.can_climb:
		if Input.is_action_pressed("Up") or Input.is_action_pressed("Down") and !player.is_on_floor():
			return player.ClimbState

	if player.ceil_left_is_colliding():
		player.global_position.x += 5
	elif player.ceil_right_is_colliding():
		player.global_position.x -= 5


	return null

func input(_event) -> StateMaker:
	if player.Has_DashAttack:
		if Input.is_action_pressed("Dash") and Input.is_action_pressed("Main_Attack_Input"):
			return player.Current_DashAttack
	return null

func set_animation_to_finished() -> void:
	is_animation_finished = true
