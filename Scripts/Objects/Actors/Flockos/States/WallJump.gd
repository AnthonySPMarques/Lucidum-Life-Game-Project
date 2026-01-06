extends StateMaker

@export_category("Velocity values")
@export var Velocity_Speed : float = 350.0
@export var VelocityDash_Speed : float = 600.0
@export var Jump_height : float = 915.0
@export var Dash_Jump_height : float = 990.0
@export var Kick_Force : float = 35.5
@export var Kick_Force_Dash : float = 35.5
@export var acceleration : int = 0
@export var dash_acceleration : int = 0
@export var friction : int = 0

var speed
var speeddash

func enter() -> void:
	super()
	
	SoundEffects.play_sound(SoundEffects.SFX_WALLKICK)
	
	#%FanSFX.stop()
	if player.is_immune == false:
		%Hitbox.enable_DefaultHitbox()
	
	speed = Velocity_Speed
	speeddash = VelocityDash_Speed
	
	
	#Dash Impulse
	if !Input.is_action_pressed("Dash"):
		player.velocity.y = -Jump_height
		if player.Right_raycast():
			player.velocity.x -= Kick_Force
		elif player.Left_raycast():
			player.velocity.x += Kick_Force
	else:
		player.velocity.y = -Dash_Jump_height
		if player.Right_raycast():
			player.velocity.x -= Kick_Force_Dash
		elif player.Left_raycast():
			player.velocity.x += Kick_Force_Dash
			
	if player.Left_raycast():
		player.is_sprite_flipped = true
	elif player.Right_raycast():
		player.is_sprite_flipped = false
		
func exit() -> void:
	%Hitbox.enable_DefaultHitbox()
	player.can_flip = true
	speed = Velocity_Speed
	
func input(_event: InputEvent) -> StateMaker:

	if Input.is_action_just_pressed("Main_Attack_Input") and Input.is_action_pressed("Down") \
	and not Input.is_action_pressed("Alt_Attack_Input"):
		return player.Current_Air_AttackDown

	elif not Input.is_action_just_pressed("Down"):
		if Input.is_action_just_pressed("Main_Attack_Input") and not Input.is_action_pressed("Dash") \
		and not Input.is_action_pressed("Alt_Attack_Input"):
			return player.AirSlashState
	
	
	return null
	
	
func process(_delta: float) -> StateMaker:

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
	
	if player.can_be_knockbacked():
		return player.KnockBackState
	return null
	
#Physics
func physics_process(delta: float) -> StateMaker:
	
	"Blade Fan State"
#	if Input.is_action_pressed("Defend"):
#		return WallBladeFanState
	
	if player.is_immune == false:
		%Hitbox.enable_DefaultHitbox()
	
	if !Input.is_action_pressed("Jump") and player.velocity.y < 0:
		player.velocity.y *= 0.5

	if player.velocity.y > 0:
		if not Input.is_action_pressed("Dash"):
			return player.FallState
		else:
			return player.DashFallState

	if Input.is_action_pressed("Alt_Attack_Input") and Input.is_action_pressed("Main_Attack_Input") and player.can_crazy_fly:
		if speed == Velocity_Speed:
			if player.Has_Air_AltAttack:
				return player.Current_Air_AltAttack
		else:
			if player.Has_DashAir_AltAttack:
				return player.Current_DashAir_AltAttack
	
	
	#Avoid cabeça de cearnese
	if player.ceil_left_is_colliding():
		player.global_position.x += 5
	elif player.ceil_right_is_colliding():
		player.global_position.x -= 5


	if player.can_climb:
		if Input.is_action_pressed("Up") and !player.is_on_floor() or Input.is_action_pressed("Down") and !player.is_on_floor():
			return player.ClimbState

	velocity()

	"Função da mecanica CloudHook que estará temporariamente descartada"
#	#Hook state
#	if player.hooking: #If the cloud hook is on a solid area:
#		return HookedState
	"Função da mecanica CloudHook que estará temporariamente descartada"

	#AirDash
	if Input.is_action_just_pressed("Dash") and player.can_air_dash == true and !player.On_Wall():# and not player.reduce_velocity():
		return player.AirDashState

	#Apply Gravity
	if !player.is_on_floor():
		player.velocity.y += (player.Gravity + 1600) * delta

	if to_slide():
		return player.WallSlideState

	if player.is_on_floor():
		return player.IdleState
		
	return null
	
func to_slide() -> bool:
	#check if player is going to face the wall
	if player.velocity.y > -200:
		if (player.velocity_is_to_left() and player.Left_raycast() ||
		player.velocity_is_to_right() and player.Right_raycast()):
			return true
	return false
func velocity():
	#Left or Right
	if Input.is_action_pressed("Right") and !Input.is_action_pressed("Left"):
		if Input.is_action_pressed("Dash"):
			player.velocity.x = min(player.velocity.x + dash_acceleration, speeddash)
			speed = VelocityDash_Speed
		else:
			player.velocity.x = min(player.velocity.x + acceleration, speed)

	elif Input.is_action_pressed("Left") and !Input.is_action_pressed("Right"):
		if Input.is_action_pressed("Dash"):
			player.velocity.x = max(player.velocity.x - dash_acceleration, -speeddash)
			speed = VelocityDash_Speed
		else:
			player.velocity.x = max(player.velocity.x - acceleration, -speed)

	else:
		#Friction:
		if player.velocity.x > 0:
			player.velocity.x = max(player.velocity.x - friction, 0)

		if player.velocity.x < 0:
			player.velocity.x = min(player.velocity.x + friction, 0)
