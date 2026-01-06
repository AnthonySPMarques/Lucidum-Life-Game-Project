extends StateMaker

@export_category("Velocity values")
@export var Jump_height : float = 100.0
@export var velocity_speed : float = 60.0
@export var Acceleration : float = 0.0
@export var Friction : float = 0.0

#var cansl = true #Variable to brake the instant air slash input
#Store modified var
var friction : float
var acceleration : float

func enter() -> void:
	super()
	
	if not player.is_impulsed_by_forces:
		friction = Friction
		acceleration = Acceleration
	else:
		friction = 0
		acceleration = Acceleration/8
	
	player.disable_snap_floor()
	
	##JUMP##
	if not player.impulsed_by_spring:
		player.velocity.y = -Jump_height
	else:
		player.velocity = player.Velocity_Impulse
		if player.Velocity_Impulse.x != 0:
			friction /= 0
			acceleration /= 0
		
	
	#SFX
	if player.impulsed_by_spring:
		if Input.is_action_pressed("Jump"):
			SoundEffects.play_sound(SoundEffects.SFX_BOING)
			SoundEffects.play_sound(SoundEffects.SFX_SPRINGVOCALED)
		else:
			SoundEffects.play_sound(SoundEffects.SFX_BOING)
	else:
		if !player.is_on_water:
			SoundEffects.play_sound(SoundEffects.SFX_JUMP)
		else:
			SoundEffects.play_sound(SoundEffects.SFX_WATERSWING)
	
	%Meele_Hitbox.disable_clash_areas()
	
	if Input.is_action_pressed("Dash") or Input.is_action_just_pressed("Dash"):
		%Trail.can_trail = true
	
	
	%Trail.can_trail = true
	
	%PivotTrail.position = Vector2.ZERO
	
	if player.is_immune == false:
		%Hitbox.enable_DefaultHitbox()

	
	
func exit() -> void:
	player.enable_snap_floor()
	
	#Reset jump increaser
	player.impulsed_by_spring = false
	
	#avoiding coyote time works in jump state
	player.can_jump = false
func input(_event: InputEvent) -> StateMaker:
	
	if player.Has_Air_AttackDown:
		if Input.is_action_just_pressed("Main_Attack_Input") and Input.is_action_pressed("Down") \
		and not Input.is_action_pressed("Alt_Attack_Input"):
			return player.Current_Air_AttackDown
	
	if not Input.is_action_pressed("Down") and \
	Input.is_action_just_pressed("Special") \
	and player.MeeleHitbox.is_slash_charged:
		return player.ChargedSlashState
	
	if not player.impulsed_by_spring:
		if (Input.is_action_just_released("Jump") or
		!Input.is_action_pressed("Jump")) and player.velocity.y < 0:
			player.velocity.y *= 0.5
	
	if Input.is_action_just_pressed("Jump") and player.is_on_water:
		return self
	
	if Input.is_action_just_pressed("Dash"):
		return player.AirDashState

	return null
func process(_delta: float) -> StateMaker:
	
	#behavior with lower frame update
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
	
	return null
	
func physics_process(delta: float) -> StateMaker:	
	
	#Give player movement values:
	velocity()
	player.velocity.y += (player.Gravity + 1600) * delta
	#if cansl:
	if Input.is_action_just_pressed("Main_Attack_Input")\
		and not Input.is_action_pressed("Alt_Attack_Input")\
			and not Input.is_action_just_pressed("Down"):
				return player.AirSlashDashState
			
	#if Input.is_action_just_pressed("Main_Attack_Input") and not Input.is_action_pressed("Dash") \
		#and not Input.is_action_pressed("Alt_Attack_Input") and not Input.is_action_just_pressed("Down"):
			#return player.AirSlashDashState
			
			
	if player.can_be_knockbacked():
		return player.KnockBackState
		
		
	##Cancel jump force##
	if not player.impulsed_by_spring:
		if !Input.is_action_pressed("Jump") and player.velocity.y < 0:
			player.velocity.y *= 0.7
	
	if player.is_immune == false:
		%Hitbox.enable_DefaultHitbox()
	
	#if player.can_air_dash:
		#if (player.Pressed_Times_L == 2 or player.Pressed_Times_R == 2) and player.velocity.x != 0:
			#return player.AirDashState
	
	
	if not player.is_on_floor():
		#Input for enter into airslash state
		####if not Input.is_action_pressed("Down"):
	
		if not player.is_on_floor():
			if (player.Left_raycast() and Input.is_action_pressed("Left")) or \
			(player.Left_raycast() and Input.is_action_pressed("Left")):
				if Input.is_action_just_pressed("Jump"):
					return player.WallJumpState
	

	if player.Has_Air_AltAttack:
		if Input.is_action_pressed("Alt_Attack_Input") and player.can_crazy_fly:
			return player.Current_DashAir_AltAttack

	if player.can_climb:
		if Input.is_action_pressed("Up") or Input.is_action_pressed("Down") and !player.is_on_floor():
			return player.ClimbState

#	if player.velocity.x > 0:
#		player.sprite.flip_h = false
#	elif player.velocity.x < 0:
#		player.sprite.flip_h = true

	if player.ceil_left_is_colliding():
		player.global_position.x += 5
	elif player.ceil_right_is_colliding():
		player.global_position.x -= 5

			
	#player.set_floor_stop_on_slope_enabled(true)
	#player.move_and_slide()

	#return for dashfall
	if player.velocity.y > 0:
		return player.DashFallState

#	if player.is_on_floor():
#		if player.velocity.x != 0:
#			return WalkState
#		else:
#			return IdleState

	return null

func velocity() -> void:
	
	#Input
	var is_left = Input.is_action_pressed("Left") and !Input.is_action_pressed("Right")
	var is_right = Input.is_action_pressed("Right") and !Input.is_action_pressed("Left")
	
	if not (Input.is_action_pressed("Left") and player.WallfloorLeft_raycast()) and \
		not (Input.is_action_pressed("Right") and player.WallfloorRight_raycast()):
		if is_right:
				player.velocity.x = min(player.velocity.x + acceleration, velocity_speed + player.Velocity_Impulse.x)

		elif is_left:
			player.velocity.x = max(player.velocity.x - acceleration, -velocity_speed - player.Velocity_Impulse.x)

		else:
			#Friction:
			if player.velocity.x > 0:
				player.velocity.x = max(player.velocity.x - friction, 0)

			if player.velocity.x < 0:
				player.velocity.x = min(player.velocity.x + friction, 0)
	else:
		player.velocity.x = 0
	
	if not Input.is_action_pressed("Left") and not Input.is_action_pressed("Right"):
		#Friction:
		if player.velocity.x > 0:
			player.velocity.x = max(player.velocity.x - friction, 0)
		if player.velocity.x < 0:
			player.velocity.x = min(player.velocity.x + friction, 0)
		
