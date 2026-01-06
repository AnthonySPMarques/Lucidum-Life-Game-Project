extends Slashs

var is_animation_finished : bool = false

func enter() -> void:
	super()
	SoundEffects.play_sound(SoundEffects.SFX_SLASHBITE)
	
	player.velocity = Vector2.ZERO
	player.position.y = snappedf(player.position.y, 64)
	
	player.can_air_dash = true
	player.can_crazy_fly = true
	player.can_climb = false
	
func exit() -> void:
	is_animation_finished = false
	
func process(_delta: float) -> StateMaker:
	if player.can_be_knockbacked():
		#%PosReseter.play("ResetPos")
		return player.KnockBackState
	if is_animation_finished:
		return player.HangingTop
	
	if player.is_on_water:
		"Create bubble particle"
		Triggers.create_ParticleTrigger(
		#Particle Scene
		preload("res://Scenes/Triggers/FXs/Particles/0.tscn"),
		#Particle Posiiton
		player.PivotCenter.global_position,
		#Particle Scale
		Vector2(player.sprite.scale.x, 1),
		#Particle Material
		preload("res://tres/Materials/WaterBubbleDeepBlown.tres"),
		#Particle AmountRatio
		0.04);
	
	return null
	
func input(_event: InputEvent) -> StateMaker:
	if Input.is_action_pressed("Down") and Input.is_action_just_pressed("Jump"):
		player.can_hang_top_solid = false
		if not Input.is_action_pressed("Dash"):
			#%PosReseter.play("ResetPos")
			return player.FallState
		else:
			#%PosReseter.play("ResetPos")
			return player.DashFallState

	if !Input.is_action_pressed("Down") \
	and !Input.is_action_pressed("Up"):
		if Input.is_action_just_pressed("Jump"):
			if not Input.is_action_pressed("Dash"):
				#%PosReseter.play("ResetPos")
				return player.JumpState
			else:
				#%PosReseter.play("ResetPos")
				return player.DashJumpState
		
	return null
	
func _set_animation_finished() -> void:
	is_animation_finished = true
