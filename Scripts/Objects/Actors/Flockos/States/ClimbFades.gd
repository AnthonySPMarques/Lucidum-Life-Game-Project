extends StateMaker

enum Is {entering, exiting}
@export var is_ : Is = Is.entering

@export var climb_end_duration : float = 0.2
var ClimbTimer

var get_animation

const SNAP_PARENT : float = 64.0
const SNAP_CENTER_X : float = 32.0

func enter() -> void:
	super()
	ClimbTimer = climb_end_duration
	
	if player != null:
		get_animation = %Animation_Traveler.get("parameters/Climbs/playback")
	snap_center()
	player.is_climbing = true
	
	if player.is_immune == false:
		if !is_ == Is.exiting:
			$"%Hitbox".enable_DefaultHitbox()
		else:
			$"%Hitbox".enable_DownHitbox()
			
	
	#player.velocity.y = 0

	print("is_ =", is_)
	if is_ == Is.entering:
		player.AnimationTraveler[
			"parameters/Climbs/ClimbStarts/ClimbStarting/transition_request"
			] = "Enter"
		player.position.y += 4
	else:
		player.can_climb = false
		player.AnimationTraveler["parameters/Climbs/playback"
		].travel("ClimbEnd")

func exit() -> void:
	super()
	player.is_climbing = false
	player.position.y -= 1
	player.ladder_node = null
	player.is_landing = false
	
	if is_ == Is.entering:
		player.can_climb = true
	

func snap_center() -> void:
	var center_checker = snappedf(player.position.x, SNAP_PARENT)
	if player.position.x < center_checker:
		player.position.x = center_checker - SNAP_CENTER_X;
	if player.position.x > center_checker:
		player.position.x = center_checker + SNAP_CENTER_X;

func physics_process(delta: float) -> StateMaker:
	print("climb timer = ", ClimbTimer)
	if is_ == Is.entering:
		player.velocity.y = 300
	
	if player.is_immune == false:
		%Hitbox.enable_DefaultHitbox()
	
	var current_animation_state = get_animation.get_current_node()
	
	if player.ladder_node != null:
		player.global_position.y = lerp(player.global_position.y, \
		player.ladder_node.global_position.y, 0.5)
		
	if player.can_be_knockbacked():
		return player.KnockBackState
	
	if ClimbTimer > 0:
		ClimbTimer -= delta
	else:
		if is_ == Is.entering:
		#if current_animation_state == "Climb" and is_ == Is.entering:
			return player.ClimbState
		if is_ == Is.exiting:
			if player.is_on_floor():
				return player.IdleState
			else:
				return player.FallState
		
	return null
