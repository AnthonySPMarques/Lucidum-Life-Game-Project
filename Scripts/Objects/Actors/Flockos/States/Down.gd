extends StateMaker

######
#Exported Vars
@export var velocity_speed : float = 350.0 ##Velocidade do movimento
@export var acceleration : float = 100.0 ##Força da aceleração de movimento
@export var friction : float = 60.0 ##Força de atrito do movimento


######
#Vars
var is_left
var is_right
var finished : bool = false
var timetoslash : float #Time to count before can go to down slash
var can_slash : bool = false

###########
#FUNCTIONS:

func enter() -> void: #When the player enters into this state:
	
	#%Mask.disabled = true
	#%MaskDown.disabled = false
	
	super()
	finished = false
	
	if player.is_immune == false:
		%Hitbox.enable_DownHitbox()
	else:
		%Hitbox.disable_hitboxes()
	
	#Give the value always that the state start
	timetoslash = 0.04
	
	player.is_landing = false
	
	if %Machine_State.Previous_State == player.DashState:
		player.AnimationTraveler["parameters/Down/conditions/InstantDuck"] = true
	if %Machine_State.Previous_State != player.DashState:
		player.AnimationTraveler["parameters/Down/conditions/InstantDuck"] = false
	
	#Enable down mask when is not immune
#	if player.is_immune == false:
#		$"%Hitbox".enable_DownHitbox()
	
func exit() -> void:
	#if not get_parent().Previous_State == player.DashState:
		#%Mask.disabled = false
		#%MaskDown.disabled = true
	
	if player.is_immune:
		%Hitbox.enable_DefaultHitbox()
	#Disable Down Mask back to non ducked states
#	if player.is_immune == false:
#		$"%Hitbox".enable_DefaultHitbox()
	
	finished = false
	
func physics_process(delta: float) -> StateMaker:
	if player.is_on_slider:
		return player.OnSliderState
	#Input
	is_left = Input.is_action_pressed("Left") and !Input.is_action_pressed("Right")
	is_right = Input.is_action_pressed("Right") and !Input.is_action_pressed("Left")
	
	if player.check_ladder_trap():
		return player.ClimbState
	
	if player.is_on_semifloor() and not player.check_ladder_trap():
		if player.Pressed_Times_D > 1:
			return player.HangingToClimbDown
	
	if player.is_immune == false:
		%Hitbox.enable_DownHitbox()
	
	#Count down timer
	if timetoslash > 0:
		timetoslash -= delta
	else:
		can_slash = true
		timetoslash = 0
		
	if Input.is_action_just_pressed("Dash") and player.can_dash:
		return player.DashState
		

	if not Input.is_action_pressed("Down") or Input.is_action_just_released("Down"):
		if not (%DownCeilRay_Left.is_colliding() or 
		%DownCeilRay_Right.is_colliding()):
			player.AnimationTraveler["parameters/Down/playback"].travel("ReDown")
			can_slash = false
			velocity()
	if player.velocity.x != 0:
		_brake()
		
	#Reverse finished
	if finished and not (%DownCeilRay_Left.is_colliding() or 
	%DownCeilRay_Right.is_colliding()):
		if !is_left and !is_right:
			return player.IdleState
		else:
			return player.RunState
			
			
	if player.can_be_knockbacked():
		return player.KnockBackState

	if !player.is_on_floor():
		#When sliding to crounch like in megaman to avoid to get her head stuck into the tilemaps
		if player.ceil_ray_is_colliding():
			player.global_position.y += 64
		return player.FallState
	return null


func _brake() -> void:
	#SmokeEffect
	#Triggers.create_VisualEffectTrigger(6, 
	#player.global_position, 
	#Vector2(%FlockosSprite.scale.x, 1))
	
	if player.velocity.x > 0:
		player.velocity.x = max(player.velocity.x - friction, 0)
		if Input.is_action_pressed("Left"):
			player.velocity.x = max(player.velocity.x - friction*2, 0)
		
	if player.velocity.x < 0:
		player.velocity.x = min(player.velocity.x + friction, 0)
		if Input.is_action_pressed("Right"):
			player.velocity.x = min(player.velocity.x + friction*2, 0)
	
func input(_event: InputEvent) -> StateMaker: #Functions for inputs:
	
	if player.is_on_semifloor():
		if Input.is_action_pressed("Down") and Input.is_action_just_pressed("Jump"):
			if (Input.is_action_pressed("Left") or Input.is_action_pressed("Right")):
				if player.get_platform_velocity() == Vector2.ZERO:
					player.position.y += 4
				return player.FallState
				
			if !(Input.is_action_pressed("Left") and Input.is_action_pressed("Right")):
				if player.get_platform_velocity() == Vector2.ZERO:
					player.position.y += 4
				return player.FallState
	else:
		if player.is_on_floor() and not \
		(%DownCeilRay_Left.is_colliding() or
		%DownCeilRay_Right.is_colliding()) and \
		not player.ceil_ray_is_colliding():
			
			if Input.is_action_just_pressed("Jump") or player.impulsed_by_spring:
				return player.JumpState
	
	
	
	#To avoid lagging when back to idle
	if Input.is_action_pressed("Main_Attack_Input") and Input.is_action_pressed("Down") and can_slash:
		return player.DownSlash1State

	return null

func velocity() -> void:
	
	if not (Input.is_action_pressed("Left") and player.WallfloorLeft_raycast()) and \
		not (Input.is_action_pressed("Right") and player.WallfloorRight_raycast()):
		if is_right:
			player.velocity.x = min(player.velocity.x + acceleration, velocity_speed)

		elif is_left:
			player.velocity.x = max(player.velocity.x - acceleration, -velocity_speed)

		else:
			#Friction:
			if player.velocity.x > 0:
				player.velocity.x = max(player.velocity.x - friction, 0)

			if player.velocity.x < 0:
				player.velocity.x = min(player.velocity.x + friction, 0)
	else:
		player.velocity.x = 0

func go_to_idle():
	finished = true
