extends StateMaker

const FALL_MIN_HEIGHT = 1400

#Exported vars#
@export_category("Velocity values")
@export var velocity_speed : float = 600.0 ##Velocidade do movimento
@export var impulsed_gravity : float = 1.15 ##Esse valor será multiplicado pela atual gravidade do jogador enquanto ele estiver caindo
@export var Acceleration : float = 80.0 ##Força da aceleração de movimento
@export var Friction : float = 40.0 ##Força de atrito do movimento

@export_category("Plataformer Logics")
@export var Buffador_de_pulo : float = 0.12 ##Tempo para pressionar o botão de pulo antes de chegar ao chão
@export var Coyote_tempo : float = 0.12 ##Tempo para dar um pulo antes de cair de uma quina
@export var time_to_press_arrow_again : float = 0.2 ##Double tap dash

#Vars#
"Value variables"
var buffador_de_pulo_temporizado : float = 0.0
var coyote : float = 0.0
var squish : float = 1.0
#Store modified var
var friction : float
var acceleration : float

const MAX_SQUISH = 1.5

func enter() -> void:
	super()
	
	if not player.is_impulsed_by_forces:
		friction = Friction
		acceleration = Acceleration
	else:
		friction = 0
		acceleration = Acceleration/8
	
	
	if player.impulsed_by_spring:
		if player.Velocity_Impulse.x != 0:
			
			friction /= 0
			acceleration /= 0

	
	%Meele_Hitbox.disable_clash_areas()
	%Trail.can_trail = true
	
	%PivotTrail.position = Vector2.ZERO
	
	player.can_flip = true
	#player.stop_fan_all()
	
	player.SFX_saw_pit.stop()
	if player.is_immune == false:
		%Hitbox.enable_DefaultHitbox()
	
	buffador_de_pulo_temporizado = 0
	coyote = Coyote_tempo
	
	if player.is_on_semifloor():
		if Input.is_action_pressed("Down") and Input.is_action_just_pressed("Jump"):
			player.velocity.y += 100

func process(delta: float) -> StateMaker:
	
	#Check if there is pogo (lennyface)
	for area in player.hitbox.get_overlapping_areas():
		if area.get_parent() is ElecPogo and is_instance_valid(area):
			area.get_parent().call_deferred("queue_free")
			return player.OnPogoDash
	
	if player.can_be_knockbacked():
		return player.KnockBackState
	
	if buffador_de_pulo_temporizado > 0:
		buffador_de_pulo_temporizado -= delta
	if coyote > 0:
		coyote -= delta
		
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
	

func input(_event: InputEvent) -> StateMaker:

	if not Input.is_action_pressed("Down") and \
	Input.is_action_just_pressed("Special") \
	and player.MeeleHitbox.is_slash_charged:
		return player.ChargedSlashState

	if Input.is_action_just_pressed("Jump"):
		buffador_de_pulo_temporizado = Buffador_de_pulo
	
	if Input.is_action_just_pressed("Jump") and player.is_on_water:
		return player.DashJumpState
	
	if player.Has_Air_AttackDown:
		if Input.is_action_just_pressed("Main_Attack_Input") and Input.is_action_pressed("Down") \
		and not Input.is_action_pressed("Alt_Attack_Input"):
			return player.Current_Air_AttackDown
	
	if Input.is_action_just_pressed("Jump") and coyote > 0 and player.can_jump == true:
		player.can_jump = false
		return player.DashJumpState

	elif not Input.is_action_just_pressed("Down"):
		#if Input.is_action_just_pressed("Main_Attack_Input") and not Input.is_action_pressed("Dash") \
		#and not Input.is_action_pressed("Alt_Attack_Input"):
		if Input.is_action_just_pressed("Main_Attack_Input") \
		and not Input.is_action_pressed("Alt_Attack_Input"):
			return player.AirSlashDashState

	return null

func physics_process(delta: float) -> StateMaker:
	if player.is_on_slider:
		return player.OnSliderState
	if player.is_immune == false:
		%Hitbox.enable_DefaultHitbox()
	
	#if player.can_air_dash or player.is_on_water:
		#if (player.Pressed_Times_L == 2 or player.Pressed_Times_R == 2) and player.velocity.x != 0:
			#return player.AirDashState
	
	velocity()
	
	if player.can_hang_top_solid and not player.is_on_floor():
		if Input.is_action_pressed("Up"):
			return player.HangingTop
	
	if player.Has_Air_AltAttack:
		if player.can_crazy_fly:
			if Input.is_action_pressed("Alt_Attack_Input"):
				return player.Current_DashAir_AltAttack

	if player.can_climb:
		if Input.is_action_pressed("Up") or Input.is_action_pressed("Down") and !player.is_on_floor():
			return player.ClimbState

	if Input.is_action_just_pressed("Dash") and (player.can_air_dash or player.is_on_water):
		return player.AirDashState

#	if side > 0:
#		player.sprite.flip_h = false
#	elif side < 0:
#		player.sprite.flip_h = true

	
	
	#Set pound animation
	if player.velocity.y > FALL_MIN_HEIGHT:
		player.is_landing = true
	elif player.velocity.y > 0 and player.velocity.y < FALL_MIN_HEIGHT:
		player.is_landing = false
	
	#Return to jump in spring:
	if player.impulsed_by_spring:
		return player.DashJumpState
	
	#Coyote time
	if not player.is_on_floor():
		#GRAVITY#
		if player.On_Wall() and (Input.is_action_pressed("Left") or Input.is_action_pressed("Right")):
			if Input.is_action_just_pressed("Jump"):
				return player.WallJumpState
			return player.WallSlideState
			
		player.velocity.y += (player.Gravity * delta) * impulsed_gravity
		
		###Add squish force by impulsed gravity reduced by 2
		if squish < MAX_SQUISH:
			squish += (impulsed_gravity/4) * delta
		else:
			squish = MAX_SQUISH
		
	else:
		#Is_on_floor
		player.can_jump = true
		if buffador_de_pulo_temporizado > 0:
			return player.DashJumpState
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
			
			if player.velocity.x != 0:
				#Set to dont land.
				player.AnimationTraveler.set("parameters/Idle/Idles/On_Floor_Is/current", 0)
				#Set to flip.
				player.AnimationTraveler.set("parameters/Run/AutoStarts/To_Flip/current", 2)
				return player.RunState
			else:
				if not player.is_landing:
					player.AnimationTraveler.set("parameters/Run/AutoStarts/To_Flip/current", 2)
					#Set the landing intro.
					return player.IdleState
				else:
					return player.LandingState
					
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
		player.velocity.x = 0
