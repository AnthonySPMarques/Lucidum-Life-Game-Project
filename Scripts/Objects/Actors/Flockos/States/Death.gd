extends StateMaker

#@export var time_to_restart : float = 8.0

@export var color_fade : Color = Color.WHITE_SMOKE

var return_start_state : bool = false

const PHANTOM_CAMERA_INSTANT_TWEEN = preload("res://tres/PhantomCameraInstantTween.tres")


func enter() -> void:
	super()
	if player.current_start_point.name == "PointStart" or player.checkpoint_is_marked == true:
		player.Start_Scene_By = player.Entering_Scene_Transition.Thunder_Wrap
	
	TransitionFaders.set_animation_fader("WhiteIn")
	#lose a chance
	player.UI.Chances -= 1
	
	return_start_state = false
	player.can_flip = false
	
	SoundEffects.play_sound(SoundEffects.SFX_KNOCKBACK)
	SoundEffects.play_sound(SoundEffects.SFX_MEOW_DEATH)
	##Disable all sfxs besides death sfx
	AudioServer.set_bus_mute(1, true)

	GlobalEngine.change_gamespeed(0.3, 0.3)
	
	#player.AnimationTraveler.set("parameters/IS_DEAD/transition_request", "Yes")
	
	##Disconnect signals from player to avoid issues when freeing nodes
	if player.UI.signal_when_health_is_over.is_connected(player.die):
		player.UI.signal_when_health_is_over.disconnect(player.die)
	if player.EnteringDoorState.goto_destination.is_connected(player._on_EnteringDoor_goto_destination):
		player.EnteringDoorState.goto_destination.disconnect(player._on_EnteringDoor_goto_destination)
	#if TransitionFaders.Transition_Animation_Finished.is_connected(player.next_area):
		#TransitionFaders.Transition_Animation_Finished.disconnect(player.next_area.bind(player.area.scene))
		#
	
	##Make cameras instant move to initial pos:
	for phantoms in CameraZonesManager.Phantoms_Children:
		phantoms.set_tween_resource(PHANTOM_CAMERA_INSTANT_TWEEN)
	
		
func exit() -> void:
	
		#p.global_position =
		
	#Heal player only if dead, not when it changes of level.
	player.UI.change_Current_Health_Value(player.Player_Data.Max_Health)
	#splayer.is_dead = false
	player.Hitted = false
	if player.UI.Chances <= 0:
		player.UI.Chances = player.UI.MaxChances
	
	
func restart_level() -> void:
	#player.AnimationTraveler.set("parameters/IS_DEAD/transition_request", "No")
	TransitionFaders.set_animation_fader("CloseEye")
	##TIMER##
	var timer_caseiro = Timer.new()
	TemporaryNodes.add_child(timer_caseiro)
	timer_caseiro.one_shot = true
	timer_caseiro.start(0.8)
	
	await timer_caseiro.timeout
	CameraZonesManager.reset_cameras_pos()
	
	timer_caseiro.queue_free()
	
	player.restart_level()
	
