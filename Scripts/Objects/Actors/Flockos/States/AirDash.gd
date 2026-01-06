extends StateMaker

#Values
@export_category("Timer")
@export var DashTime = 0.4

@export_category("Velocity values")
@export var velocity_speed : float = 600.0 ##Velocidade do movimento
@export var Acceleration : float = 225.0 ##Força da aceleração de movimento
@export var Friction : float = 50.0 ##Força de atrito do movimento

var Actual_Dash_Time : float = 0
var Direction_Dash: int = 1

var input_released = false
var side_can_release = false

var acceleration : float
var friction : float

# Upon entering the state, set dash direction to either current input or the direction the player is facing if no input is pressed
func enter() -> void:
	super()
	
	if not player.is_impulsed_by_forces:
		friction = Friction
		acceleration = Acceleration
	else:
		friction = 0
		acceleration = Acceleration/8
	%Trail.can_trail = true
	if player.is_small_area_on_water:
		player.AnimationTraveler["parameters/Current_Animation_State/transition_request"] = "WaterDash"
		SoundEffects.play_sound(SoundEffects.SFX_WATERSWING)
	
	if player.is_on_water == false:
		SoundEffects.play_sound(SoundEffects.SFX_DASH)
		player.AnimationTraveler.set("parameters/Dashing_On_Water/current", 1)
	else:
		player.AnimationTraveler.set("parameters/Dashing_On_Water/current", 0)
	
	#air dash
	player.velocity.y = 0
	input_released = false
	
	#if player.Pressed_Times_L == 2 or player.Pressed_Times_R == 2:
	#	side_can_release = true
	
	Actual_Dash_Time = DashTime
	if player.is_sprite_flipped:
		Direction_Dash = -1
	else:
		Direction_Dash = 1
		
	#Enable dash box
	if player.is_immune == false:
		%Hitbox.enable_DashHitbox()
		
	#"eletric smoke dash"
	Triggers.create_VisualEffectTrigger(7, 
	%Pivot.global_position, 
	Vector2(%FlockosSprite.scale.x, 1))

		
		
func exit() -> void:
	
	#%Mask.disabled = false
	#%MaskDown.disabled = true
	
	#Restar trail position
	%PivotTrail.position = Vector2.ZERO
	
	player.can_air_dash = false
	player.can_jump = false
	player.AnimationTraveler.set("parameters/Is_Dashing/current",
	1)
	#Disaable Down Mask
	#player.Pressed_Times_L = 0 
	#player.Pressed_Times_R = 0
	side_can_release = false
	
	
	if player.is_immune == false:
		player.hitbox_mask.disabled = false
		player.hitbox_down_mask.disabled = true
	
func input(_event: InputEvent) -> StateMaker:
	
	if Input.is_action_just_released("Dash") or Input.is_action_just_pressed("Alt_Attack_Input"):
		#%Mask.disabled = false
		#%MaskDown.disabled = true
		return player.DashFallState

	if player.Has_DashAttack:
		if Input.is_action_just_pressed("Main_Attack_Input"):
			#%Mask.disabled = false
			#%MaskDown.disabled = true
			return player.Current_DashAttack

	if player.Has_Air_AttackDown:
		if Input.is_action_just_pressed("Main_Attack_Input") and Input.is_action_pressed("Down") \
		and not Input.is_action_pressed("Alt_Attack_Input"):
			#%Mask.disabled = false
			#%MaskDown.disabled = true
			return player.Current_Air_AttackDown

	if Input.is_action_just_released("Dash") or ((Input.is_action_just_released("Left") or
	Input.is_action_just_released("Right")) and !Input.is_action_pressed("Dash")):
		#%Mask.disabled = false
		#%MaskDown.disabled = true
		return player.DashFallState

	if Input.is_action_pressed("Left") and not Input.is_action_pressed("Right"):
		Direction_Dash = -1
	elif Input.is_action_pressed("Right") and not Input.is_action_pressed("Left"):
		Direction_Dash = 1
	
	return null
	
func process(delta: float) -> StateMaker:
	Actual_Dash_Time -= delta
	
	#Changed to manage flip sprite based in direction dash
	if player.velocity.x < 0:
		player.is_sprite_flipped = true
	else:
		player.is_sprite_flipped = false
	
	#Return to jump in spring:
	if player.impulsed_by_spring:
		return player.JumpState
	
	if player.is_on_water:
		"Create bubble particle"
		Triggers.create_ParticleTrigger(
		#Particle Scene
		preload("res://Scenes/Triggers/FXs/Particles/0.tscn"),
		#Particle Posiiton
		player.PivotCenter.global_position + Vector2(32*player.sprite.scale.x, 0),
		#Particle Scale
		Vector2(player.sprite.scale.x, 1),
		#Particle Material
		preload("res://tres/Materials/WaterBubbleDeep.tres"),
		#Particle AmountRatio
		0.1);
	
	#Enable dash box
	if player.is_immune == false:
		%Hitbox.enable_DashHitbox()
	
	player.AnimationTraveler.get("parameters/Dash/playback").travel("DashLoop")
	
	#Make current hitbox as dash shape
	if player.is_immune == false:
		%Hitbox.enable_DashHitbox()
	
	if !Input.is_action_pressed("Left") and !Input.is_action_pressed("Right") \
	and !Input.is_action_pressed("Dash"):
		Actual_Dash_Time = 0
	
	if player.can_be_knockbacked():
		#%Mask.disabled = false
		#%MaskDown.disabled = true
		return player.KnockBackState

	if player.On_Wall():
		#%Mask.disabled = false
		#%MaskDown.disabled = true
		#return player.WallSlideState
		pass

	#Direction Change on wall
	if (!Input.is_action_pressed("Left") and
	!Input.is_action_pressed("Right")):
		#Right wall collision when dash:
		if player.Right_raycast():
			#Direction_Dash = -1
			player.is_sprite_flipped = true
		#Left wall collision when dash:
		elif player.Left_raycast():
			#Direction_Dash = 1
			player.is_sprite_flipped = false



	#While dash time is not end:
	if Actual_Dash_Time > 0:
		if Direction_Dash > 0:
			player.velocity.x = min(player.velocity.x + acceleration, velocity_speed)
		elif Direction_Dash < 0:
			player.velocity.x = max(player.velocity.x - acceleration, -velocity_speed)
		return null



	#When Dash time is end:
	elif Actual_Dash_Time <= 0:
		if player.velocity.x > 0:
			player.velocity.x = max(player.velocity.x - friction, 0)
		if player.velocity.x < 0:
			player.velocity.x = min(player.velocity.x + friction, 0)


	
#	if (!Input.is_action_pressed("Left") and
#	!Input.is_action_pressed("Right")):
#		#Right wall collision when dash:
#		if player.Right_raycast():
#			Direction_Dash = -1
#			player.sprite.flip_h = true
#		#Left wall collision when dash:
#		elif player.Left_raycast():
#			Direction_Dash = 1
#			player.sprite.flip_h = false
	
	


	if player.is_on_floor():
		if not Input.is_action_pressed("Left") and not Input.is_action_pressed("Right"):
			#%Mask.disabled = false
			#%MaskDown.disabled = true
			return player.DashFallState
		elif Input.is_action_pressed("Left") or Input.is_action_pressed("Right"):
			#%Mask.disabled = false
			#%MaskDown.disabled = true
			return player.RunState

	if Actual_Dash_Time > 0:
		return null
	if (player.velocity.x == 0 and not (Input.is_action_pressed("Left") and Input.is_action_pressed("Right"))) \
	or Input.is_action_pressed("Left") or Input.is_action_pressed("Right"):
		#%Mask.disabled = false
		#%MaskDown.disabled = true
		return player.DashFallState
	return null
