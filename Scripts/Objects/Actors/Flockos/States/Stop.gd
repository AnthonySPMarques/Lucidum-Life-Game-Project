extends StateMaker
@export var let_keep_running : bool = false

func enter() -> void:
	super()
	if let_keep_running:
		player.velocity = Vector2.ZERO
	
