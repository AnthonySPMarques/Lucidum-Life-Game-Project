extends StateMaker

@onready var Timer_idle_to_stare_screen: Timer = %IdleToStareScreen
@export var Time_To_Creepy : float = 1.0

var is_petting : bool = false
var has_been_petted : bool = false

############
#FUNCTIONS:#
func enter() -> void: #When the player enters into this state:
	super()
	#player.get_moving_platform = null
	player.impulsed_by_spring = false
	player.can_flip = false
	if !player.is_on_floor():
		player.can_climb = false
	Timer_idle_to_stare_screen.start(Time_To_Creepy)
	
	if player.floor_snap_length == 0:
		player.enable_snap_floor()
	
	#%Mask.disabled = false
	#%MaskDown.disabled = true
	
	%Trail.can_trail = false
	
	%Meele_Hitbox.disable_clash_areas()
	
	if !player.is_immune:
		%Hitbox.enable_DefaultHitbox()
	else:
		%Hitbox.disable_hitboxes()
	
	#Enable Normal Mask
#	if player.is_immune == false:
#		$"%Hitbox".enable_DefaultHitbox()
	player.AnimationTraveler[
		"parameters/Current_Animation_State/transition_request"
	] = "Landing" if player.is_landing else "Idle"
	

	#give player starting velocity
	player.velocity = Vector2.ZERO

func exit() -> void:
	is_petting = false
	has_been_petted = false
	player.can_flip = true
	#Toogle off idle land
	player.is_landing = false
	pass

func meow() -> void:
	SoundEffects.play_sound(SoundEffects.SFX_MEOW)

func physics_process(delta: float) -> StateMaker:
	if player.is_on_slider:
		return player.OnSliderState
	
	player.AnimationTraveler[
		"parameters/Current_Animation_State/transition_request"
	] = "IdleTired" if player.UI.is_health_rigid else "Idle"
	
	#Go dash
	#if (player.Pressed_Times_L == 2 or player.Pressed_Times_R == 2):
		#return player.DashState
		
	if player.can_be_knockbacked():
		return player.KnockBackState
	
	if player.is_immune == false:
		%Hitbox.enable_DefaultHitbox()
	
	if !player.is_on_floor():
		#Make player fall faster
		player.velocity.y += (player.Gravity * delta) + 100
		if !player.can_climb:
			return player.FallState
		else:
			if Input.is_action_pressed("Down") and !Input.is_action_pressed("Up"):
				if player.check_ladder_trap():
					print("aaa")
					return player.ClimbStartState
				
	else:
		
		if player.can_move:
			if Input.is_action_just_pressed("Dash") and player.can_dash:
				return player.DashState
			if not (Input.is_action_pressed("Left") and Input.is_action_pressed("Right")):
				if Input.is_action_pressed("Left") or Input.is_action_pressed("Right"):
					if (Input.is_action_pressed("Left") and player.WallfloorLeft_raycast()) or \
					(Input.is_action_pressed("Right") and player.WallfloorRight_raycast()):
						return null
					return player.RunState

	if player.can_climb:
		if (Input.is_action_pressed("Up") and player.is_on_floor()) or \
		(Input.is_action_pressed("Down") and player.check_ladder_trap()):
			return player.ClimbState
			
	if player.check_ladder_trap() and \
	(Input.is_action_pressed("Down") and \
	!Input.is_action_pressed("Up")):
		player.velocity.y = 300
		return player.ClimbStartState
		
		
	if not Input.is_action_pressed("Down") and \
	Input.is_action_just_pressed("Special") \
	and player.MeeleHitbox.is_slash_charged:
		return player.ChargedSlashState
	elif Input.is_action_just_pressed("Main_Attack_Input") and not Input.is_action_pressed("Alt_Attack_Input"):
		if player.can_slash:
			return player.IdleSlash1State
	
	if player.AnimationTraveler.get("parameters/Idle/playback").get_current_node() == "Idle_BORAPORRA":
		if player.Is_cursor_inside_PetClickZone() and Input.is_action_pressed("Mouse_L"):
			is_petting = true
			
			
	if !player.Is_cursor_inside_PetClickZone() or !Input.is_action_pressed("Mouse_L"):
		is_petting = false
		
	if is_petting == true:
		
		if not SoundEffects.is_sound_playing(SoundEffects.SFX_PURR):
			SoundEffects.play_sound(SoundEffects.SFX_PURR)
		%Animation_Traveler["parameters/Idle/playback"].travel("Idle_Pet_Purr_Blush")
		has_been_petted = true
		
	else:
		if SoundEffects.is_sound_playing(SoundEffects.SFX_PURR):
			SoundEffects.stop_sound(SoundEffects.SFX_PURR)
				
		if has_been_petted == true:
			%Animation_Traveler["parameters/Idle/playback"].travel("Idle")
			has_been_petted = false
			
	if not player.check_ladder_trap():
		if Input.is_action_pressed("Down") \
		and not player.check_ladder_trap() and player.is_on_floor() and \
		not Input.is_action_pressed("Alt_Attack_Input"):
			if not Input.is_action_pressed("Jump"):
				return player.DownState
		
	return null


func input(_event: InputEvent) -> StateMaker: #Functions for inputs:
	
	#Meow
	if Input.is_action_pressed("Taunt") and Input.is_action_pressed("Up"):
		%Animation_Traveler["parameters/Idle/playback"].travel("IdleMeows")
		
	#Door
	if player.is_on_door:
		if Input.is_action_just_pressed("Down") or Input.is_action_just_pressed("Up"):
			return player.EnteringDoorState
	
	#Shake
	if player.is_wet and Input.is_action_pressed("Alt_Attack_Input") \
	and Input.is_action_just_pressed("Down"):
			return player.ShakeWaterState
	
	
	
	if player.impulsed_by_spring:
		return player.JumpState
		
	if Input.is_action_just_pressed("Jump") or player.impulsed_by_spring:
		if Input.is_action_pressed("Dash"):
			return player.DashJumpState
			
		if Input.is_action_just_pressed("Main_Attack_Input"):
			return player.AirSlashState
		
		return player.JumpState

	if player.Has_AttackUp:
		if Input.is_action_just_pressed("Main_Attack_Input"):
			if Input.is_action_pressed("Up"):
				return player.Current_AttackUp
			
	

	return null


func _on_stare__to_screen_timeout() -> void:
	player.AnimationTraveler["parameters/Idle/playback"].travel("Idle_You")

func play_SFX_Purr() -> void:
	SoundEffects.play_sound(SoundEffects.SFX_PURR)
