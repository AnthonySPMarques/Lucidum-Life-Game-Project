extends Slashs


@export_category("Bools")
@export var final_slash : bool = false
@export var idle_slash : bool = true
@export var down_slash : bool = false

@export_category("Strings")
@export var parameter : String = ""

@onready var animation_player: AnimationPlayer = %AnimationPlayer

var current_idle_animation_state = null
var current_down_animation_state = null

var get_idleslash_animation = null
var get_downslash_animation = null

@onready var slash_delay_timer: Timer = $"../../../Timers/SlashDelay"

var inputed : bool = false
var can_input : bool = false
var time_to_time #time to go idle and play save animation

var can_next_slash : bool = true

var is_animation_finished : bool = false
var goto_idle : bool = false #An animation_finished for savesword
var goto_down : bool = false

func enter() -> void:
	super()
	if player != null:
		get_idleslash_animation = %Animation_Traveler.get("parameters/Idle_Slashes/playback")
		get_downslash_animation = %Animation_Traveler.get("parameters/Down/playback")
	#%Meele_Hitbox.enable_clash_areas()
	
	if not final_slash:
		SoundEffects.play_sound(SoundEffects.SFX_SLASHBITE)
	else:
		SoundEffects.play_sound(SoundEffects.SFX_SLASHBITE3TH)
	
	is_animation_finished = false
	goto_idle = false
	goto_down = false
	can_next_slash = true
	
	player.velocity.x *= 0.5
	player.velocity.y *= 0
	
	if get_parent().player.is_small_area_on_water:
		if idle_slash and not down_slash:
			"Create bubble particle"
			Triggers.create_ParticleTrigger(
			#Particle Scene
			preload("res://Scenes/Triggers/FXs/Particles/0.tscn"),
			#Particle Posiiton
			get_parent().player.global_position + 
			Vector2(32 * get_parent().player.sprite.scale.x, -78),
			#Particle Scale
			Vector2(player.sprite.scale.x, 1),
			#Particle Material
			preload("res://tres/Materials/WaterBubbleDeepBlown.tres"),
			#Particle AmountRatio
			0.4);
			
		elif not idle_slash and down_slash:
			"Create bubble particle"
			Triggers.create_ParticleTrigger(
			#Particle Scene
			preload("res://Scenes/Triggers/FXs/Particles/0.tscn"),
			#Particle Posiiton
			get_parent().player.global_position + 
			Vector2(32 * get_parent().player.sprite.scale.x, -32),
			#Particle Scale
			Vector2(player.sprite.scale.x, 1),
			#Particle Material
			preload("res://tres/Materials/WaterBubbleDeepBlown.tres"),
			#Particle AmountRatio
			0.4);
			
			
	"Getters"
	if parameter != "":
		player.AnimationTraveler.get("parameters/"+parameter+"/playback").travel(str(name))
	else:
		#printerr("parameter has not declared in current state")
		breakpoint
	

func exit() -> void:
	
	%Meele_Hitbox.disable_clash_areas()
	%Meele_Hitbox.disable_all_collision_shapes()
	
	can_input = false
	inputed = false

	#get_node(Hitbox_Mask).disabled = true
	#if not self is Slashs:
	player.can_flip = true
	player.is_landing = false
	
func physics_process(delta: float) -> StateMaker:
	if player.is_on_slider:
		return player.OnSliderState
	inputed = Input.is_action_just_pressed("Main_Attack_Input")
	
	if get_idleslash_animation != null:
		current_idle_animation_state = get_idleslash_animation.get_current_node()
	if get_idleslash_animation != null:
		current_down_animation_state = get_downslash_animation.get_current_node()
	
	if not player.is_on_floor():
		player.velocity.y *= 0
		return player.FallState
	
	if Input.is_action_just_pressed("Dash") and player.can_dash:
		return player.DashState
	#if Input.is_action_just_pressed("Main_Attack_Input") and can_input:
	
	if player.is_on_semifloor():
		if Input.is_action_pressed("Down") and Input.is_action_just_pressed("Jump"):
			if (Input.is_action_pressed("Left") or Input.is_action_pressed("Right")):
				player.position.y += 4
				return player.FallState
				
			if !(Input.is_action_pressed("Left") and Input.is_action_pressed("Right")):
				player.position.y += 4
				return player.FallState
	else:
		if player.is_on_floor() and not \
		(%DownCeilRay_Left.is_colliding() or
		%DownCeilRay_Right.is_colliding()) and \
		not player.ceil_ray_is_colliding():
			
			if Input.is_action_just_pressed("Jump") or player.impulsed_by_spring:
				return player.JumpState
		
	if player.Has_AttackUp:
		if inputed and Input.is_action_pressed("Up") and is_animation_finished:
			return player.Current_AttackUp
		
	if inputed == true:
		if down_slash and is_animation_finished:
			return NextSlashState
		
	if not down_slash:
		if Input.is_action_pressed("Left") or Input.is_action_pressed("Right"):
			player.can_slash = false
			slash_delay_timer.start()
			return player.RunState
		
	
	if inputed and is_animation_finished and not final_slash:
		if current_idle_animation_state != "SaveSword" and \
			current_down_animation_state != "DownSaveSword":
			if can_next_slash:
				return NextSlashState
		else:
			if down_slash:
				return player.DownState
			else:
				return player.IdleState
	
	if player.is_immune == false:
		if not down_slash:
			%Hitbox.enable_DefaultHitbox()
		else:
			%Hitbox.enable_DownHitbox()
		
	player.can_flip = false
	
	if player.can_be_knockbacked():
		return player.KnockBackState
	
	#Can input after TimerInput ends
	if TimerInput <= 0:
		can_input = true
	else:
		can_input = false
		TimerInput -= delta
	
	
	#Countdown the timer
	TimerSlash -= delta

	
	if is_animation_finished == true:
		if not down_slash:
				
			#Time to do the save animation
			if inputed == false or final_slash == true:
				player.AnimationTraveler.get("parameters/"+parameter+"/playback").travel("SaveSword")
				if goto_idle == true:
					return player.IdleState
				
		else:
			if goto_down:
				return player.DownState

	return null
	

#IT DOESN'T RETURN STATEMAKER!!!
func set_animation_to_finished() -> void:
	is_animation_finished = true

func goto_idlestate() -> void:
	goto_idle = true

func goto_downstate() -> void:
	goto_down = true

func set_can_next_slash_false() -> void:
	can_next_slash = false
