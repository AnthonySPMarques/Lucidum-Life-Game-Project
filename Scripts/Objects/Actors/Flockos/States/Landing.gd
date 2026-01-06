extends StateMaker

@export_category("Timers")
@export var to_idle := 0.3 ##Timer from landing to idle


var idle

func enter() -> void:
	super()
	idle = to_idle
	#Animation player parameters:
	
func process(delta: float) -> StateMaker:
	
	if idle > 0:
		idle -= delta
	else:
		return player.IdleState
	
	return null
	
func exit() -> void:
	idle = to_idle
