extends CharacterBody3D


const SPEED = 4.0
const JUMP_VELOCITY = 4.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_pressed("Left"):
		$Sprite3D.scale.z = -1
		$Sprite3D/AnimationPlayer.play("RunCycle")
		velocity.x = -SPEED
	elif Input.is_action_pressed("Right"):
		$Sprite3D.scale.z = 1
		$Sprite3D/AnimationPlayer.play("RunCycle")
		velocity.x = SPEED
	else:
		$Sprite3D/AnimationPlayer.play("Idle")
		velocity.x = 0
	move_and_slide()
