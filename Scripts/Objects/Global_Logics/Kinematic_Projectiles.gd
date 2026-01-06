@icon("res://Sprites/ToEditor/Class_Icons.png")
class_name Kinematic_Projectiles extends CharacterBody2D

@export var Visibility_Mask : VisibleOnScreenNotifier2D

#@export var Owner : String = "Player"

@export var Speed : float = 0.0
@export_range(0.000, 1.000) var SpeedRatio : float = 1.0
@export var Friction : float = 0.0
@export var Gravity : float = 0.0
@export var Damage : float = 0.0
@export_range(0.0, 360.0) var Angle : float = 0.0

enum Enum_Projectiles {Bullet, Target_Follower, Diagonal, Linear}
@export var Projectile_Type : Enum_Projectiles = Enum_Projectiles.Bullet

#Target
var enemie = null
var current_target = null
var direction : int = 1

signal kill_cause

func _enter_tree() -> void:
	if is_instance_valid(self):
		#self.add_to_group(Owner, true)
		Visibility_Mask.screen_exited.connect(kill)
	
	if Projectile_Type == Enum_Projectiles.Linear:
		velocity.x = Speed
	
func _physics_process(delta: float) -> void:
	if Visibility_Mask == null:
		printerr("Visibility mask has not added to node")
		breakpoint
	
	if Gravity != 0:
		velocity.y += Gravity
	match Projectile_Type:
		Enum_Projectiles.Bullet:
			_Bullet_Behavior(direction)
		Enum_Projectiles.Target_Follower:
			_Target_Follower_Behavior(current_target, delta)
		Enum_Projectiles.Diagonal:
			_Diagonal_Behavior(Angle)
		Enum_Projectiles.Linear:
			_Linear_Behavior(Speed, Friction)

func _Bullet_Behavior(dir: int) -> void:
	move_and_slide()
	velocity.x = (Speed * dir) * SpeedRatio
	
	
	
func get_direction(angle: int) -> Vector2:
	var vector_from_angle = Vector2(cos(deg_to_rad(angle)),
	sin(deg_to_rad(angle)))
	
	return vector_from_angle
	
func _Diagonal_Behavior(angle) -> void:
	velocity = get_direction(angle) * Speed
	
func _Target_Follower_Behavior(target: Node2D, Delta: float) -> void:
	if target == null:
		position += Speed * Vector2.RIGHT.rotated(rotation) * Delta
	else:
		if is_instance_valid(enemie[0]):
			follow_enemy(enemie[0], Delta)
			
func follow_enemy(target: Node2D, Delta) -> void:
	look_at(target.global_position)
	position = position.move_toward(target.global_position, Speed * Delta)

func _Linear_Behavior(Linear_Speed, Linear_Friction) -> void:
	velocity.x = Linear_Speed
	velocity.x = max(velocity.x - Linear_Friction * 0.1, 0)

func kill() -> void:
	if is_instance_valid(self):
		if self.has_signal("kill_cause"):
			emit_signal("kill_cause")
		self.call_deferred("queue_free")
