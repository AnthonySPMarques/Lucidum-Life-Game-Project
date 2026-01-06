extends StateMaker

#Export Vars#
@export_category("Velocity values")
@export var velocity_speed : float = 350.0 ##Velocidade do movimento
@export var acceleration : float = 100.0 ##Força da aceleração de movimento
@export var friction : float = 60.0 ##Força de atrito do movimento

#Time that you have to press the left or right key again before go to idle state:
#export (float) var time_to_press_arrow_again : float = 0.1
#var TimerToPressArrowCounter = 1.0

#Vars
var is_left
var is_right

var side = 0

var keep_running : bool = false #play running animation from loop

func enter() -> void:
	super()
	
	player.AnimationTraveler["parameters/Run/AutoStarts/To_Flip/transition_request"] = "No"
	
	%Trail.can_trail = false
	
	#Toggle off player landing animation when do run cycle animation:
	player.is_landing = false
	
	
	
	#Reset gravity
	player.velocity.y = 0
	
func exit() -> void:
	keep_running = false
	
func input(_event: InputEvent) -> StateMaker:
	
	if Input.is_action_just_pressed("Jump") or player.impulsed_by_spring:
		if Input.is_action_pressed("Dash"):# and not player.reduce_velocity():
			return player.DashJumpState
		return player.JumpState
		
	if Input.is_action_just_pressed("Main_Attack_Input"):
		if Input.is_action_pressed("Up"):
			if player.Has_AttackUp:
				return player.Current_AttackUp
		else:
			if player.is_on_floor():
				if not Input.is_action_pressed("Down"):
					if Input.is_action_pressed("Left") or \
					Input.is_action_pressed("Right"):
						if player.velocity.x == velocity_speed or player.velocity.x == -velocity_speed: 
							return player.RunSlashState

	

	if not player.impulsed_by_spring:
		if Input.is_action_pressed("Down") and player.is_on_floor():
			return player.DownState

		if player.is_on_floor():
			if Input.is_action_just_pressed("Dash"):# and not player.reduce_velocity():
				return player.DashState

	return null

func physics_process(_delta: float) -> StateMaker:
	if player.is_on_slider:
		return player.OnSliderState
	if player.is_immune == false:
		%Hitbox.enable_DefaultHitbox()
	else:
		%Hitbox.disable_hitboxes()
	
	#To climbstate
	if player.can_climb:
		if Input.is_action_pressed("Up") or Input.is_action_pressed("Down") \
		and !player.is_on_floor():
			return player.ClimbState
	#Climb from up to down
	elif player.check_ladder_trap() and Input.is_action_pressed("Down"):
		return player.ClimbStartState
	###
	
	if player.can_be_knockbacked():
		return player.KnockBackState
	
	if not Input.is_action_pressed("Up") and not Input.is_action_pressed("Down"):
		if Input.is_action_just_pressed("Main_Attack_Input"):
			if Input.is_action_pressed("Left") or \
				Input.is_action_pressed("Right"):
				if player.velocity.x == velocity_speed or player.velocity.x == -velocity_speed: 
					return player.RunSlashState
			if not Input.is_action_pressed("Left") and \
			not Input.is_action_pressed("Right"):
				if player.can_slash and !player.is_on_wall():
					player.velocity.x *= 0
					return player.IdleSlash1State
			
	#Do flip animation
	if (Input.is_action_just_pressed("Left") and !player.is_sprite_flipped) or \
	(Input.is_action_just_pressed("Right") and player.is_sprite_flipped):
		direction_changed()
		
	velocity()

	#Input
	is_left = Input.is_action_pressed("Left") and !Input.is_action_pressed("Right")
	is_right = Input.is_action_pressed("Right") and !Input.is_action_pressed("Left")
	
	
	#movement from slopes:
	

	if player.velocity.x == 0 and not player.impulsed_by_spring:
		if not Input.is_action_pressed("Main_Attack_Input"): return player.IdleState
		else: return player.IdleSlash1State
	elif player.impulsed_by_spring:
		return player.JumpState
		
	if !player.is_on_floor():
		if player.velocity.y >= 0:
			#player.velocity.y += (player.Gravity * delta) + 100
			if !Input.is_action_pressed("Dash"):
				return player.FallState
			else:
				return player.DashFallState
		else:
			if !Input.is_action_pressed("Dash"):
				return player.JumpState
			else:
				return player.DashJumpState
		
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

func direction_changed():
	#print("flipped animation")
	player.AnimationTraveler["parameters/Run/playback"].travel("Flip")
	
	
