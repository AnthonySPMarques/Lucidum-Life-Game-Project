extends StateMaker

@export var ExpTime_to_Idle : float = 0.84
var TimerToIdle

func enter() -> void:
	super()
	TimerToIdle = ExpTime_to_Idle

	pass

func exit() -> void:
	%Hitbox.enable_DefaultHitbox()

func process(delta: float) -> StateMaker:
	
	if TimerToIdle > 0:
		TimerToIdle -= delta
	else:
		return player.IdleState
		
	return null
