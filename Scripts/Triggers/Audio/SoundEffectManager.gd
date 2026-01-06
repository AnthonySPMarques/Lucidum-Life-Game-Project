@icon("res://Sprites/EditorTriggers/SoundEffects.png")
extends Node

@onready var SFX_ATTACKHIT : int = %SFX_AttackHit.get_index()
@onready var SFX_SLASHBITE : int = %SFX_SlashBite.get_index()
@onready var SFX_SLASHBITE3TH : int = %SFX_SlashBite3th.get_index()
@onready var SFX_FIREWORKBITES : int = %SFX_FireworkBites.get_index()
@onready var SFX_KICKBACK : int = %SFX_Kickback.get_index()
@onready var SFX_MEOW : int = %SFX_Meow.get_index()
@onready var SFX_JUMP : int = %SFX_Jump.get_index()
@onready var SFX_LAND : int = %SFX_Land.get_index()
@onready var SFX_DASH : int = %SFX_Dash.get_index()
@onready var SFX_DASHSAW : int = %SFX_DashSaw.get_index()
@onready var SFX_WALLKICK : int = %SFX_WallKick.get_index()
@onready var SFX_KNOCKBACK : int = %SFX_Knockback.get_index()
@onready var SFX_THUNDERINTRO : int = %SFX_ThunderIntro.get_index()
@onready var SFX_OPENINGDOOR : int = %SFX_OpenDoor.get_index()
@onready var SFX_CLOSINGDOOR : int = %SFX_CloseDoor.get_index()
@onready var SFX_MEOW_HURT : int = %SFX_MeowHurt.get_index()
@onready var SFX_SPLASH_WATER_ENTER : int = %SFX_SplashWaterEnter.get_index()
@onready var SFX_SPLASH_WATER_EXIT : int = %SFX_SplashWaterExit.get_index()
@onready var SFX_WATER_SHAKE : int = %SFX_WaterShake.get_index()
@onready var SFX_THUNDER_ECO : int = %SFX_ThunderEco.get_index()
@onready var SFX_SPLASH : int = %SFX_Splash.get_index()
@onready var SFX_WATERSWING : int = %SFX_WaterSwing.get_index()
@onready var SFX_LIGHTINGKITE : int = %SFX_LightingKite.get_index()
@onready var SFX_BOING : int = %SFX_Boing.get_index()
@onready var SFX_MEOW_DEATH : int = %SFX_MeowDeath.get_index()
@onready var SFX_PURR : int = %SFX_Purr.get_index()
@onready var SFX_CRAZYFLY_SAW : int = %SFX_CrazyFly_Saw.get_index()
@onready var SFX_FAN : int = %SFX_Fan.get_index()
@onready var SFX_LIGHTINGCHARGE : int = %SFX_LightingCharge.get_index()
@onready var SFX_WHOOSH : int = %SFX_WhooshBlade.get_index()
@onready var SFX_STRONGSWORDSTAMP : int = %SFX_StrongSwordStamp.get_index()
@onready var SFX_GLITCHINGSCRATCH : int = %SFX_GlitchingScratch.get_index()
@onready var SFX_DESTROYEREXPLOSION : int = %SFX_DestructionExplosion.get_index()
@onready var SFX_MENUAPPEAR: int = %SFX_MenuAppear.get_index()
@onready var SFX_MENUCONFIRM: int = %SFX_MenuConfirm.get_index()
@onready var SFX_MENUQUIT: int = %SFX_MenuQuit.get_index()
@onready var SFX_MENUARROW: int = %SFX_MenuArrow.get_index()
@onready var SFX_PICKUP: int = %SFX_Pickup.get_index()
@onready var SFX_PICKUP_RARE: int = %SFX_PickupRare.get_index()
@onready var SFX_POING: int = %SFX_Poing.get_index()
@onready var SFX_POINGPOWER: int = %SFX_PoingPower.get_index()
@onready var SFX_FLOCKOSYELL: int = %SFX_FlockosYell.get_index()
@onready var SFX_METALSPRING: int = %SFX_MetalSpring.get_index()
@onready var SFX_SPRINGVOCALED: int = %SFX_SpringVocaled.get_index()
@onready var SFX_LUCIDEL: int = %SFX_Luicidel.get_index()
@onready var SFX_FLOCKOS_CRY_1ST: int = %SFX_FlockosCry1st.get_index()
@onready var SFX_FLOCKOS_CRY_2ND: int = %SFX_FlockosCry2nd.get_index()
@onready var SFX_FLOCKOS_CRY_3RD: int = %SFX_FlockosCry3rd.get_index()


func _ready() -> void:
	push_warning("Create rough slide sfx")
	for Y in get_children():
		var Ys = Y as AudioStreamPlayer
		Ys.finished.connect(sound_finished.bind(Ys))
		print(Ys.get_index() , " ID = " , Ys.name)


func play_sound_advanced(
	AudioID : int,
	#StreamLoader : AudioStream,
	PitchScale : float = 1.0,
	VolumeDecibel : float = 0.0
) -> void:
	
	#get_child(AudioID).set_stream(StreamLoader)
	if get_child(AudioID).stream is AudioStreamRandomizer:
		get_child(AudioID).stream.set("random_pitch", 1.0)
		
	get_child(AudioID).pitch_scale = PitchScale
	get_child(AudioID).volume_db = VolumeDecibel
	get_child(AudioID).play()
	
func play_sound(AudioID : int) -> void:
	var sound = get_child(AudioID) as AudioStreamPlayer
	
	##Get game settings if vocal sfx is enabled
	if (sound.is_in_group("vocal") and
	GameSettings.ConfigurationManager.GameplaySettings.Game_Configurations_Dictionary.Enable_voice_sfx) or\
	(!sound.is_in_group("vocal")):
		get_child(AudioID).play()

func stop_sound(AudioID : int) -> void:
	if get_child(AudioID).is_playing:
		get_child(AudioID).stop()

func is_sound_playing(AudioID: int) -> bool:
	return get_child(AudioID).playing

func sound_finished(SoundNode: AudioStreamPlayer) -> void:
	
	if SoundNode == %SFX_SlashBite:
		SoundNode.stream.set("random_pitch", 1.1)
		#SoundNode.pitch_scale = 0.9
		#SoundNode.volume_db = 0.0
