extends EnemyStateMaker

@export_category("States")
@export var ChasePlayer : EnemyStateMaker

@export_category("General properties")
@export var Time_ToGo_ChasePlayer :float= 4.0

@export_category("Velocity values")
@export var friction : float = 200.0 ##Força de atrito do movimento
@export var Gravity_Multiplier : float = 2.0

var current_timer_togo_chaseplayer : float

var cannonball : PackedScene = preload("res://Scenes/Objects/Projectiles/AntiNightmare_CannonBall.tscn")

@onready var malicious_projectile: AudioStreamPlayer2D = %AreaSFX_MaliciousProjectile
@onready var fire_pos: Marker2D = %FirePos



func enter() -> void:
	%AnimationTree["parameters/playback"].travel("Cannoner_Fire")
	current_timer_togo_chaseplayer = Time_ToGo_ChasePlayer
	print(str(name) + "is shooting")
	
func physics_process(delta: float) -> EnemyStateMaker:
	
	##Rotate sprite
	if enemy.is_on_floor():
		var tweni = create_tween()
		tweni.tween_property(%Sprite, 
		"rotation",
		enemy.get_floor_normal().angle() + deg_to_rad(90), 
		0.1).set_ease(Tween.EASE_OUT)
		tweni.play()
		
	#Enemy velocity
	if enemy.velocity.x > 0:
		enemy.velocity.x = max(enemy.velocity.x - friction, 0)
	if enemy.velocity.x < 0:
		enemy.velocity.x = min(enemy.velocity.x + friction, 0)
		
	if not enemy.is_on_floor():
		if enemy.velocity.y < enemy.max_gravity_force:
			enemy.velocity.y += (enemy.gravity_engine * Gravity_Multiplier) * delta
		else:
			enemy.velocity.y = enemy.max_gravity_force
			
	#Enemy timer
	if current_timer_togo_chaseplayer > 0:
		current_timer_togo_chaseplayer -= delta
	else:
		return ChasePlayer
			
	return null
	
func Left_Target_Entered(target: Node2D) -> void:
	if target is Flockos:
		enemy.flip_x = true

func Right_Target_Entered(target: Node2D) -> void:
	if target is Flockos:
		enemy.flip_x = false
		
func shot() -> void:
	if GlobalEngine.flockos.is_dead == false:
		malicious_projectile.play()
		Triggers.create_Projectile(cannonball, fire_pos.global_position, Vector2.ONE)
	
