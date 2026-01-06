extends Slashs

#Exported Vars
#export var Reduced_speed = 20

@export_category("Velocity values")
@export var velocity_speed : float = 60.0
@export var acceleration : float = 0.0
@export var friction : float = 0.0

var buffador_de_pulo_temporizado : float = 0.0
var is_animation_finished : bool = false

var inputed = false

#func
func enter() -> void:
	super()
	
	TimerInput = Time_ToInput
	
	buffador_de_pulo_temporizado = 0.0
	TimerSlash = Attack_Duration
	#Hitbox_Mask.disabled = false

	#pra evitar de criar um "airdashslash"
#	if Input.is_action_pressed("Left"):
#		velocity_speed = -player.velocity.x
#	elif Input.is_action_pressed("Right"):
#		velocity_speed = player.velocity.x

func exit() -> void:
	%Meele_Hitbox.disable_clash_areas()
	is_animation_finished = false
	inputed = false
	#avoiding coyote time works in jump state
	player.can_jump = false
	player.can_air_slash = false
	
func input(_event: InputEvent) -> StateMaker:
	if player.can_crazy_fly:
		if Input.is_action_pressed("Alt_Attack_Input") and Input.is_action_pressed("Main_Attack_Input"):
			return player.CrazyFlyState
			
	if Input.is_action_just_released("Jump") and player.velocity.y < 0:
		player.velocity.y *= 0.5
			
	return null

func physics_process(delta: float) -> StateMaker:
		
		
	#Dash Fall while slash
		
	velocity()
	#Countdown the timer
	if is_animation_finished:
		return player.DashFallState

	if player.Hitted:
		return player.KnockBackState

	if player.can_climb:
		if Input.is_action_pressed("Up") or Input.is_action_pressed("Down") and !player.is_on_floor():
			return player.ClimbState


	if Input.is_action_just_pressed("Dash") and player.can_air_dash == true: # and not player.reduce_velocity():
		return player.AirDashState

	if player.ceil_left_is_colliding():
		player.global_position.x += 5
	elif player.ceil_right_is_colliding():
		player.global_position.x -= 5

	#Give player movement values:
	if not player.is_on_floor():
		player.velocity.y += player.Gravity * 1.5 * delta
		if player.On_Wall() and Input.is_action_just_pressed("Jump"):
			return player.WallJumpState
			
	#Is on floor or not:
	if not player.is_on_floor():
		#GRAVITY#
		if player.On_Wall():
			return player.WallSlideState
	else:
		#Is_on_floor
		player.can_jump = true
		if buffador_de_pulo_temporizado > 0:
			#print("bufado")
			return player.DashJumpState
		else:
			if player.velocity.x != 0:
				return player.RunState
			else:
				return player.IdleState
	
	return null

func velocity() -> void:
	
	#Input
	var is_left = Input.is_action_pressed("Left") and !Input.is_action_pressed("Right")
	var is_right = Input.is_action_pressed("Right") and !Input.is_action_pressed("Left")
	
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

func _set_animation_finished() -> void:
	is_animation_finished = true
