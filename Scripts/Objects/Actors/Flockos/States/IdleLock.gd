extends StateMaker

func enter() -> void:
	player.velocity = Vector2.ZERO

func process(_delta: float) -> StateMaker:
	
	if not Input.is_action_pressed("CameraLock"):
		return player.IdleState
	return null
