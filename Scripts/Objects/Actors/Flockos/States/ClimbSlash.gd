extends Slashs

"Give time to end also the save sword animation"

var is_animation_finished : bool = false

func enter() -> void:
	super()
	player.velocity.y = 0
	player.is_climbing = true
	TimerSlash = Attack_Duration

	if player.is_small_area_on_water:
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
		0.03);
	
	player.can_flip = false
	
	player.AnimationTraveler.get("parameters/Climbs/playback").travel("ClimbSlash")
	
func play_sound() -> void:
	SoundEffects.play_sound(SoundEffects.SFX_SLASHBITE)
	
func exit() -> void:
	%Meele_Hitbox.disable_clash_areas()
	is_animation_finished = false
	player.is_climbing = false
	player.can_flip = true
	player.AnimationTraveler.set("parameters/SpeedClimb/scale", 0)

func process(_delta: float) -> StateMaker:
	if player.can_be_knockbacked():
		return player.KnockBackState
	return null

func physics_process(_delta: float) -> StateMaker:
	if player.is_immune == false:
		%Hitbox.enable_DefaultHitbox()
	if player.Hitted:
		return player.KnockBackState

	#Countdown the timer
	if is_animation_finished:
		return player.ClimbState

	return null

func set_animation_to_finished() -> void:
	is_animation_finished = true
