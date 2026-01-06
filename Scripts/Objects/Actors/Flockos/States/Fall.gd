extends StateMaker

const FALL_MIN_HEIGHT = 1400

#Exported vars#
@export_category("Velocity values")
@export var impulsed_gravity : float = 1.5 ##Esse valor será multiplicado pela atual gravidade do jogador enquanto ele estiver caindo
@export var velocity_speed : float = 360.0 ##Velocidade do movimento
@export var Acceleration : float = 50.0 ##Força da aceleração de movimento
@export var Friction : float = 60.0 ##Força de atrito do movimento

@export_category("Plataformer Logics")
@export var Buffador_de_pulo : float = 0.12 ##Tempo para pressionar o botão de pulo antes de chegar ao chão
@export var Coyote_tempo : float = 0.12 ##Tempo para dar um pulo antes de cair de uma quina
@export var time_to_press_arrow_again : float = 0.2 ##Double tap dash
#Time that you have to press the left or right key again before go to idle state:

var TimerToPressArrowCounter : float = 1.0
var buffador_de_pulo_temporizado : float = 0.12
var coyote : float = 0.12
var squish : float
#Store modified var
var friction : float
var acceleration : float

const MAX_SQUISH = 1.5

func enter() -> void:
	super()
	player.main_mask.position.y = -58
	if not player.is_impulsed_by_forces:
		friction = Friction
		acceleration = Acceleration
	else:
		friction = 0
		acceleration = Acceleration/8
	#%Mask.disabled = false
	#%MaskDown.disabled = true
	player.disable_snap_floor()
	if player.impulsed_by_spring:
		if player.Velocity_Impulse.x != 0:
			friction = 0
			acceleration = 0
		
	%Meele_Hitbox.disable_clash_areas()
	
	player.can_flip = true
	
	squish = 1.0
	
	player.SFX_saw_pit.stop()
	
	buffador_de_pulo_temporizado = 0
	coyote = Coyote_tempo
	
	#Set falling current animation
	
	#Set landing mode animation
	
	#Enable Normal Mask
	if player.is_immune == false:
		player.hitbox_mask.disabled = false
		player.hitbox_down_mask.disabled = true
		player.hitbox_wall_mask.disabled = true
	
	#Avoid dust landing bug
	if player.is_on_semifloor():
		if Input.is_action_pressed("Down") and Input.is_action_just_pressed("Jump"):
			player.velocity.y += 100
func exit() -> void:
	player.is_impulsed_by_forces= false
	player.enable_snap_floor()
	
func process(_delta: float) -> StateMaker:
	
	#Check if there is pogo (lennyface)
	for area in player.hitbox.get_overlapping_areas():
		if area.get_parent() is ElecPogo and is_instance_valid(area):
			area.get_parent().call_deferred("queue_free")
			return player.OnPogo
	
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
	velocity()
	
	if not player.is_on_floor():
		player.velocity.y += (player.Gravity * delta) * impulsed_gravity
		
	if player.is_immune == false:
		%Hitbox.enable_DefaultHitbox()
	
	if player.SFX_fan.playing == true:
		player.SFX_fan.stop()
	
	if player.can_climb:
		if Input.is_action_pressed("Up") or Input.is_action_pressed("Down") and !player.is_on_floor() and !Input.is_action_pressed("Jump"):
			player.velocity.y = 0
			return player.ClimbState
	
	if player.can_hang_top_solid and not player.is_on_floor():
		if Input.is_action_pressed("Up"):
			return player.HangingTop
	
	#if is falling and didnt did a airdash meanwhile:
	if Input.is_action_just_pressed("Dash") and player.can_air_dash == true:# and not player.reduce_velocity():
		return player.AirDashState

	#Set pound animation
	if player.velocity.y > FALL_MIN_HEIGHT:
		player.is_landing = true
	elif player.velocity.y > 0 and player.velocity.y < FALL_MIN_HEIGHT:
		player.is_landing = false
	
	#Return to jump in spring:
	if player.impulsed_by_spring:
		return player.JumpState
		
	#Is on floor or not:
	if not player.is_on_floor():
		#GRAVITY#
		if player.On_Wall() and (Input.is_action_pressed("Left") or Input.is_action_pressed("Right")):
			if Input.is_action_just_pressed("Jump"):
				return player.WallJumpState
			return player.WallSlideState
		
		###Add squish force by impulsed gravity reduced by 2
		if squish < MAX_SQUISH:
			squish += (impulsed_gravity/4) * delta
		else:
			squish = MAX_SQUISH
		
		
	else:
		
		if not player.is_on_water:
			SoundEffects.play_sound(SoundEffects.SFX_LAND)
		#Is_on_floor
		player.can_jump = true
		if buffador_de_pulo_temporizado > 0:
			if !player.is_on_slider:
				return player.JumpState
			else:
				return player.OnSliderState
		else:
			
			if !player.Hitted and player.velocity.y < 100:
				#Dust landing#
				Triggers.create_VisualEffectTrigger(8, 
				player.global_position, 
				Vector2(%FlockosSprite.scale.x, 1))
				
				Triggers.create_VisualEffectTrigger(5, 
				player.global_position + (Vector2(-10, 10)), 
				Vector2(%FlockosSprite.scale.x, 1))
				
				Triggers.create_VisualEffectTrigger(5, 
				player.global_position + (Vector2(10, 10)), 
				Vector2(%FlockosSprite.scale.x, 1))
			
			#Add key to fade gravity by starting from the squish value accreassed
			#by the impulse gravity force while falling:
			%Visuals.squish_sprite(
				Vector2(1.0 + (squish - 0.8), 1.0 - (squish - 1.0)),
				0.2)
			#Set to dont land.
			player.AnimationTraveler.set("parameters/Run/AutoStarts/To_Flip/transition_request", "DontStart")
			
			if player.velocity.x != 0:
				return player.RunState
			else:
				if player.is_on_slider:
					return player.OnSliderState
				else:
					if not player.is_landing:
						return player.IdleState
					else:
						return player.LandingState
						
	#if player.can_air_dash or player.is_on_water:
		#if (player.Pressed_Times_L == 2 or player.Pressed_Times_R == 2) and player.velocity.x != 0:
			#return player.AirDashState
	
	#Check hit
	if player.can_be_knockbacked():
		return player.KnockBackState

	if buffador_de_pulo_temporizado > 0:
		buffador_de_pulo_temporizado -= delta
	if coyote > 0:
		coyote -= delta
	return null
	
func input(_event: InputEvent) -> StateMaker:
	
	if not Input.is_action_pressed("Down") and \
	Input.is_action_just_pressed("Special") \
	and player.MeeleHitbox.is_slash_charged:
		return player.ChargedSlashState
	
	if Input.is_action_just_pressed("Jump"):
		buffador_de_pulo_temporizado = Buffador_de_pulo
		if player.is_on_water:
			return player.JumpState
	
		if coyote > 0 and player.can_jump == true:
			player.can_jump = false
			return player.JumpState
	
	
	if player.Has_Air_AltAttack:
		if player.can_crazy_fly:
			if Input.is_action_pressed("Alt_Attack_Input"):
				return player.Current_Air_AltAttack

	if player.Has_Air_AttackDown:
		if Input.is_action_just_pressed("Main_Attack_Input") and Input.is_action_pressed("Down") \
		and not Input.is_action_pressed("Alt_Attack_Input"):
			return player.Current_Air_AttackDown

	if Input.is_action_just_pressed("Main_Attack_Input") and not Input.is_action_pressed("Dash") \
	and not Input.is_action_pressed("Alt_Attack_Input"):
		return player.AirSlashState

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
	
