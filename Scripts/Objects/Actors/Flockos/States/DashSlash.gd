@icon("res://Sprites/EditorTriggers/SpinningBiteIcon.png")
extends Slashs

@export_category("Timer")
@export var DashTime = 0.4

@export_category("Velocity values")
@export var velocity_speed : float = 360.0 ##Velocidade do movimento
@export var acceleration : float = 40.0 ##Força da aceleração de movimento
@export var friction : float = 60.0 ##Força de atrito do movimento

var Actual_Dash_Time : float = 0
var Direction_Dash : int = 1

# Upon entering the state, set dash direction to either current input or the direction the player is facing if no input is pressed
func enter() -> void:
	super()

	SoundEffects.play_sound(SoundEffects.SFX_DASHSAW)
	TimerSlash = Attack_Duration
	#get_node(Hitbox_Mask).disabled = false
	Actual_Dash_Time = DashTime
	
	
	if !player.is_on_floor():
		Actual_Dash_Time /= 4
		
	#%Mask.disabled = false
	#%MaskDown.disabled = true

	player.AnimationTraveler.get("parameters/Dash/playback").travel("DashSlash")
	
	%Trail.can_trail = true
	%PivotTrail.position = Vector2.ZERO
	
	if player.is_sprite_flipped == true:
		Direction_Dash = -1
	else:
		Direction_Dash = 1
	
func exit() -> void:
	#avoiding coyote time works in jump state
	SoundEffects.stop_sound(SoundEffects.SFX_DASHSAW)
	
	%Meele_Hitbox.disable_clash_areas()
	%Meele_Hitbox.disable_all_collision_shapes()
	
	
	#%ClashMask1.disabled = true
	#%ClashMask2.disabled = true


# Override MoveState input() since we don't want to change states based on player input
func input(_event: InputEvent) -> StateMaker:
	
	if Input.is_action_just_released("Dash") or Input.is_action_just_pressed("Alt_Attack_Input"):
		if player.is_on_floor():
			if not (Input.is_action_pressed("Left") and Input.is_action_pressed("Right")):
				if not Input.is_action_pressed("Main_Attack_Input"):
					return player.IdleState
				else:
					return player.IdleSlash1State
			else:
				return player.RunState
		else:
			return player.DashFallState

	if Input.is_action_just_pressed("Jump") and player.is_on_floor():
		return player.DashJumpState

	if Input.is_action_just_pressed("Left"):
		Direction_Dash = -1
	elif Input.is_action_just_pressed("Right"):
		Direction_Dash = 1
	return null

func process(delta: float) -> StateMaker:
	Actual_Dash_Time -= delta
	
	if Input.is_action_pressed("Down"):
		#To avoid lagging when back to idle
		if Input.is_action_pressed("Main_Attack_Input"):
			return player.DownSlash1State
		else:
			return player.DownState
	#Return to jump in spring:
	if player.impulsed_by_spring:
		player.velocity = player.Velocity_Impulse
		
	if player.is_on_floor():
		player.velocity.y = 0
	
	if player.is_small_area_on_water and !ray_is_colliding():
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
		0.1);
	
		#Disaable Down Mask
	if player.is_immune == false:
		%Hitbox.enable_DefaultHitbox()
	
	if player.can_be_knockbacked():
		return player.KnockBackState

	#Give velocity
	#player.velocity.y = player.move_and_slide_with_snap(
		#player.velocity, player.vector_snap * player.snap_floor, player.PLANE_FLOOR,
		#false, 5, player.SLOPE_HOLDDOWN).y
	
	if ray_is_colliding():
		player.velocity.x = 0
		if Input.is_action_pressed("Main_Attack_Input"):
			Actual_Dash_Time = DashTime
	else:
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


		#While dash time is not end:
		if Actual_Dash_Time > 0:
			player.SFX_dash_saw.volume_db = linear_to_db(0.0)
			if Direction_Dash > 0:
				player.velocity.x = min(player.velocity.x + acceleration, velocity_speed)
			elif Direction_Dash < 0:
				player.velocity.x = max(player.velocity.x - acceleration, -velocity_speed)
			return null

		#When Dash time is end:
		elif Actual_Dash_Time <= 0:
			player.SFX_dash_saw.pitch_scale = lerp(player.SFX_dash_saw.pitch_scale, 0.2, 0.05)
			if player.velocity.x > 0:
				player.velocity.x = max(player.velocity.x - friction, 0)
			if player.velocity.x < 0:
				player.velocity.x = min(player.velocity.x + friction, 0)




	if player.velocity.x == 0 and Actual_Dash_Time <= 0:
		if player.is_on_floor():
			if not Input.is_action_pressed("Left") and not Input.is_action_pressed("Right"):
				return player.IdleState
			else:
				return player.RunState
		else:
			return player.DashFallState
	return null
#END#


func ray_is_colliding() -> bool:
	return (%LeftRayDashA.is_colliding() or 
	%LeftRayDashB.is_colliding() or
	%LeftRayDashC.is_colliding() or
	%LeftRayDashD.is_colliding() or
	%RightRayDashA.is_colliding() or
	%RightRayDashB.is_colliding() or
	%RightRayDashC.is_colliding() or
	%RightRayDashD.is_colliding())
	
