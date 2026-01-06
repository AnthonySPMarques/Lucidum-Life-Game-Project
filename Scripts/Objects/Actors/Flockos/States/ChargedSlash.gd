extends Slashs

@export var slow_game_time : float = 1

var is_animation_finished : bool = false
var can_input : bool = false
var BigSlash : PackedScene = preload("res://Scenes/Objects/Projectiles/BigSlashBite.tscn")

#var camera_zoom = preload("res://Scenes/Triggers/Camera.tscn")

func enter() -> void:
	super()
	SoundEffects.play_sound(SoundEffects.SFX_GLITCHINGSCRATCH)
	
	player.is_immune = true
	%Hitbox.disable_hitboxes()
	
	player.UI.change_Current_AwakenEnergy_Value(0)
	%FlashHit.play("OnlyInvencible")
	player.velocity = Vector2.ZERO
	TimerSlash = Attack_Duration
	TimerInput = Time_ToInput
	get_parent().player.is_landing = false
	
	"Setters"
	%Animation_Traveler.set("parameters/Is_On_Floor/transition_request", "Yes")
	%Animation_Traveler.set("parameters/Is_Slashing/transition_request", "Yes")
	%Animation_Traveler.set("parameters/Is_Charged/transition_request", "Yes")
	#%Animation_Traveler.get("parameters/IdleSlashCharged/playback").travel("IdleSlashCharged_1")

func physics_process(_delta: float) -> StateMaker:
	
	#In this state, set zoom for camera.
	CameraZonesManager.Current_camerazone.set_zoom(player.ZoomScale)
	
	#if player.Hitted:
		#player.return_tween_camerazoom(0.05)
		#return player.KnockBackState
	
	if is_animation_finished == true:
		return NextSlashState
	
	return null
	
func gameprocess_speed(speed: float, time: float) -> void:
	GlobalEngine.change_gamespeed(speed, time)
	
func shoot():
	var BigSlashObj = BigSlash.instantiate()
	BigSlashObj.set_as_top_level(true)
	
	%StrongQuake_SlashBite.emit()
	
	if player.is_sprite_flipped == true:
		BigSlashObj.global_position = player.BigSlash_pos_left.global_position
		BigSlashObj.direction = -1
	else:
		BigSlashObj.global_position = player.BigSlash_pos_right.global_position
		BigSlashObj.direction = 1

	player.call_deferred("add_child", BigSlashObj)

func exit() -> void:
	
	GlobalEngine.return_defaultspeed()
	%Meele_Hitbox.disable_clash_areas()
	
	can_input = false
	is_animation_finished = false
	
	%FlashHitTree.get("parameters/playback").travel("OnlyInvencible")
	
	#Set energy bar to 0
	player.AnimationTraveler.set("parameters/Is_Ducked/transition_request", "No")

func set_animation_to_finished() -> void:
	is_animation_finished = true
	

func boom_sound() -> void:
	SoundEffects.play_sound(SoundEffects.SFX_FIREWORKBITES)

func vocal() -> void:
	SoundEffects.play_sound(SoundEffects.SFX_FLOCKOSYELL)
