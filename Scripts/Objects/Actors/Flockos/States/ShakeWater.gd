extends Slashs

var can_back_idle = false
var bolt = preload("res://Scenes/Triggers/FXs/Particles/1.tscn")

func enter() -> void:
	super()
	%Hitbox.disable_hitboxes()
	
	
	player.is_wet = false
	player.can_flip = false
	
func exit() -> void:
	
	%WaterShake_Mask.disabled = true
	
	can_back_idle = false

	player.is_landing = false
	player.can_flip = true
	
func process(_delta) -> StateMaker:
	#%Shake_Spark_Particle.position.x *= player.sprite.scale.x
	player.AnimationTraveler["parameters/Current_Animation_State/transition_request"] = "ShakeWater"
	player.AnimationTraveler["parameters/ShakeWater/playback"].travel("BackToBiped")
	
	if can_back_idle:
		return player.IdleState
		
	return null

func create_bolt() -> void:
	
	var bolti = bolt.instantiate() as Node2D
	bolti.global_position = %PivotShakeWater.global_position * Vector2(player.scale.x, 1)
	bolti.scale = Vector2i.ONE*2
	player.call_deferred("add_child", bolti)
	
func play_sfx() -> void:
	#GlobalEngine.change_gamespeed(0.4, 0.1)
	SoundEffects.play_sound(SoundEffects.SFX_WATER_SHAKE)
	pass
	
func can_back_to_idle() -> void:
	can_back_idle = true
