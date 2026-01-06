extends StateMaker

@export_category("Velocity values")
@export var Velocity_speed : float = 60.0
@export var Gravity_Divider : float = 0.5


#On enter
func enter() -> void:
	super()
	
	if not Input.is_action_pressed("Dash"):
		%Trail.can_trail = false
	
	if player.is_immune == false:
		%Hitbox.enable_WallHitbox()
	
	#player.can_flip = false
	
	player.velocity.x = 0
	player.can_crazy_fly = true
	player.can_air_dash = true
	
func exit() -> void:
	player.AnimationTraveler.set("parameters/Is_Air_Slashing/current", 1)
	player.velocity.x = 0

func input(_event: InputEvent) -> StateMaker:
	if Input.is_action_just_pressed("Jump"):
		#"eletric smoke dash"
		Triggers.create_VisualEffectTrigger(9,
		%PivotWall.global_position - Vector2(0, 24), 
		Vector2(-%FlockosSprite.scale.x, 1))
		if Input.is_action_pressed("Dash"):
			%Trail.can_trail = true
		else:
			%Trail.can_trail = false
		return player.WallJumpState
	return null
	
func process(_delta : float) -> StateMaker:
	
	#Return to jump in spring:
	if player.impulsed_by_spring:
		player.velocity = player.Velocity_Impulse
		
	if player.is_small_area_on_water:
		"Create bubble particle"
		Triggers.create_ParticleTrigger(
		#Particle Scene
		preload("res://Scenes/Triggers/FXs/Particles/0.tscn"),
		#Particle Posiiton
		player.PivotCenter.global_position + Vector2(-16*player.sprite.scale.x, 0),
		#Particle Scale
		Vector2(player.sprite.scale.x, 1),
		#Particle Material
		preload("res://tres/Materials/WaterBubbleDeep.tres"),
		#Particle AmountRatio
		0.01);
	
	return null
	
	
#Physics
func physics_process(delta: float) -> StateMaker:
	
	if player.is_on_slider:
		return player.OnSliderState
		
	if player.can_be_knockbacked():
		return player.KnockBackState
	
	if Input.is_action_just_pressed("Main_Attack_Input") and not player.is_on_floor(): #player.prefloor_colliding():
		return player.WallSlashState
		
	if player.is_immune == false:
		%Hitbox.enable_WallHitbox()
	
	if not Input.is_action_pressed("Left") and not Input.is_action_pressed("Right"):
		player.is_sprite_flipped = !player.is_sprite_flipped 
		%Hitbox.enable_DefaultHitbox()
		return player.FallState
	

	if Input.is_action_just_pressed("Jump") and \
	!Input.is_action_pressed("Defend"):
		if Input.is_action_pressed("Dash"):
			%Trail.can_trail = true
		else:
			%Trail.can_trail = false
		#"eletric smoke dash"
		Triggers.create_VisualEffectTrigger(9, 
		%PivotWall.global_position - Vector2(0, 24), 
		Vector2(-%Flockos.scale.x, 1))
		return player.WallJumpState
	
	"Blade Fan State"
#	elif Input.is_action_pressed("Defend"):
#		return WallBladeFanState
	
	if player.is_on_floor():
		player.is_sprite_flipped = !player.is_sprite_flipped 
		return player.IdleState
		

#	if player.Left_raycast():
#		player.is_sprite_flipped = true
#	if player.Right_raycast():
#		player.is_sprite_flipped = false
		
		
	var side = 0
	#Apply Direction
	if Input.is_action_pressed("Left") and !Input.is_action_pressed("Right"):
		side = -1
	elif Input.is_action_pressed("Right") and !Input.is_action_pressed("Left"):
		side = 1
	elif Input.is_action_pressed("Left") and Input.is_action_pressed("Right"):
		side = 0
	else:
		side = 0

	#Apply Gravity
	if not Input.is_action_pressed("Up"):
		player.AnimationTraveler.get("parameters/WallSlide/playback").travel("WallSliding")
		player.velocity.y = player.Gravity / Gravity_Divider * delta
	#Brake sliding
	else:
		player.AnimationTraveler.get("parameters/WallSlide/playback").travel("WallStop")
		player.velocity.y = 0
		
		
	#Vector values
	player.velocity.x = Velocity_speed * side
	
	#Falls
	if !player.On_Wall() and Input.is_action_pressed("Dash"):# and not player.reduce_velocity():
		return player.DashFallState
		
	elif !player.On_Wall() and !Input.is_action_pressed("Dash"):
		#Fall fast
		player.velocity.y = 300
		return player.FallState

	return null
