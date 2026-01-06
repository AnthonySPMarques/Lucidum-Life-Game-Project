extends StateMaker

#Exported Vars
@export_category("Velocity values")
@export var Jump_height : float = 1100.0 ##Força do pulo
@export var velocity_speed : float = 360.0 ##Velocidade do movimento
@export var Acceleration : float = 40.0 ##Força da aceleração de movimento
@export var Friction : float = 60.0 ##Força de atrito do movimento
@export var time_to_press_arrow_again : float = 0.2 ##Double tap dash
#export var Reduced_speed = 20

#Time that you have to press the left or right key again before go to idle state:
var TimerSlash
var TimerToPressArrowCounter = 1.0
var TriggerTimer = false

#Vars

var current_speed

#Store modified var
var friction : float
var acceleration : float

#func
func enter() -> void:
	#player.get_moving_platform = null
	super()
	if not player.is_impulsed_by_forces:
		friction = Friction
		acceleration = Acceleration
	else:
		friction = 0
		acceleration = Acceleration/8
		
	player.disable_snap_floor()
	
	if not player.impulsed_by_spring:
		player.velocity.y = -Jump_height
	else:
		"Velocity is applied already in flockos script"
		#player.velocity.y = 0 #Make the velocity plus properly the velocity impulse
		#player.velocity = player.Velocity_Impulse
		if player.Velocity_Impulse.x != 0:
			friction = 0
			acceleration = 0
			
	
	player.Pressed_Times_L = 0
	player.Pressed_Times_R = 0
	
	TriggerTimer = false
	
	
	#Give timer value:
	TimerToPressArrowCounter = time_to_press_arrow_again
	
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
		
func exit() -> void:
	player.enable_snap_floor()
	#avoiding coyote time works in jump state
	player.can_jump = false
	
	player.impulsed_by_spring = false
	
func physics_process(delta: float) -> StateMaker:
	
	#Give player movement values:
	velocity()
	player.velocity.y += (player.Gravity + 1600) * delta
	
	#Give a attack with the sword when going down
	if player.Has_Air_AttackDown:
		if Input.is_action_pressed("Down") and Input.is_action_just_pressed("Main_Attack_Input") \
		and not Input.is_action_pressed("Alt_Attack_Input"):
			return player.Current_Air_AttackDown
	
	####if not Input.is_action_pressed("Down"):
	if Input.is_action_just_pressed("Main_Attack_Input") and not Input.is_action_pressed("Dash") \
		and not Input.is_action_pressed("Alt_Attack_Input"):
			return player.AirSlashState
	
	if player.can_be_knockbacked():
		return player.KnockBackState

	if player.can_climb and not Input.is_action_pressed("Main_Attack_Input") and not Input.is_action_pressed("Jump"):
		if Input.is_action_pressed("Up") or Input.is_action_pressed("Down") and !player.is_on_floor():
			return player.ClimbState

	#Match conditions for airslash
	if Input.is_action_just_pressed("Dash") and (player.can_air_dash or 
	player.is_on_water) and not Input.is_action_pressed("Main_Attack_Input"): # and not player.reduce_velocity():
		return player.AirDashState
	
	#player.move_and_slide()
	#Skip corners in ceils
	if player.ceil_left_is_colliding():
		player.global_position.x += 5
	elif player.ceil_right_is_colliding():
		player.global_position.x -= 5

	#Give player movement values:
	if not player.is_on_floor():
		#Input for enter into airslash state
		
		if not player.is_on_floor():
			if (player.Left_raycast() and Input.is_action_pressed("Left")) or \
			(player.Left_raycast() and Input.is_action_pressed("Left")):
				if Input.is_action_just_pressed("Jump"):
					return player.WallJumpState
		
	
	
	#When player is falling
	if player.velocity.y > 0:
		return player.FallState
		
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
		if not player.is_impulsed_by_forces:
			player.velocity.x = 0

	
	
func input(_event: InputEvent) -> StateMaker:
	
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
	
	if player.Has_Air_AltAttack:
		if player.can_crazy_fly:
			if Input.is_action_pressed("Alt_Attack_Input"):
				return player.Current_Air_AltAttack
	return null
