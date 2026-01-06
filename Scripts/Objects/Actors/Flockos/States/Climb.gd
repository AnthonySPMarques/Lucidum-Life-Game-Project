extends StateMaker

@export var Climb_Speed : float = 0.0

@onready var get_animation
@onready var ladder_box: Area2D = %LadderBox

const SNAP_PARENT : float = 64.0
const SNAP_CENTER_X : float = 32.0
const SNAP_CENTER_Y : float = 16.0

var is_on_top : bool = false

func enter() -> void:
	super()
	if player != null:
		get_animation = %Animation_Traveler.get("parameters/Climbs/playback")
		
	player.is_climbing = true
	
	player.can_hang_top_solid = false
	
	if not ladder_box.area_entered.is_connected(when_is_on_top):
		ladder_box.area_entered.connect(when_is_on_top)
	
	player.can_crazy_fly = true
	
	if player.is_immune == false:
		%Hitbox.enable_DefaultHitbox()
	is_on_top = false
	player.can_air_dash = true
	snap_center()
	player.velocity.x = 0
	
	"Setters"
	player.AnimationTraveler[
			"parameters/Climbs/ClimbStarts/ClimbStarting/transition_request"
			] = "Grab"
	
	"Getters"
	player.AnimationTraveler["parameters/Climbs/playback"].travel("Climb")
	
	player.can_flip = false
	
func exit() -> void:
	player.is_climbing = false
	
	player.can_flip = true
	
	#if get_parent().Default_State == player.ClimbSlashState:
		#player.AnimationTraveler["parameters/Current_Animation_State/transition_request"]
	#else:
		#player.AnimationTraveler["parameters/Current_Animation_State/transition_request"]
	
	
func snap_center() -> void:
	var center_checker = snappedf(player.position.x, SNAP_PARENT)
	if player.position.x < center_checker:
		player.position.x = center_checker - SNAP_CENTER_X;
	if player.position.x > center_checker:
		player.position.x = center_checker + SNAP_CENTER_X;


func input(_event: InputEvent) -> StateMaker:

	if Input.is_action_just_pressed("Main_Attack_Input"):
		player.AnimationTraveler["parameters/TimeScale/scale"] = 1
		if Input.is_action_pressed("Left"):
			player.is_sprite_flipped = true
		elif Input.is_action_pressed("Right"):
			player.is_sprite_flipped = false
		player.velocity.y = 0
		return player.ClimbSlashState
	
	return null

func process(_delta: float) -> StateMaker:
	
	var current_animation_state = get_animation.get_current_node()

	if not is_on_top:
		#Uping
		if not Input.is_action_pressed("Special"):
			if Input.is_action_pressed("Up") and not Input.is_action_pressed("Down"):
				
				player.AnimationTraveler["parameters/TimeScale/scale"] = 1
				player.AnimationTraveler.get("parameters/Climbs/playback").travel("Climb")
				
				player.velocity.y = -Climb_Speed
			
			#Downing
			elif not Input.is_action_pressed("Up") and Input.is_action_pressed("Down"):
				
				player.AnimationTraveler["parameters/TimeScale/scale"] = 1
				player.AnimationTraveler.get("parameters/Climbs/playback").travel("DowningClimb")
				
				player.velocity.y = Climb_Speed
				
			else:
				player.AnimationTraveler.get("parameters/Climbs/playback").travel("Climb")
				player.velocity.y = 0
				if current_animation_state == "Climb" and (get_animation.get_current_play_position() >= 0 or
				get_animation.get_current_play_position() <= 0.1):
					player.AnimationTraveler["parameters/TimeScale/scale"] = 0
	else:
		return player.ClimbEndState
	

	if player.is_small_area_on_water and player.velocity.y != 0:
		"Create bubble particle"
		Triggers.create_ParticleTrigger(
		#Particle Scene
		preload("res://Scenes/Triggers/FXs/Particles/0.tscn"),
		#Particle Posiiton
		player.PivotCenter.global_position,
		#Particle Scale
		Vector2.ONE,
		#Particle Material
		preload("res://tres/Materials/WaterBubbleDeep.tres"),
		#Particle AmountRatio
		0.05);
	
	
	if player.is_immune == false:
		%Hitbox.enable_DefaultHitbox()
	
	if player.can_be_knockbacked():
		return player.KnockBackState
	
#	if player.can_climb == false and Input.is_action_pressed("Up"):
#		player.velocity.y = 0
#
#		#Snap up
##		var center_checker = stepify(player.position.y, SNAP_PARENT)
##		player.position.y = center_checker - SNAP_CENTER_Y;
#
#		return ClimbEndState

	if player.can_climb == false || player.is_on_floor() and Input.is_action_pressed("Down"):
		player.velocity.y = 0
		return player.IdleState
	
	if Input.is_action_just_pressed("Jump") and not Input.is_action_pressed("Up"):
		if not Input.is_action_pressed("Down"):
			if not Input.is_action_pressed("Dash"):
				if not Input.is_action_pressed("Up") and not Input.is_action_pressed("Down"):
					return player.JumpState
			else:
				return player.DashJumpState
		else:
			if not Input.is_action_pressed("Dash"):
				return player.FallState
			else:
				return player.DashFallState

	return null



func when_is_on_top(area: Area2D):
	if area.is_in_group("TopLadders") and get_parent().Default_State == self:
		player.velocity.y = 0
		player.ladder_node = area
		player.AnimationTraveler.get("parameters/Climbs/playback").travel("ClimbEnd")
		is_on_top = true
	return null
