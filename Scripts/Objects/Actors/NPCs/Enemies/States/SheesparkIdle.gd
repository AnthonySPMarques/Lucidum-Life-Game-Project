extends EnemyStateMaker

var target : Node2D ##Var to store node Flockos
@onready var AimLaser_State: EnemyStateMaker = %AimLaser
@onready var animation_tree: AnimationTree = %AnimationTree

@onready var behavior_player: AnimationPlayer = $"../../Sprite/BehaviorPlayer"

func enter() -> void:
	animation_tree["parameters/playback"].travel("Sheespark_Idle")
	%Aimmer.clear_points()
	behavior_player.play("RESET")
	target = null

func process(delta: float) -> EnemyStateMaker:
	
	if not enemy.is_on_floor():
		enemy.velocity.y += 800*delta
	else:
		enemy.velocity.y = 0
		
	if target != null:
		%AimLaser.target = target
		return AimLaser_State
		
	return null
		

func found_target(area: Area2D) -> void:
	if area is PlayerHitbox:
		target = GlobalEngine.flockos
