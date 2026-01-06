extends StateMaker


@export_category("Velocity values")
@export
var MinSpringForce : float = 100
@export
var MaxSpringForce : float = 1400
@export var velocity_speed : float = 360.0 ##Velocidade do movimento
@export var acceleration : float = 40.0 ##Força da aceleração de movimento
@export var friction : float = 60.0 ##Força de atrito do movimento
@export var impulsed_gravity : float = 1.5 ##Esse valor será multiplicado pela atual gravidade do jogador enquanto ele estiver caindo

@onready var pogo_ray: RayCast2D = %PogoRay
@onready var pogo_hurter_mask: CollisionShape2D = %PogoMask

var pogonode : PackedScene = preload("res://Scenes/Objects/Actors/NPCs/interactive_non_living_characters/Vehiles/ElecPogo.tscn")

func enter() -> void:
	super()
	pogo_hurter_mask.disabled = false
	player.AnimationTraveler["parameters/InVehiles/Vehile/transition_request"] = "Pogo"

func exit() -> void:
	pogo_hurter_mask.disabled = true
	
func physics_process(delta: float) -> StateMaker:
	
	if player.velocity_is_to_up():
		player.AnimationTraveler["parameters/InVehiles/Pogo/playback"].travel("OnPogoUp")
	else:
		player.AnimationTraveler["parameters/InVehiles/Pogo/playback"].travel("OnPogoDown")
		
	if Input.is_action_just_pressed("Jump") and\
	Input.is_action_pressed("Up"):
		
		var pogoi = pogonode.instantiate() as ElecPogo
		pogoi.global_position = player.global_position
		pogoi.pow_ground()
		get_parent().add_child(pogoi)
		
		if !Input.is_action_pressed("Dash"):
			return player.JumpState
		else:
			return player.DashJumpState
	
	#Give player movement values:
	velocity()
	player.velocity.y += ((player.Gravity + 1600) * delta) * impulsed_gravity
	
	if player.can_be_knockbacked():
		var pogoi = pogonode.instantiate() as ElecPogo
		pogoi.global_position = player.global_position
		pogoi.pow_ground()
		get_parent().add_child(pogoi)
		return player.KnockBackState
	
	if pogo_ray.is_colliding() and player.velocity.y > 0:
		pogo()
	
	if Input.is_action_pressed("Jump") and pogo_ray.is_colliding():
		pogo_power()
		
	if Input.is_action_pressed("Jump") and Input.is_action_just_pressed("Down"):
		pogo_down()
	
	if Input.is_action_just_released("Jump") and player.velocity.y < 0:
		player.velocity.y *= 0.4
		
	if name == "OnPogo":
		if Input.is_action_pressed("Dash"):
			%Trail.can_trail = true
			return player.OnPogoDash
		
	if name == "OnPogoDash":
		if !Input.is_action_pressed("Dash"):
			%Trail.can_trail = false
			return player.OnPogo
		
	return null
	
func velocity() -> void:
	
	#Input
	var is_left = Input.is_action_pressed("Left") and !Input.is_action_pressed("Right")
	var is_right = Input.is_action_pressed("Right") and !Input.is_action_pressed("Left")
	
	if not (Input.is_action_pressed("Left") and player.WallfloorLeft_raycast()) and \
		not (Input.is_action_pressed("Right") and player.WallfloorRight_raycast()):
		if is_right:
			player.velocity.x = min(player.velocity.x + acceleration, velocity_speed)

		elif is_left:
			player.velocity.x = max(player.velocity.x - acceleration, -velocity_speed)

		else:
			#Friction:
			if player.velocity.x > 0:
				player.velocity.x = max(player.velocity.x - friction, 0)

			if player.velocity.x < 0:
				player.velocity.x = min(player.velocity.x + friction, 0)
	else:
		player.velocity.x = 0
	
func pogo() -> void:
	SoundEffects.play_sound(39)
	Triggers.create_VisualEffectTrigger(5, pogo_ray.get_collision_point())
	player.velocity.y = -MinSpringForce 
	if player.impulsed_by_spring:
		player.velocity = player.Velocity_Impulse
	
func pogo_power() -> void:
	SoundEffects.play_sound(40)
	player.velocity.y = -MaxSpringForce
	if player.impulsed_by_spring:
		player.velocity = player.Velocity_Impulse
	
func pogo_down() -> void:
	player.velocity.y = MaxSpringForce*impulsed_gravity
	
