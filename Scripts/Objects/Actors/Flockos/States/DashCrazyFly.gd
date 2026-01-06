extends Slashs

@export_category("Velocity values")
@export var Velocity_speed : float = 60

@export_category("Timers")
@export var time_adder : float = 0.1

var bounce_vector : Vector2
var percent : float = 1.0

func enter() -> void:
	super()
	
	TimerSlash = Attack_Duration
	TimerInput = Time_ToInput
	
	player.SFX_saw_pit.play()
	
	player.is_crazying_fly = true
	player.can_crazy_fly = false

	player.mask_b.disabled = false
	player.hitbox_mask.disabled = true
	
	if not player.is_flipped():
		if not Input.is_action_pressed("Up"):
			bounce_vector = Vector2(Velocity_speed, Velocity_speed)
		else:
			bounce_vector = Vector2(Velocity_speed, -Velocity_speed)
	else:
		if not Input.is_action_pressed("Up"):
			bounce_vector = Vector2(-Velocity_speed, Velocity_speed)
		else:
			bounce_vector = Vector2(-Velocity_speed, -Velocity_speed)

	
	#Hitbox_Mask.disabled = false
	#Set default variables

func exit() -> void:
	
	player.SFX_saw_pit.stop()

	player.velocity = Vector2.ZERO
	player.MeeleHitbox.disable_clash_areas()
	
	player.can_crazy_fly = false

	player.mask_b.disabled = true
	player.hitbox_mask.disabled = false
	player.MeeleHitbox.is_persistent_mask_colliding = false

	#avoiding coyote time works in jump state
	#Hitbox_Mask.disabled = true

func physics_process(delta: float) -> StateMaker:

	TimerSlash = clamp(TimerSlash, 0, Attack_Duration)
	
	if Input.is_action_just_pressed("Main_Attack_Input") and Input.is_action_pressed("Down") \
	and not Input.is_action_pressed("Alt_Attack_Input"):
		return player.AvoiderDownState
	
	percent = clamp(percent, 0, Velocity_speed*2)
	
	if %CrazyFly_Box.get_overlapping_bodies().size() > 0:
		
		if percent < (Velocity_speed*2):
			percent += 2
	
		percent = lerp(percent, 0.50, 0.25)
		if TimerSlash < Attack_Duration:
			increase_time(time_adder)
	else:
		percent = lerp(percent, 1.00, 0.25)
	
	if player.can_be_knockbacked():
		return player.KnockBackState
	
	#Countdown the timer
	if TimerSlash > 0:
		TimerSlash -= delta
	else:
		if !player.is_on_floor():
			return player.DashFallState
		return player.IdleState


	if player.can_climb:
		if Input.is_action_pressed("Up") or Input.is_action_pressed("Down") and !player.is_on_floor():
			return player.ClimbState

	#apply movement
	var info_collision = player.move_and_collide(bounce_vector * delta * percent)

	if info_collision:
		bounce_vector = bounce_vector.bounce(info_collision.normal)

	return null

func increase_time(time: float) -> void:
	TimerSlash += time
	TimerSlash = clamp(TimerSlash,0 ,Attack_Duration)
