extends EnemyStateMaker

@export_category("States")
@export var ShootPlayer : EnemyStateMaker

@export_category("General properties")
@export var Time_ToGo_ShootPlayer :float= 4.0

@export_category("Velocity values")
@export var velocity_speed : float = 350.0 ##Velocidade do movimento
@export var acceleration : float = 100.0 ##Força da aceleração de movimento
@export var KnockBack_Hit : float = 80.0 ##Velocidade do movimento
@export var Gravity_Multiplier : float = 2.0

var Target_enemy : Flockos
var is_braking : bool = false
var shot_brake : bool = false
var current_timer_togo_shootplayer : float
	

func enter() -> void:
	print(name, "Is chasing player")
	%AnimationTree["parameters/playback"].travel("Cannoner_AlertLoop")
	current_timer_togo_shootplayer = Time_ToGo_ShootPlayer
	is_braking = false
	super()
	
func process(delta: float) -> EnemyStateMaker:
	
	if enemy.is_on_floor():
		var tweni = create_tween()
		tweni.tween_property(%Sprite, 
		"rotation",
		enemy.get_floor_normal().angle() + deg_to_rad(90), 
		0.1).set_ease(Tween.EASE_OUT)
		tweni.play()
	
	if not enemy.is_on_floor():
		if enemy.velocity.y < enemy.max_gravity_force:
			enemy.velocity.y += (enemy.gravity_engine * Gravity_Multiplier) * delta
		else:
			enemy.velocity.y = enemy.max_gravity_force
	
	if %Enemy_HitBox.get_overlapping_areas().size() > 0:
		enemy.velocity.x *= 0
	else:
		if enemy.current_direction == "Left":
			enemy.flip_x = true
			LeftDrive()
		elif enemy.current_direction == "Right":
			enemy.flip_x = false
			RightDrive()
			
	if current_timer_togo_shootplayer > 0:
		if enemy.velocity.x != 0:
			current_timer_togo_shootplayer -= delta
	else:
		if enemy.get_floor_angle() == deg_to_rad(0.000):
			if not enemy.is_on_wall():
				return ShootPlayer
		
	return null

func Left_Target_Entered(target: Node2D) -> void:
	if target is Flockos:
		enemy.current_direction = "Left"

func Right_Target_Entered(target: Node2D) -> void:
	if target is Flockos:
		enemy.current_direction = "Right"
		
func LeftDrive() -> void:
	enemy.velocity.x = max(enemy.velocity.x - acceleration, -velocity_speed)
	
func RightDrive() -> void:
	enemy.velocity.x = min(enemy.velocity.x + acceleration, velocity_speed)
