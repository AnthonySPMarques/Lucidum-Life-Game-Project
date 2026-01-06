extends StateMaker

@export var flip_x : bool = false
#@export var Time_to_wait : float = 0.0 ##Tempo para chegar ao idle state

var timer_to_count : float ##To go idle

var get_cameramanager : CameraZonesManager

var get_current_level : Node2D

@onready var persistent_mask: CollisionShape2D = $"../../Areas2Ds/PersistentBox/PersistentMask"


#player dont die for the 2nd time
#phantom camera not reset pos

func enter() -> void:
	player.is_impulsed_by_forces = false
	
	
	
	
	player.clear_trail()
	player.is_dead = false
	%Trail.can_trail = false
	persistent_mask.disabled = true ##<- just to pass through level passers
	super()
	TransitionFaders.set_animation_fader("OpenEye")
	player.first_position = \
	GlobalEngine.GamePlayer.Universe_2D_Trigger.current_level.EntracesMarker.get_child(0).global_position#global_position
	
	#get_current_scene = GamePlayerTrigger.current_Scene2D
	
	player.velocity *= 0
	print("from intro.gd ", player.Start_Scene_By)
	#Set start transition
	match player.Start_Scene_By:
		player.Entering_Scene_Transition.Thunder_Wrap:
			timer_to_count = 1.6
			AnimationCurrentTransition= "Start"
			player.global_position = player.first_position
			SoundEffects.play_sound(SoundEffects.SFX_THUNDERINTRO)
			
		player.Entering_Scene_Transition.WalkingLeft:
			timer_to_count = 0.8
			AnimationCurrentTransition= "Walk"
			flip_x = true
			player.velocity.x = -player.RunState.velocity_speed/2
		
		player.Entering_Scene_Transition.WalkingRight:
			timer_to_count = 0.8
			AnimationCurrentTransition= "Walk"
			flip_x = false
			player.velocity.x = player.RunState.velocity_speed/2

	player.AnimationTraveler["parameters/Current_Animation_State/transition_request"] = AnimationCurrentTransition
	
	#Store current scene and cameramanager nodes
	#if get_current_level is LevelLogic:
		#if get_current_level.CameraManager != null:
			#get_cameramanager = get_current_level.CameraManager
		#else:
			#printerr("[LevelLogic.gd] -var-> CameraManager = null")
	
	#Update CameraZoneManager array appends by calling a func
	#if get_cameramanager is CameraZonesManager:
		#get_cameramanager.update_appends()
	
	##timer_to_count = Time_to_wait
	player.is_sprite_flipped = flip_x
	
	%FlashHitTree["parameters/playback"].travel("RESET_respawn")
	
	
	
	AudioServer.set_bus_mute(1, false)
	
	player.can_flip = false
	player.is_immune = true
	%Meele_Hitbox.disable_clash_areas()
	%Meele_Hitbox.disable_all_collision_shapes()
	%Hitbox.disable_hitboxes()
	
func exit() -> void:
	persistent_mask.disabled = false
	player.is_immune = false
	player.hitbox.enable_DefaultHitbox()
	
	##Return each previous phantom resource to the currents one.
	for phantoms in \
	GlobalEngine.GamePlayer.Universe_2D_Trigger.current_level.CameraManager.Phantoms_Children:
		if is_instance_valid(phantoms):
			phantoms.set_tween_resource(
				CameraZonesManager.Phantoms_Resources[phantoms.get_index()]
				)
		
	
func process(delta) -> StateMaker:
	
	
	
	if timer_to_count > 0:
		timer_to_count -= delta
	else:
		return player.IdleState
		
	return null
