extends StateMaker

@export var Climbing_to_top = true
var is_animation_finished = false

func enter() -> void:
	super()
	SoundEffects.play_sound(SoundEffects.SFX_WHOOSH)
	#player.main_mask.disabled = true
	#player.mask_down.disabled = true
	player.can_climb = false
	
func exit() -> void:
	#player.main_mask.disabled = false
	#player.mask_down.disabled = false
	is_animation_finished = false
	if player.get_moving_platform != null:
		#offset = player.global_position - player.get_moving_platform.global_position
		player.global_position.y = player.get_moving_platform.global_position.y
		
		#player.get_moving_platform = null
	
func physics_process(_delta: float) -> StateMaker:
	
	if is_animation_finished == true:
		if Climbing_to_top:
			player.can_hang_top_solid = false
			
			if not Input.is_action_pressed("Left") and not Input.is_action_pressed("Right") \
			and not Input.is_action_pressed("Down"):
				#%PosReseter.play("ResetPos")
				return player.IdleState
			
			elif Input.is_action_pressed("Left") or Input.is_action_pressed("Right"):
				#%PosReseter.play("ResetPos")
				return player.RunState
			
			elif Input.is_action_pressed("Down"):
				#%PosReseter.play("ResetPos")
				return player.DownState
			
		else:
			return player.HangingTop

	if player.is_small_area_on_water:
		"Create bubble particle"
		if name == "HangClimbToTop":
			Triggers.create_ParticleTrigger(
			#Particle Scene
			preload("res://Scenes/Triggers/FXs/Particles/0.tscn"),
			#Particle Posiiton
			player.PivotCenter.global_position,
			#Particle Scale
			Vector2.ONE,
			#Particle Material
			preload("res://tres/Materials/WaterBubbleDeep.tres"),
			#Particle AmountRatio
			0.04);
		
		elif name == "HangClimbToDown":
			Triggers.create_ParticleTrigger(
			#Particle Scene
			preload("res://Scenes/Triggers/FXs/Particles/0.tscn"),
			#Particle Posiiton
			player.PivotCenter.global_position + Vector2(0, 48),
			#Particle Scale
			Vector2.ONE,
			#Particle Material
			preload("res://tres/Materials/WaterBubbleDeep.tres"),
			#Particle AmountRatio
			0.04);
		
	return null
	
func climb_down() -> void:
	#%PersistentMask.position.y = -128
	#%Mask.position.y = -128
	#%MaskDown.position.y = -128
	player.position.y += 128
	#player.sprite.position.y += 128
	player.main_mask.position.y = -58-128
	pass
func climb_hang() -> void:
	#%PersistentMask.position.y = 0
	#%Mask.position.y = 0
	#%MaskDown.position.y = 0
	player.position.y -= 128
	player.main_mask.position.y = -58
	#player.sprite.position.y -= 128
	pass
func set_animation_to_finished() -> void:
	is_animation_finished = true
