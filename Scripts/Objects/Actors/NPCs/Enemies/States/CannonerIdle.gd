extends EnemyStateMaker

var Player_is_inside_target_area : bool = false

@export_category("States")
@export var ChasePlayer : EnemyStateMaker
@export var ShootPlayer : EnemyStateMaker

@export var Velocity_Start : float = 140.0

@onready var enemy_area_detc_l: Area2D = %Enemy_TargetDetectorLeft
@onready var enemy_area_detc_r: Area2D = %Enemy_TargetDetectorRight


func enter() -> void:
	Player_is_inside_target_area = false
	
	%AnimationTree["parameters/playback"].travel("Cannoner_Idle")
	enemy_area_detc_l.body_entered.connect(entered_target.bind(enemy_area_detc_l))
	enemy_area_detc_r.body_entered.connect(entered_target.bind(enemy_area_detc_r))
	
	super()

func process(delta: float) -> EnemyStateMaker:
	enemy.velocity.x = Velocity_Start * %Sprite.scale.x
	if not enemy.is_on_floor():
		enemy.velocity.y += GlobalEngine.Gravity*delta
		
	if Player_is_inside_target_area:
		return ChasePlayer
	else:
		return null
	
	
func entered_target(body: Node2D, areaconnected: Area2D) -> void:
	if body is Flockos:
		if areaconnected == enemy_area_detc_l:
			enemy.current_direction = "Left"
		elif areaconnected == enemy_area_detc_r:
			enemy.current_direction = "Right"
		Player_is_inside_target_area = true
