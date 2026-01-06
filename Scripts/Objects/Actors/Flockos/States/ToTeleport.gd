extends StateMaker

var goto_TeleportToIdle = false
var goto_Idle = false

func enter() -> void:
	super()
	player.can_flip = false
	player.is_sprite_flipped = false
	if name == "ToTeleport":
		enterin()
	else:
		player.is_on_NIGHTMARE_TRAVEL = true
		enterout()
	
func exit() -> void:
	player.can_flip = true
	goto_TeleportToIdle = false
	goto_Idle = false

func enterin() -> void:
	player.UI.hide()
func enterout() -> void:
	TransitionFaders.set_animation_fader("WhiteIn")
	player.UI.show()

	
func physics_process(_delta: float) -> StateMaker:
	CameraZonesManager.Current_camerazone.set_zoom(player.ZoomScale)
	if goto_TeleportToIdle and self == player.ToTeleport:
		return player.TeleportToIdle
	if goto_Idle and self == player.TeleportToIdle:
		return player.IdleState
	return null

#Call screen transition
func shine_transition() -> void:
	TransitionFaders.set_animation_fader("StrongShine")
	await TransitionFaders.Transition_Animation_Finished
	play_transition_cutscene()

#Func to play cutscene video
func play_transition_cutscene() -> void:
	%FlockosTravelAnimation.play_video()

#Func to return idle when animation is end
func _on_flockos_travel_animation_cutscene_finished() -> void:
	print("cus")
	if self == player.ToTeleport: 
		print("custt")
		goto_TeleportToIdle = true
	if self == player.TeleportToIdle:
		print("custti")
		goto_Idle = true
