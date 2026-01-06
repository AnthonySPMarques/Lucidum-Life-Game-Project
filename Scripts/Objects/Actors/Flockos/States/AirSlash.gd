extends Slashs

#Exported Vars
#@export var Jump_height = 100

@export_category("Velocity values")
@export var impulsed_gravity : float = 1.2 ##Esse valor será multiplicado pela atual gravidade do jogador enquanto ele estiver caindo
@export var velocity_speed : float = 60.0
@export var acceleration : float = 0.0
@export var friction : float = 120.0

var buffador_de_pulo_temporizado : float = 0.0
var is_animation_finished : bool = false

var inputed = false

#func
func enter() -> void:
	is_animation_finished = false
	
	super()
	
	SoundEffects.play_sound(SoundEffects.SFX_SLASHBITE)
	
	TimerInput = Time_ToInput
	buffador_de_pulo_temporizado = 0
	TimerSlash = Attack_Duration
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
		0.4);
		
func exit() -> void:
	%Meele_Hitbox.disable_clash_areas()
	%Meele_Hitbox.disable_all_collision_shapes()
	is_animation_finished = false
	inputed = false
	#avoiding coyote time works in jump state
	player.can_jump = false
	player.can_air_slash = false

func physics_process(delta: float) -> StateMaker:
	#print(is_animation_finished)
	velocity()
	
	#Return to jump in spring:
	if player.impulsed_by_spring:
		player.velocity = player.Velocity_Impulse
	
	if player.velocity.y < 0:
		player.velocity.y += (player.Gravity + 1900) * delta
		
	if player.velocity.y >= 0:
		player.velocity.y += (player.Gravity * delta) * impulsed_gravity
			
	
	if TimerSlash > 0:
		TimerSlash -= delta
	if TimerInput > 0:
		TimerInput -= delta
	
	
		
	#Give player movement values:
	if not player.is_on_floor():
		
		if is_animation_finished:
			if name != "AirSlashDash":
				return player.FallState
			else:
				return player.DashFallState
				
		if player.velocity_is_to_down():
			if player.On_Wall() and Input.is_action_just_pressed("Jump"):
				return player.WallJumpState
			
			#GRAVITY#
			if (player.Left_raycast() and Input.is_action_pressed("Left")) or \
			(player.Right_raycast() and Input.is_action_pressed("Right")):
				return player.WallSlideState
	
	else:
		player.AnimationTraveler.get("parameters/AirSlashs/playback").travel("LandingAirSlash")
		player.velocity.x = 0
		#Is_on_floor
		player.can_jump = true
		if is_animation_finished == true:
			player.is_landing = false
			if Input.is_action_pressed("Main_Attack_Input"):
				return player.IdleSlash1State
			else:
				return player.IdleState
					
				

	if player.can_be_knockbacked():
		return player.KnockBackState
		
	if player.is_immune == false:
		%Hitbox.enable_DefaultHitbox()

	if player.can_climb:
		if Input.is_action_pressed("Up") or Input.is_action_pressed("Down") and !player.is_on_floor():
			return player.ClimbState

	if Input.is_action_just_pressed("Dash") and player.can_air_dash == true: # and not player.reduce_velocity():
		return player.AirDashState

	if player.ceil_left_is_colliding():
		player.global_position.x += 5
	elif player.ceil_right_is_colliding():
		player.global_position.x -= 5

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


func input(_event: InputEvent) -> StateMaker:
	
	if Input.is_action_just_pressed("Main_Attack_Input") and TimerInput <= 0 and not player.is_on_floor():
		#inputed = true
		player.AnimationTraveler["parameters/AirSlashs/AirSlash/TimeSeek/seek_request"] = 0.0
		
		return self
		
	#if inputed == true:
		#if is_animation_finished == true:
			#player.AnimationTraveler["parameters/AirSlashs/playback"].travel("AirSlash2")
			#return self
	
	if player.Has_Air_AltAttack:
		if player.can_crazy_fly:
			if Input.is_action_pressed("Alt_Attack_Input"):
				return player.Current_Air_AltAttack
			
	if player.velocity.y < 0:
		if (Input.is_action_just_released("Jump") or
		!Input.is_action_pressed("Jump")):
			player.velocity.y *= 0.5
			
	return null

func _set_animation_finished() -> void:
	is_animation_finished = true
