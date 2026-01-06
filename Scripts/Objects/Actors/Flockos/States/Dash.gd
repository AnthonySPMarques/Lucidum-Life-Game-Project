extends StateMaker

@export_category("Timer")
@export var DashTime : float = 0.0

@export_category("Velocity values")
@export var velocity_speed : float = 0.0
@export var Acceleration : float = 100.0
@export var Friction : float = 20.0


var Actual_Dash_Time : float = 0.0
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
		
	player.floor_snap_length = 32
	
	
	#%Mask.disabled = true
	#%MaskDown.disabled = false
	
	if player.is_small_area_on_water:
		player.AnimationTraveler["parameters/Current_Animation_State/transition_request"] = "WaterDash"
		SoundEffects.play_sound(SoundEffects.SFX_WATERSWING)
		
	%Trail.can_trail = true
	
	if player.is_on_water == false:
		SoundEffects.play_sound(SoundEffects.SFX_DASH)
	
	
	"Getters"
	player.AnimationTraveler.get("parameters/Dash/playback").travel("DashLoop")
	
	input_released = false
	
	#if player.Pressed_Times_L == 2 or player.Pressed_Times_R == 2:
		#side_can_release = true
	
	Actual_Dash_Time = DashTime
	if player.is_sprite_flipped:
		Direction_Dash = -1
	else:
		Direction_Dash = 1
	
	#Enable dash box
	if player.is_immune == false:
		%Hitbox.enable_DashHitbox()
	else:
		%Hitbox.disable_hitboxes()
	
	#"eletric smoke dash"
	Triggers.create_VisualEffectTrigger(7, 
	%Pivot.global_position, 
	Vector2(%FlockosSprite.scale.x, 1))

	#"smoke dash"
	Triggers.create_VisualEffectTrigger(6, 
	player.global_position, 
	Vector2(%FlockosSprite.scale.x, 1))
	
func exit() -> void:
	player.floor_snap_length = player.CURRENT_SNAP_LENGTH
	#%MaskDown.disabled = true
	
	#Restar trail position
	%PivotTrail.position = Vector2.ZERO
	
	#Disable Down Mask
	player.Pressed_Times_L = 0 
	player.Pressed_Times_R = 0
	side_can_release = false
	
	player.AnimationTraveler.set("parameters/Is_Dashing/current",
	1)
	
	if player.is_immune == false:
		player.hitbox_mask.disabled = false
		player.hitbox_down_mask.disabled = true
	
	
# Override MoveState input() since we don't want to change states based on player input
func input(_event: InputEvent) -> StateMaker:

	if Input.is_action_just_released("Dash") or \
	(  
	( !Input.is_action_pressed("Left") and 
	!Input.is_action_pressed("Right") )
	and side_can_release):# or Input.is_action_just_pressed("Alt_Attack_Input"):
		#Change to stop animation
		player.AnimationTraveler.get("parameters/Dash/playback").travel("DashStopLoop")
		if player.velocity.x > 0:
			player.velocity.x = max(player.velocity.x - friction, 0)
		if player.velocity.x < 0:
			player.velocity.x = min(player.velocity.x + friction, 0)
	
	
	if Input.is_action_pressed("Down"):
		return player.DownState
	
	
	
	###
	###Chanegd just pressed
	if Input.is_action_pressed("Left"):
		Direction_Dash = -1
	elif Input.is_action_pressed("Right"):
		Direction_Dash = 1
	return null

func physics_process(delta: float) -> StateMaker:
	Actual_Dash_Time -= delta
	if player.is_on_slider:
		return player.OnSliderState
	if not (%DownCeilRay_Left.is_colliding() or
		%DownCeilRay_Right.is_colliding()):
		if Input.is_action_pressed("Main_Attack_Input"):
			if !Input.is_action_pressed("Up"):
				if player.Has_DashAttack:
					%Mask.disabled = false
					%MaskDown.disabled = true
					return player.Current_DashAttack
			else:
				if player.Has_AttackUp:
					%Mask.disabled = false
					%MaskDown.disabled = true
					return player.Current_AttackUp
			
		if Input.is_action_just_pressed("Jump") or player.impulsed_by_spring:
			%Mask.disabled = false
			%MaskDown.disabled = true
			
			return player.DashJumpState
	
	
	if not (%DownCeilRay_Left.is_colliding() or
		%DownCeilRay_Right.is_colliding()):
		if player.impulsed_by_spring:
			return player.DashJumpState
		
	if player.is_small_area_on_water:
		"Create bubble particle"
		Triggers.create_ParticleTrigger(
		#Particle Scene
		preload("res://Scenes/Triggers/FXs/Particles/0.tscn"),
		#Particle Posiiton
		player.PivotCenter.global_position + Vector2(32*player.sprite.scale.x, 0),
		#Particle Scale
		Vector2(-player.sprite.scale.x, 1),
		#Particle Material
		preload("res://tres/Materials/WaterBubbleDeep.tres"),
		#Particle AmountRatio
		0.1);
		if not (%DownCeilRay_Left.is_colliding() or
		%DownCeilRay_Right.is_colliding()):
			if not player.ceil_ray_is_colliding():
				if Input.is_action_pressed("Jump"):
					return player.DashJumpState
	
	if !Input.is_action_pressed("Left") and !Input.is_action_pressed("Right") \
	and !Input.is_action_pressed("Dash"):
		Actual_Dash_Time = 0
	
	#Make current hitbox as dash shape
	if player.is_immune == false:
		%Hitbox.enable_DashHitbox()
	
	#When Hitted
	if player.can_be_knockbacked():
		return player.KnockBackState
	
	
	#
	#Changed to manage flip sprite based in direction dash
	if player.velocity.x < 0:
		player.is_sprite_flipped = true
	elif player.velocity.x > 0:
		player.is_sprite_flipped = false
	
	#When is falling without jumping
	if not player.is_on_floor():
		
		if player.ceil_ray_is_colliding():
			player.global_position.y += 64
		player.velocity.y *= 0.5
		return player.DashFallState
	
	if (!Input.is_action_pressed("Left") and
	!Input.is_action_pressed("Right")):
		#Right wall collision when dash:
		if player.Right_raycast():
			player.velocity.x = -velocity_speed
			Direction_Dash = -1
			player.is_sprite_flipped = true
		#Left wall collision when dash:
		elif player.Left_raycast():
			player.velocity.x = velocity_speed
			Direction_Dash = 1
			player.is_sprite_flipped = false

	#Or if dash input is released
	if Input.is_action_just_released("Dash") and input_released == false:# or Input.is_action_just_pressed("Alt_Attack_Input"):
		Actual_Dash_Time = 0.05
		input_released = true
		
	#While dash time is not end:
	if Actual_Dash_Time > 0 and not input_released:
		if not player.is_on_wall():
			if Input.is_action_pressed("Dash") or \
			(Input.is_action_pressed("Left") or 
			Input.is_action_pressed("Right")):
				if Direction_Dash > 0 and not Input.is_action_pressed("Left"):
					player.velocity.x = min(player.velocity.x + acceleration, velocity_speed)
				elif Direction_Dash < 0 and not Input.is_action_pressed("Right"):
					player.velocity.x = max(player.velocity.x - acceleration, -velocity_speed)
				else:
					Actual_Dash_Time = 0
		else:
			if Direction_Dash > 0:
				player.velocity.x = velocity_speed
			elif Direction_Dash < 0:
				player.velocity.x = -velocity_speed
		return null

	#When Dash time is end:
	elif Actual_Dash_Time <= 0 or input_released:
	#else:
		if not (%DownCeilRay_Left.is_colliding() or
		%DownCeilRay_Right.is_colliding()):
			if Input.is_action_pressed("Left") or Input.is_action_pressed("Right"):
				player.RunState.keep_running = true
				return player.RunState
			
			#Change to stop animation
			player.AnimationTraveler.get("parameters/Dash/playback").travel("DashStopLoop")
			
			#Velocity decreasing:
			if player.velocity.x > 0:
				player.velocity.x = max(player.velocity.x - friction, 0)
			if player.velocity.x < 0:
				player.velocity.x = min(player.velocity.x + friction, 0)
			
	
			#When velocity comes to 0
			if player.velocity.x == 0:
				if not Input.is_action_pressed("Left") and not Input.is_action_pressed("Right"):
					if not Input.is_action_pressed("Down"):
						return player.IdleState
					else:
						return player.DownState
				else:
					return player.RunState
		else:
			return player.DownState
			
	return null
#END#
