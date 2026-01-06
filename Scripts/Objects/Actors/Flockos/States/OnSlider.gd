extends StateMaker

const FLOCKOS_CHARACTER_BODY_2D_CAPSULE_MASK = preload("uid://cx2ipw1ner7l8")
const FLOCKOS_CHARACTER_BODY_2D_RECTANGLE_MASK = preload("uid://bhxaeuwbqip5n")

@export var Main_ImpulseY : float = 1100.0 ##Força do pulo
@export var Acceleration : float = 40.0 ##Força da aceleração de movimento
@export var Friction : float = 60.0 ##Força de atrito do movimento

var SliderBody : SliderBody2D = null
var velocity_impulse : Vector2 = Vector2.ZERO

var friction : float
var acceleration : float

var get_last_sliderbody_speed : float

var floor_angle :float= 0.0

func enter() -> void:
	super()
	player.persistent_mask.disabled = true
	get_last_sliderbody_speed = 0
	%RoughSpark.emitting = true
	#%Mask.shape = FLOCKOS_CHARACTER_BODY_2D_CAPSULE_MASK
	player.floor_max_angle = deg_to_rad(180)
	#player.floor_constant_speed = true
	player.floor_block_on_wall = false
	player.floor_snap_length = 32
	
	friction = Friction
	acceleration = Acceleration
	
	player.can_flip = false
	player.is_sliding = true
	
func exit() -> void:
	
	player.persistent_mask.disabled = false
	
	#%Mask.shape = FLOCKOS_CHARACTER_BODY_2D_RECTANGLE_MASK
	player.floor_max_angle = deg_to_rad(player.CURRENT_MAX_ANGLE)
	player.floor_constant_speed = false
	player.floor_block_on_wall = true
	%RoughSpark.emitting = false
	###Fix velocity dir
	#if player.is_sprite_flipped and velocity_impulse.x > 0:
		#velocity_impulse.x *= -1
	#if not player.is_sprite_flipped and velocity_impulse.x < 0:
		#velocity_impulse.x *= 1
		
	player.disable_snap_floor()
	player.is_impulsed_by_forces = true
	#player.velocity += velocity_impulse
	
	player.can_flip = true
	player.is_sliding = false
	Triggers.CreateTweenProperty(player.sprite, "rotation",0,
	0.3, Tween.EASE_OUT, Tween.TRANS_SINE)
	Triggers.CreateTweenProperty(player.main_mask, "rotation",0,
	0.3, Tween.EASE_OUT, Tween.TRANS_SINE)
	
	
	
func physics_process(delta: float) -> StateMaker:
	
	print("velocity impulse = ", velocity_impulse)
	
	if (player.is_on_floor() or player.is_on_slider):
		floor_angle = player.get_floor_normal().angle()
		
	if SliderBody != null:
		player.is_sprite_flipped = SliderBody.SliderSpeed < 0
		
		##If try to brake
		if (player.is_sprite_flipped and Input.is_action_pressed(&"Right")) or \
		(!player.is_sprite_flipped and Input.is_action_pressed(&"Left")):
			velocity_impulse.x = SliderBody.SliderSpeed/4
			#player.velocity.x = SliderBody.SliderSpeed/4
			if SliderBody.SliderSpeed < 0:
				player.velocity.x = min(player.velocity.x + friction, SliderBody.SliderSpeed/2)
			if SliderBody.SliderSpeed > 0:
				player.velocity.x = max(player.velocity.x - friction, SliderBody.SliderSpeed/2)

			#player.move_local_x(SliderBody.SliderSpeed/12)
		else:
			velocity_impulse.x = SliderBody.SliderSpeed
			if SliderBody.SliderSpeed < 0:
				player.velocity.x = max(player.velocity.x - acceleration, SliderBody.SliderSpeed)
			if SliderBody.SliderSpeed > 0:
				player.velocity.x = min(player.velocity.x + acceleration, SliderBody.SliderSpeed)
			#player.velocity.x = SliderBody.SliderSpeed
			#player.move_local_x(SliderBody.SliderSpeed/4)
		
		if player.is_on_floor_only():
			#player.floor_snap_length
			Triggers.CreateTweenProperty(player.sprite, "rotation", player.get_floor_normal().angle()+deg_to_rad(90),
			delta, Tween.EASE_OUT, Tween.TRANS_CIRC)
			Triggers.CreateTweenProperty(player.main_mask, "rotation", player.get_floor_normal().angle()+deg_to_rad(90),
			delta, Tween.EASE_OUT, Tween.TRANS_CIRC)

		else:
			Triggers.CreateTweenProperty(player.sprite, "rotation",0,
			delta, Tween.EASE_IN_OUT, Tween.TRANS_EXPO)
			Triggers.CreateTweenProperty(player.main_mask, "rotation",0,
			delta, Tween.EASE_IN_OUT, Tween.TRANS_EXPO)

			
	if Input.is_action_pressed("Jump"):
		player.velocity.y -= Main_ImpulseY*2
		player.velocity.x += get_last_sliderbody_speed/2
		return player.JumpState
		#return player.JumpState
		#return player.ImpulsedState
	#If not jumped
	elif !player.is_on_slider or !player.is_on_floor():
		
		#player.velocity.y -= Main_ImpulseY*Vector2.from_angle(floor_angle).y*delta
		player.velocity.x += get_last_sliderbody_speed
		print("player.velocity.y = ", player.velocity.y)
		return player.FallState
		#return player.ImpulsedState
	#if Input.is_action_just_pressed("Jump") or player.velocity.y > 0:
		#if Input.is_action_pressed("Dash"):
			#return player.DashJumpState
		#else:
			#return player.JumpState
	#else:
		#if not player.is_on_slider and not player.is_on_floor():
			#if Input.is_action_pressed("Dash"):
				#return player.DashFallState
			#else:
				#return player.FallState
	
	return null

func _on_sliderbody(body: Node2D) -> void:
	if body is SliderBody2D:
		SliderBody = body
		get_last_sliderbody_speed = SliderBody.SliderSpeed

func _out_of_sliderbody(body: Node2D) -> void:
	if body is SliderBody2D:
		SliderBody = null
