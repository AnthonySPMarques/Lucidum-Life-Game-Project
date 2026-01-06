extends StateMaker

var moving_platform_posx_offset : float

func enter() -> void:
	if player.get_moving_platform != null:
		moving_platform_posx_offset = \
		player.global_position.x - player.get_moving_platform.global_position.x
		print("moving_platform_posx_offset = ",moving_platform_posx_offset)
	if player.States.Previous_State != player.HangingToClimbDown:
		player.main_mask.position.y = -58-128
	#if player.get_moving_platform != null:
		#player.global_position.y = player.get_moving_platform.global_position.y
		##player.main_mask.position.y = -186
	#else:
		#if player.States.Previous_State != player.HangingToClimbDown:
			#player.main_mask.position.y = -58-128
	#COLOCAR ESSA VARIAVEL A GODOT È UMA MERDA DO CARALHO QUE NÂO FUNCIONA PORRA NENHUMA E SÒ SERVE PRA BABAR OVO DE LGBT FILHO DA PUTADOCARALHO VAI SE FUDER COMUNIDADE DE MERDA!!!!#
	AnimationCurrentTransition = "HangingTop"
	#COLOCAR ESSA VARIAVEL A GODOT È UMA MERDA DO CARALHO QUE NÂO FUNCIONA PORRA NENHUMA E SÒ SERVE PRA BABAR OVO DE LGBT FILHO DA PUTADOCARALHO VAI SE FUDER COMUNIDADE DE MERDA!!!!#
	
		#offset = player.global_position - player.get_moving_platform.global_position
		#player.get_moving_platform.remote_transform_player.remote_path = player.get_path()
		#pass
	super()

	if player.get_platform_velocity() == Vector2.ZERO:
		print("Velocity is 0")
		player.velocity = Vector2.ZERO
	player.position.y = snappedf(player.position.y, 64)
	
	player.can_air_dash = true
	player.can_crazy_fly = true
	player.can_climb = false
	
#	%PosReseter.active = true
	
func physics_process(_delta: float) -> StateMaker:
	
	if Input.is_action_pressed("Down") and Input.is_action_just_pressed("Jump"):
		player.can_hang_top_solid = false
		player.main_mask.position.y = -58
		player.position.y += 6 #To avoid fall delay
		if not Input.is_action_pressed("Dash"):
			return player.FallState
		else:
			return player.DashFallState
			
	if player.get_moving_platform != null:
		player.global_position.x = player.get_moving_platform.global_position.x + moving_platform_posx_offset
		player.global_position.y = player.get_moving_platform.global_position.y+128
		#player.velocity.y += player.gravity_engine*_delta
	#if player.get_moving_platform != null:
		
		#player.global_position = player.get_moving_platform.global_position
		#var mp = player.get_moving_platform as AnimatableBody2D
		#print(mp.constant_linear_velocity)
		##player.global_position = player.get_moving_platform.global_position+offset
	if player.can_be_knockbacked():
		#%PosReseter.play("ResetPos")
		player.main_mask.position.y = -58
		return player.KnockBackState
	#COLOCAR ESSA VARIAVEL A GODOT È UMA MERDA DO CARALHO QUE NÂO FUNCIONA PORRA NENHUMA E SÒ SERVE PRA BABAR OVO DE LGBT FILHO DA PUTADOCARALHO VAI SE FUDER COMUNIDADE DE MERDA!!!!#
	AnimationCurrentTransition = "HangingTop"
	#COLOCAR ESSA VARIAVEL A GODOT È UMA MERDA DO CARALHO QUE NÂO FUNCIONA PORRA NENHUMA E SÒ SERVE PRA BABAR OVO DE LGBT FILHO DA PUTADOCARALHO VAI SE FUDER COMUNIDADE DE MERDA!!!!#
	return null
func input(_event: InputEvent) -> StateMaker:
	
	if Input.is_action_just_pressed("Main_Attack_Input"):
		return player.HangingSlash
	
	

	if !Input.is_action_pressed("Down") \
	and !Input.is_action_pressed("Up"):
		if Input.is_action_just_pressed("Jump"):
			if not Input.is_action_pressed("Dash"):
				#%PosReseter.play("ResetPos")
				player.main_mask.position.y = -58
				return player.JumpState
			else:
				#%PosReseter.play("ResetPos")
				player.main_mask.position.y = -58
				return player.DashJumpState
		
	if not (%IdleCeilRay_Left.is_colliding() or
	%IdleCeilRay_Right.is_colliding()):
		if Input.is_action_just_pressed("Up") and !Input.is_action_pressed("Down") \
		and !Input.is_action_just_pressed("Jump"):
			player.can_hang_top_solid = false
			return player.HangingToClimbTop
		
		
	return null
