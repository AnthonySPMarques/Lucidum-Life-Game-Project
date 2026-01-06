extends EnemyStateMaker

@export var frozen_time : float = 0.5
@export var StateToBack : EnemyStateMaker

var ready_frozen_time : float

func enter() -> void:
	enemy.velocity *= Vector2.ZERO
	ready_frozen_time = frozen_time
	
func process(delta: float) -> EnemyStateMaker:
	
	ready_frozen_time -= delta
	if ready_frozen_time > 0:
		return null
		
	return StateToBack #When frozen time is 0
