extends StateMaker

@export var velocity_speed : float = 360.0 ##Velocidade do movimento
@export var Acceleration : float = 40.0 ##Força da aceleração de movimento
@export var Friction : float = 60.0 ##Força de atrito do movimento

func physics_process(delta: float) -> StateMaker:
	
	velocity()
	if not player.is_on_floor():
		player.velocity.y += player.Gravity/2 * delta
	
	if player.is_on_floor():
		return player.IdleState
		
	if player.Hitted:
		return player.KnockBackState
		
	return null

func velocity() -> void:
	
	#Input
	var is_left = Input.is_action_pressed("Left") and !Input.is_action_pressed("Right")
	var is_right = Input.is_action_pressed("Right") and !Input.is_action_pressed("Left")
	
	if not (Input.is_action_pressed("Left") and player.WallfloorLeft_raycast()) and \
		not (Input.is_action_pressed("Right") and player.WallfloorRight_raycast()):
		if is_right:
			player.velocity.x = min(player.velocity.x + Acceleration, velocity_speed)

		elif is_left:
			player.velocity.x = max(player.velocity.x - Acceleration, -velocity_speed)

		else:
			#Friction:
			if player.velocity.x > 0:
				player.velocity.x = max(player.velocity.x - Friction, 0)

			if player.velocity.x < 0:
				player.velocity.x = min(player.velocity.x + Friction, 0)
	else:
		if player.velocity.x > 0:
			player.velocity.x = max(player.velocity.x - Friction, 0)
		if player.velocity.x < 0:
			player.velocity.x = min(player.velocity.x + Friction, 0)
