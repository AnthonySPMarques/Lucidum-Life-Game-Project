@icon("res://Sprites/EditorTriggers/CameraTrigger.png")
extends CharacterBody2D


func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("CameraLock"):
		if Input.is_action_pressed("Right"):
			position.x = lerpf(position.x, 64.0, 0.1)
		elif Input.is_action_pressed("Left"):
			position.x = lerpf(position.x, -64.0, 0.1)
		if Input.is_action_pressed("Down"):
			position.y = lerpf(position.y, -58.0+64.0, 0.1)
		elif Input.is_action_pressed("Up"):
			position.y = lerpf(position.y, -58.0-64.0, 0.1)
	else:
		position.x = lerpf(position.x, 0.0, 0.5)
		position.y = lerpf(position.y, -58.0, 0.5)
		
