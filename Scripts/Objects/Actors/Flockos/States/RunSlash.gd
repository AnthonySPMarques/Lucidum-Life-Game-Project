extends Slashs

#Export Vars#
#export (float) var reduced_speed : int = 0
@export_category("Velocity values")
@export var velocity_speed : float = 0.0 ##Velocidade do movimento
@export var acceleration : float = 0.0 ##Força da aceleração de movimento
@export var friction : float = 0.0 ##Força de atrito do movimento
@export var final_slash : bool
@export var back_to_downstate : bool = false

#Vars
var is_left
var is_right
var current_speed
var inputed = false
var can_input : bool = false
var time_to_time #time to go idle and play save animation
var is_animation_finished : bool = false

func enter() -> void:
	super()
	
	SoundEffects.play_sound(SoundEffects.SFX_SLASHBITE)
	SoundEffects.play_sound(SoundEffects.SFX_KICKBACK)
	
	is_animation_finished = false
	
	#%Mask.disabled = false
	#%MaskDown.disabled = true
	
	#time to go idle and play save animation
	time_to_time = 0.2
	player.can_flip = false
	player.velocity.y = 0
	
	
	if player.is_small_area_on_water:
		"Create bubble particle"
		Triggers.create_ParticleTrigger(
		#Particle Scene
		preload("res://Scenes/Triggers/FXs/Particles/0.tscn"),
		#Particle Posiiton
		player.global_position + 
		Vector2(32 * player.sprite.scale.x, -78),
		#Particle Scale
		Vector2(player.sprite.scale.x, 1),
		#Particle Material
		preload("res://tres/Materials/WaterBubbleDeepBlown.tres"),
		#Particle AmountRatio
		1.0);
		
	
	#Set current state of animationtree
	"Setters"
	player.AnimationTraveler.get("parameters/Run/playback").travel(str(name))
	
	#Declare exported variable values
	TimerSlash = Attack_Duration
	TimerInput = Time_ToInput
	
	#get_node(Hitbox_Mask).disabled = false
	

func exit() -> void:
	
	can_input = false
	inputed = false
	#get_node(Hitbox_Mask).disabled = true
	player.is_landing = false

	player.can_flip = true
	
	
func physics_process(delta: float) -> StateMaker:
	if player.is_on_slider:
		return player.OnSliderState
	if player.is_on_wall():
		return player.IdleState
	
	if player.is_immune == false:
		%Hitbox.enable_DefaultHitbox()
	else:
		%Hitbox.disable_hitboxes()
	
	#player.velocity.y = player.move_and_slide_with_snap(
	#player.velocity, player.vector_snap * player.snap_floor, player.PLANE_FLOOR,
	#true, 5, player.SLOPE_HOLDDOWN).y
	
	#Input Timer
	if TimerInput <= 0:
		can_input = true
	else:
		TimerInput -= delta
	
	#Countdown the timer
	TimerSlash -= delta

	if Input.is_action_just_pressed("Main_Attack_Input") and can_input:
		inputed = true
	
	if player.can_be_knockbacked():
		return player.KnockBackState
	
	if inputed and not TimerSlash < 0 and not final_slash:
		if is_animation_finished:
			if player.is_on_floor():
				return NextSlashState
	
	elif TimerSlash < 0:
		if not back_to_downstate:
			#Time to do the save animation
			if time_to_time > 0:
				time_to_time -= delta
			else:
				time_to_time = 0
			player.AnimationTraveler.get("parameters/Idle_Slashes/playback").travel("SaveSword")
			
			#if time_to_time <= 0:
			if is_animation_finished:
				return player.RunState
		else:
			return player.DownState

	return null

func velocity() -> void:

	if not (Input.is_action_pressed("Left") and player.WallfloorLeft_raycast()) and \
		not (Input.is_action_pressed("Right") and player.WallfloorRight_raycast()):
		if not player.is_flipped():
			player.velocity.x = min(player.velocity.x + acceleration, velocity_speed)

		else:
			player.velocity.x = max(player.velocity.x - acceleration, -velocity_speed)

		if not Input.is_action_pressed("Left") and not Input.is_action_pressed("Right"):
			#Friction:
			if player.velocity.x > 0:
				player.velocity.x = max(player.velocity.x - friction, 0)

			if player.velocity.x < 0:
				player.velocity.x = min(player.velocity.x + friction, 0)
	else:
		player.velocity.x = 0

#IT DOESN'T RETURN STATEMAKER!!!
func set_animation_to_finished() -> void:
	is_animation_finished = true
