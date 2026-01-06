@icon("res://Sprites/Characters/Editor/Icon.png")
extends CharacterBody2D
class_name Flockos

"Scene to be created"
#[Scene to be created] 

"Signals"
signal passed_to_next_area #When player goes from an area 1-A to area 1-B
signal restarted_current_level #When it restarts level
###
"Enums"
enum Entering_Scene_Transition {
	Thunder_Wrap,
	Exiting_From_Door,
	WalkingLeft,
	WalkingRight,
	Falling,
	HighJump}
enum TileType {
	Hurtable = 5
}


##Constants##:
const THRU_BIT_DROP = 2 #For down from onlyway solids
const CURRENT_MAX_ANGLE = 64
const RIPPLER_FX = preload("uid://c2ecmnxx3r6nw")


var CURRENT_SNAP_LENGTH #var cuz it needs to be applied only one time
#const PLANE_FLOOR = Vector2.UP
#const SNAP_RANGE = 16
#const SLOPE_HOLDDOWN = deg_to_rad(63.0)
##Exported Variables
@export_category("Exported Variables")
@export var Own_Player_Data : PlayerResources = preload("uid://dtnx3ul6y3l3u")

@export_subgroup("Enums")
@export var Start_Scene_By : Entering_Scene_Transition = Entering_Scene_Transition.Thunder_Wrap
				
##Variable for numbers:
@export_subgroup("Ints Floats")
##Gravity of character:
#@export var Gravity = 5
##Limit for gravity when increasing value:
#@export var Gravity : float = 980.0
@export var MaxPlayerGravity : float = 1200.0
##Timer to define the time to press again the arrow before the dash
##command is cancelled:
@export var time_to_press_arrow_again : float = 0.2
##How fast the game runs
@export var current_game_speed : float = 1.0
##Export nodepath for masks
@export_subgroup("Masks")
##Current mask for Player behaivors
@export var CurrentMask : CollisionShape2D
##Export boolean variables
@export_subgroup("Booleans")
##Show all the info for Player behaivor
@export var Show_Debug_States : bool = false
@export var Show_Debug_Velocity : bool = false
@export var Show_Debug_Bool : bool = false
@export var Show_Debug_Cheats : bool = false
##[USED FOR ANIMATIONPLAYER] when Player is in iframe.
@export var is_immune : bool = false
@export_category("Used in AnimationPlayers")
@export var can_flip : bool = true
@export var Hitted : bool = false
@export var ZoomScale : Vector2 = Vector2.ONE

@export_category("State Machines")
@export_subgroup("State Machine")
@export var StartState : StateMaker
@export var IdleState : StateMaker
@export var IdleSlash1State : StateMaker
@export var IdleSlash2State : StateMaker
@export var IdleSlash3State : StateMaker
@export var ChargedSlashState : StateMaker
@export var RunState : StateMaker
@export var RunSlashState : StateMaker
@export var DownState : StateMaker
@export var DownSlash1State : StateMaker
@export var DownSlash2State : StateMaker
@export var DownSlash3State : StateMaker
@export var EnteringDoorState : StateMaker
@export var ExitingDoorState : StateMaker
@export var JumpState : StateMaker
@export var FallState : StateMaker
@export var LandingState : StateMaker
@export var DashState : StateMaker
@export var DashJumpState : StateMaker
@export var DashFallState : StateMaker
@export var DashSlashState : StateMaker
@export var AirDashState : StateMaker
@export var AirSlashState : StateMaker
@export var AirSlashDashState : StateMaker
@export var CrazyFlyState : StateMaker 
@export var DashCrazyFlyState : StateMaker 
@export var WallSlideState : StateMaker
@export var WallSlashState : StateMaker
@export var WallJumpState : StateMaker
@export var ClimbStartState : StateMaker
@export var ClimbState : StateMaker
@export var ClimbSlashState : StateMaker
@export var ClimbEndState : StateMaker
@export var ShakeWaterState : StateMaker
@export var LightingKiteState : StateMaker
@export var AvoiderDownState : StateMaker
@export var HangingTop: StateMaker
@export var HangingToClimbTop: StateMaker
@export var HangingToClimbDown: StateMaker
@export var HangingSlash: StateMaker
@export var KnockBackState : StateMaker
@export var DeathState : StateMaker
@export var TauntVictoryState : StateMaker
@export var OnPogo : StateMaker
@export var OnPogoDash : StateMaker
@export var OnSliderState : StateMaker
@export var ToTeleport : StateMaker
@export var TeleportToIdle : StateMaker
@export var Stop : StateMaker

##Set the current equipped skills in character
@export var I_Current_DashAttack : StateMaker #Dash + Attack
@export var I_Current_Air_AltAttack : StateMaker #on air: AltAttack
@export #Usally to use in crazy fly and dash crazy fly
var I_Current_DashAir_AltAttack : StateMaker #on air while dashing: AltAttack
@export var I_Current_AttackUp : StateMaker #Attack + K_UP
@export var I_Current_Air_AttackDown : StateMaker #on air: Attack + K_DOWN

@export var Has_DashAttack : bool = false #Dash + Attack
@export var Has_Air_AltAttack : bool = false #on air: AltAttack
@export var Has_DashAir_AltAttack : bool = false #on air while dashing: AltAttack
@export var Has_AttackUp : bool = false #Attack + K_UP
@export var Has_Air_AttackDown : bool = false #on air: Attack + K_DOWN

var Current_DashAttack : StateMaker 
var Current_Air_AltAttack : StateMaker 
var Current_DashAir_AltAttack : StateMaker 
var Current_AttackUp : StateMaker 
var Current_Air_AttackDown : StateMaker 

var velocity_modifier : float = 1.0

#@export var BladeFanState : StateMaker
#@export var BladeFanJumpState : StateMaker
##Variables:
#var bubbles_preload = preload("res://Scenes/Triggers/FXs/Particles/0.tscn")
##STATIC VARS

static var GameDisbaleParticles : bool = GameSettings.ConfigurationManager.GameplaySettings.Game_Configurations_Dictionary.Disable_Particles
static var Player_Data = PlayerResources.new()
static var Data : Dictionary #Current data
static var Checkpoint_Data : Dictionary #Data stored in checkpoints

var get_moving_platform : MiscPlatform
var is_on_NIGHTMARE_TRAVEL : bool = false #If player entered void to nightmare level path
var is_sliding : bool = false #If player is sliding over a slippery solid ex: water, ice etc
var is_on_slider : bool = false
var areaS_current_zoomscale = Vector2.ONE
var Gravity : float = ProjectSettings.get_setting("physics/2d/default_gravity")
var TimerToPressArrowCounter = 1.0
var is_on_water : bool = false
var is_small_area_on_water : bool = false
var is_climbing : bool = false
var can_jump : bool #Avoid coyote timer bug
var is_landing : bool = false
var can_air_slash : bool = true
var can_climb :bool = false
var can_air_dash : bool #Avoid mutiple dashs on air
var can_crazy_fly : bool = true
var can_dash : bool = true
var can_slash : bool = true
var can_hang_top_solid : bool = false
var is_crazying_fly : bool = false
###var animation_name : String = ""
#var vector_snap = direction_snap * SNAP_RANGE
###var snap_floor = Vector2.DOWN setget update_floor
var Pressed_Times_L : int = 0 #Double click dash
var Pressed_Times_R : int = 0#Double click dash
var Pressed_Times_D : int = 0#Double click hang down
var is_wet : bool = false
var is_dead : bool = false
var ladders : Array = []
var center_position = Vector2.ZERO
var get_state = null
var is_sprite_flipped : bool = false
var ladder_node = null #get_current_ladder_climbing
var is_on_door : bool = false
var door_instance : Door = null
var can_produz_bolha = true
var get_arvore = null
var facing_side : int = 1
var hurt_direction = null #Give var to Knockback state
var gravity_engine : float = ProjectSettings.get_setting("physics/2d/default_gravity")
var can_play_charging_sound : bool = false
var is_impulsed_by_forces : bool = false
var can_move : bool = true
var current_nightfly_level_cleared : bool = false
var checkpoint : Checkpoint #Get checkpoint node
var is_inside_checkpoint : bool = false
var first_position : Vector2 #Store the first position the player is inside a level
var checkpoint_is_marked : bool = false
var impulsed_by_spring : bool = false
#var Jump_increaser : float = 0.0 #If player gets his jump higher by pressing a spring
var Velocity_Impulse : Vector2 = Vector2.ZERO

var current_start_point: Node2D #= [store current start point]

var is_on_NIGHTMARE_PORTAL: bool = false

##Get Nodes:
#Sprite2Ds
@onready var sprite : Sprite2D = %FlockosSprite
#@onready var eletric_body: AnimatedSprite2D = %Eletric_Body
#Area2Ds
@onready var moving_platform_getter: Area2D = $Mask/MovingPlatformGetter
#@onready var snap_solid_up_buffer: Area2D = %SnapSolidUpBuffer
@onready var hitbox : Area2D = %Hitbox
@onready var ladder_box: Area2D = %LadderBox
@onready var water_box: Area2D = %WaterBox
#CollisionShapes
@onready var hitbox_mask: CollisionShape2D = %HitboxMask
@onready var hitbox_down_mask: CollisionShape2D = %DownHitboxMask
@onready var hitbox_wall_mask: CollisionShape2D = %WallSlideMask
#@onready var mask_alt: CollisionShape2D = %Mask_Alt
@onready var main_mask: CollisionShape2D = %Mask
@onready var mask_down: CollisionShape2D = %MaskDown
@onready var persistent_mask: CollisionShape2D = %PersistentMask
#Class_Names
@onready var UI : Global_Interface = %UserInterface
#AnimationPlayer
@onready var PlayerNode : AnimationPlayer = %AnimationPlayer
@onready var indicator_player: AnimationPlayer = %IndicatorPlayer
#AnimationTree
@onready var AnimationTraveler : AnimationTree = %Animation_Traveler
#Raycasts
@onready var Ceil_L0: RayCast2D = %Ceil_L0
@onready var Ceil_L1: RayCast2D = %Ceil_L1
@onready var Ceil_R0: RayCast2D = %Ceil_R0
@onready var Ceil_R1: RayCast2D = %Ceil_R1
@onready var Wall_left_ray_0: RayCast2D = $RayCasts/Wall_Rays/Left_0
@onready var Wall_left_ray_1: RayCast2D = $RayCasts/Wall_Rays/Left_1
@onready var Wall_left_ray_2: RayCast2D = $RayCasts/Wall_Rays/Left_2
@onready var Wall_left_ray_3: RayCast2D = $RayCasts/Wall_Rays/Left_3
@onready var Wall_left_ray_4: RayCast2D = $RayCasts/Wall_Rays/Left_4
@onready var Wall_right_ray_0: RayCast2D = $RayCasts/Wall_Rays/Right_0
@onready var Wall_right_ray_1: RayCast2D = $RayCasts/Wall_Rays/Right_1
@onready var Wall_right_ray_2: RayCast2D = $RayCasts/Wall_Rays/Right_2
@onready var Wall_right_ray_3: RayCast2D = $RayCasts/Wall_Rays/Right_3
@onready var Wall_right_ray_4: RayCast2D = $RayCasts/Wall_Rays/Right_4
@onready var WallFloor_left_0: RayCast2D = $RayCasts/WallFloor_Rays/Left_0
@onready var WallFloor_left_1: RayCast2D = $RayCasts/WallFloor_Rays/Left_1
@onready var WallFloor_left_2: RayCast2D = $RayCasts/WallFloor_Rays/Left_2
@onready var WallFloor_left_3: RayCast2D = $RayCasts/WallFloor_Rays/Left_3
@onready var WallFloor_left_4: RayCast2D = $RayCasts/WallFloor_Rays/Left_4
@onready var WallFloor_right_0: RayCast2D = $RayCasts/WallFloor_Rays/Right_0
@onready var WallFloor_right_1: RayCast2D = $RayCasts/WallFloor_Rays/Right_1
@onready var WallFloor_right_2: RayCast2D = $RayCasts/WallFloor_Rays/Right_2
@onready var WallFloor_right_3: RayCast2D = $RayCasts/WallFloor_Rays/Right_3
@onready var WallFloor_right_4: RayCast2D = $RayCasts/WallFloor_Rays/Right_4
@onready var Ladder_ray_1: RayCast2D = $RayCasts/Ladder_Rays/Ray_1
@onready var Ladder_ray_2: RayCast2D = $RayCasts/Ladder_Rays/Ray_2
@onready var Ladder_ray_3: RayCast2D = $RayCasts/Ladder_Rays/Ray_3
#Maker2Ds
@onready var PivotSmoother: Marker2D = %PivotSmoother
@onready var PivotCenter: Marker2D = %Pivot
@onready var PivotWall: Marker2D = %PivotWall
@onready var PivotTrail: Marker2D = %PivotTrail
@onready var BigSlash_pos_right: Marker2D = %BigSlashPosRight
@onready var BigSlash_pos_left: Marker2D = %BigSlashPosLeft
@onready var left_up_click_zone: Marker2D = %LeftUp_ClickZone
@onready var right_down_click_zone: Marker2D = %RightDown_ClickZone
#Nodes
@onready var States : PlayerStateParent = %Machine_State
#Nodes2Ds
@onready var indicator_sprite: Node2D = %IndicatorSprite
@onready var MeeleHitbox: Node2D = %Meele_Hitbox
@onready var projectile_maker : Node2D = %Projectiles
@onready var Ladder_Rays: Node2D = %Ladder_Rays
@onready var Wall_Rays: Node2D = %Wall_Rays
@onready var WallFloor_rays: Node2D = %WallFloor_Rays
##Sound Effects
@onready var SFX_attack_hit := SoundEffects.get_child(0) as AudioStreamPlayer
@onready var SFX_kickback := SoundEffects.get_child(1) as AudioStreamPlayer
@onready var SFX_meow := SoundEffects.get_child(2) as AudioStreamPlayer
@onready var SFX_meow_hurt := SoundEffects.get_child(3) as AudioStreamPlayer
@onready var SFX_meow_death := SoundEffects.get_child(4) as AudioStreamPlayer
@onready var SFX_jump := SoundEffects.get_child(5) as AudioStreamPlayer
@onready var SFX_fall_release := SoundEffects.get_child(6) as AudioStreamPlayer
@onready var SFX_dash_saw := SoundEffects.get_child(7) as AudioStreamPlayer
@onready var SFX_slash_bite_to_saw := SoundEffects.get_child(8) as AudioStreamPlayer
@onready var SFX_dash := SoundEffects.get_child(9) as AudioStreamPlayer
@onready var SFX_wall_kick := SoundEffects.get_child(10) as AudioStreamPlayer
@onready var SFX_knockback := SoundEffects.get_child(11) as AudioStreamPlayer
@onready var SFX_thunder_intro := SoundEffects.get_child(12) as AudioStreamPlayer
@onready var SFX_thunder_outro := SoundEffects.get_child(13) as AudioStreamPlayer
@onready var SFX_door_enter := SoundEffects.get_child(14) as AudioStreamPlayer
@onready var SFX_door_quit := SoundEffects.get_child(15) as AudioStreamPlayer
@onready var SFX_splash_water_enter := SoundEffects.get_child(16) as AudioStreamPlayer
@onready var SFX_splash_water_exit := SoundEffects.get_child(17) as AudioStreamPlayer
@onready var SFX_splash := SoundEffects.get_child(18) as AudioStreamPlayer
@onready var SFX_water_swing := SoundEffects.get_child(19) as AudioStreamPlayer
@onready var SFX_saw_pit := SoundEffects.get_child(20) as AudioStreamPlayer
@onready var SFX_purr := SoundEffects.get_child(21) as AudioStreamPlayer
@onready var SFX_fan := SoundEffects.get_child(22) as AudioStreamPlayer
@onready var SFX_slam_thunder := SoundEffects.get_child(23) as AudioStreamPlayer
@onready var SFX_firework_bites := SoundEffects.get_child(24) as AudioStreamPlayer
@onready var SFX_eletric_glitch := SoundEffects.get_child(25) as AudioStreamPlayer
@onready var SFX_eletricity_charge := SoundEffects.get_child(26) as AudioStreamPlayer
@onready var eletric_body_particles: ParticleLogic = $Visuals/Eletric_Body_Particles

func _ready() -> void:
	%RoughSpark.emitting = false
	%FlashHitTree.active = true
	current_start_point = GlobalEngine.GamePlayer.Universe_2D_Trigger.current_level.EntracesMarker.get_child(0)
	
	#is_dead = false
	GlobalEngine.flockos = self
	TransitionFaders.set_animation_fader("OpenEye")
	#print("Flockos stored in GlobalEngine as ", GlobalEngine.flockos)
	Player_Data = Own_Player_Data
	print(GlobalEngine.GamePlayer)
	
	CURRENT_SNAP_LENGTH = floor_snap_length
	
	$Audios/SFX.stop()
	
	Hitted = false
	current_nightfly_level_cleared = false
	
	
	Current_DashAttack = I_Current_DashAttack
	Current_Air_AltAttack = I_Current_Air_AltAttack
	Current_DashAir_AltAttack = I_Current_DashAir_AltAttack
	Current_AttackUp = I_Current_AttackUp
	Current_Air_AttackDown = I_Current_Air_AttackDown
	
	%PivotSmoother.global_position = PivotCenter.global_position
	
	##Apply state machine
	States.init(self)

	remove_from_group("Enemies")
	remove_from_group("Hurters")

	indicator_sprite.hide()
	
	get_arvore = get_tree()
	show()
	
	
	#get_state
	get_state = States.Default_State

	#Auto activate the animationtree node
	if AnimationTraveler.active == false:
		AnimationTraveler.active = true
	
	##Auto connect nodes
	if not UI.signal_when_health_is_over.is_connected(die):
		UI.signal_when_health_is_over.connect(die)
	if not EnteringDoorState.goto_destination.is_connected(_on_EnteringDoor_goto_destination):
		EnteringDoorState.goto_destination.connect(_on_EnteringDoor_goto_destination)

func _unhandled_input(event: InputEvent) -> void:
	States.input(event)
func _input(event: InputEvent) -> void:
	
	if is_on_NIGHTMARE_PORTAL and Input.is_action_just_pressed("Interact_Input"):
		Dive_into_nightmare_path()
	
	if Input.is_action_pressed("Right") and Input.is_action_pressed("Left"):
		Pressed_Times_L = 0
		Pressed_Times_R = 0
	
	#Plus key pressed times:
	if Input.is_action_just_pressed("Left") and not Input.is_action_pressed("Right"):
		Pressed_Times_L += 1
		Pressed_Times_R = 0
	if Pressed_Times_L >= 2:
		Pressed_Times_L = 2
		
	if Input.is_action_just_pressed("Right") and not Input.is_action_pressed("Left"):
		Pressed_Times_R += 1
		Pressed_Times_L = 0
	if Pressed_Times_R >= 2:
		Pressed_Times_R = 2
		
	if Input.is_action_just_pressed("Down"):
		Pressed_Times_D += 1
	if Pressed_Times_D >= 2:
		Pressed_Times_D = 2
		
		
	##drop from only up floor
	if is_on_floor():
		if event.is_action_pressed("Down") and event.is_action_pressed("Jump"):
			position.y += 0.1
	
	
func _physics_process(delta: float) -> void:
	
	#print("impulsed by spring = ",impulsed_by_spring)
	#Update maskdown pos to make it not clip when rotating on slopes
	%MaskDown.global_position = %MaskSnapperPos.global_position
	%PersistentMask.global_position = %MaskPersSnapperPos.global_position
	#
	###Rotate sprite alongside slopes
	if is_on_floor():
		impulsed_by_spring = false
		if get_floor_angle(up_direction) <= deg_to_rad(floor_max_angle):
			"Sprite rotation disabled"
			var tweni = create_tween()
			tweni.tween_property(%FlockosSprite, 
			"rotation",
			get_floor_normal().angle()+deg_to_rad(90), 
			0.1).set_ease(Tween.EASE_IN)
			
			tweni.play()
			
			tweni = create_tween()
			tweni.tween_property(%Mask, 
			"rotation",
			get_floor_normal().angle()+deg_to_rad(90), 
			0.1).set_ease(Tween.EASE_IN)
			
			tweni.play()
			
			tweni = create_tween()
			tweni.tween_property(%MaskDown, 
			"rotation",
			get_floor_normal().angle()+deg_to_rad(90), 
			0.1).set_ease(Tween.EASE_IN)
			
			tweni.play()
			
			tweni = create_tween()
			tweni.tween_property(%PersistentMask, 
			"rotation",
			get_floor_normal().angle()+deg_to_rad(90), 
			0.1).set_ease(Tween.EASE_IN)
			
			tweni.play()
		
		else:
			var tweni = create_tween()
			tweni.tween_property(%FlockosSprite, 
			"rotation",
			0, 
			0.03).set_ease(Tween.EASE_OUT)
			tweni.play()
			
			tweni = create_tween()
			tweni.tween_property(%Mask, 
			"rotation",
			0, 
			0).set_ease(Tween.EASE_IN)
			
			tweni.play()
			
			tweni = create_tween()
			tweni.tween_property(%MaskDown, 
			"rotation",
			0, 
			0).set_ease(Tween.EASE_IN)
			
			tweni.play()
			
			tweni = create_tween()
			tweni.tween_property(%PersistentMask, 
			"rotation",
			0, 
			0).set_ease(Tween.EASE_IN)
			
			tweni.play()
	
	velocity.x *= velocity_modifier
	velocity_modifier = clamp(velocity_modifier, 0.1, 2.0)
	
	if velocity_modifier < 1.0:
		%ColorState.play("Azul")
		velocity_modifier = move_toward(velocity_modifier, 1.0, 0.01)
	else:
		%ColorState.play("RESET")
	
	%PivotSmoother.global_position = lerp(
		%PivotSmoother.global_position,
		%Pivot.global_position,
		0.2
		)
	
	States.physics_process(delta)
	
	if not ladder_box.has_overlapping_areas():
		can_climb = false
	
	##Not a function
	move_and_slide()
	##VFXs
	smoke_dash()
	
	##update_data()
	
	
	
	if is_on_water:
		can_crazy_fly = true
	
	if AnimationTraveler.active == false:
		AnimationTraveler.active = true
	

	#Variable to get if the area is a door:
	is_on_door = (
		hitbox.get_overlapping_areas()[0] is Door
		if hitbox.get_overlapping_areas().size() != 0
		else false
		)
#
	
	#Check if you can press the arrow again to execute dash:
	if Pressed_Times_R != 0 or Pressed_Times_L != 0 or Pressed_Times_D != 0:
		
		if TimerToPressArrowCounter > 0:
			TimerToPressArrowCounter -= delta
		else:
			TimerToPressArrowCounter = 0
			Pressed_Times_R = 0
			Pressed_Times_L = 0
			Pressed_Times_D = 0
			
	elif Pressed_Times_R == 0 and Pressed_Times_L == 0 and Pressed_Times_D == 0:
		TimerToPressArrowCounter = time_to_press_arrow_again
	
	#Give position based on a pivot
	center_position = %Pivot.global_position
	
	#apply vars on floor
	if is_on_floor():
		can_air_slash = true
		can_air_dash = true
		can_crazy_fly = true
		disable_wall_raycast()
		
	else:
		enable_wall_raycast()

	#Flip Sprite
	#if not On_Wall() and can_flip:
	if can_flip:
		#Make a custom flip for sprite:
		if is_sprite_flipped and Input.is_action_just_pressed("Right") || !is_sprite_flipped and Input.is_action_just_pressed("Left"):
			AnimationTraveler.set("parameters/Run/AutoStarts/To_Flip/current", 0)
		elif !is_sprite_flipped and Input.is_action_just_pressed("Right") || is_sprite_flipped and Input.is_action_just_pressed("Left"):
			AnimationTraveler.set("parameters/Run/AutoStarts/To_Flip/current", 1)
		
		if Input.is_action_pressed("Left") and !Input.is_action_pressed("Right"):
			is_sprite_flipped = true
		elif Input.is_action_pressed("Right") and !Input.is_action_pressed("Left"):
			is_sprite_flipped = false
		
	#Flip sprite on var
	#set direction of the meele
	
	if is_sprite_flipped:
		facing_side = -1
	else:
		facing_side = 1
		
	sprite.scale.x = facing_side
	MeeleHitbox.scale.x = facing_side
	hitbox.scale.x = facing_side
	
func _process(delta: float) -> void:
	#print("self", position)
	#print("mask", main_mask.position)
	#print(get_moving_platform, "  ", moving_platform_getter.get_overlapping_areas())
	if (is_on_floor() and get_platform_velocity() == Vector2.ZERO) or\
	(moving_platform_getter.get_overlapping_areas().size() == 0):
		get_moving_platform = null
	#if get_moving_platform != null:
		#print("get_moving_platform = ", get_moving_platform)
		#
	#if (is_on_floor() and get_platform_velocity() == Vector2.ZERO) or\
	#(not is_on_floor() and States.Default_State != HangingTop):
		#get_moving_platform = null
	
		
	if Player_Data.Current_Health <= 0:
		is_dead = true
		
	if not impulsed_by_spring:
		Velocity_Impulse = Vector2.ZERO
	
	
	States.process(delta)
	get_ladder_top()
	
	if %Machine_State.Default_State.Ducking_State == true:
		main_mask.disabled = true
		mask_down.disabled = false
	else:
		main_mask.disabled = false
		mask_down.disabled = true
	
	if is_on_water:
		is_wet = false
	
	
	##Mark checkpoint
	if is_inside_checkpoint:
		#if Input.is_action_just_pressed("Down") or Input.is_action_just_pressed("Up"):
			if checkpoint != null:
				checkpoint_is_marked = true
				checkpoint.mark_this_checkpoint()
	
		
	#modulate = Color(1.2, 1.2, 1.8) if UI.is_awaken_energy_full else Color(1.0, 1.0, 1.0)
	if UI.is_awaken_energy_full:
		if Hitted:
			%FlashHitTree["parameters/playback"].travel("Knockback")

		if can_be_knockbacked():
			%FlashHitTree["parameters/playback"].travel("Lighted")
			
		%FlashHitTree["parameters/conditions/Awaken_Isnt_Full"] = false
		%FlashHitTree["parameters/conditions/Is_Not_Lighted"] = false
		%FlashHitTree["parameters/conditions/Is_Lighted"] = true
		eletric_body_particles.emitting = true
		eletric_body_particles.get_child(0).emitting = true
	else:
		eletric_body_particles.emitting = false
		eletric_body_particles.get_child(0).emitting = false
		%FlashHitTree["parameters/conditions/Is_Not_Lighted"] = true
		%FlashHitTree["parameters/conditions/Is_Lighted"] = false
		%FlashHitTree["parameters/conditions/Awaken_Isnt_Full"] = true
		
#To change level's current path to it's nightmare side:
func Dive_into_nightmare_path() -> void:
	print("drive through nightmare side")
	States.Default_State = $Machine_State/ToTeleport
	$Machine_State/ToTeleport.enter()
	#TransitionFaders.set_animation_fader("CloseEye")
	
	
"An func that animates the transition of a camera zooming"
func tween_camerazoom(ZoomScale_Tween: Vector2, 
Duration: float, Transition: Tween.TransitionType,
Ease: Tween.EaseType) -> void:
	var tween_new = create_tween()
	tween_new.tween_property(self, "ZoomScale", 
	ZoomScale_Tween, Duration).set_trans(Transition).set_ease(Ease)
	
"Return the current zoom of an area"
func return_tween_camerazoom(Duration: float,
Transition: Tween.TransitionType = Tween.TransitionType.TRANS_LINEAR,
Ease: Tween.EaseType = Tween.EaseType.EASE_IN_OUT) -> void:
	var tween_new = create_tween()
	tween_new.tween_property(self, "ZoomScale", 
	areaS_current_zoomscale, Duration).set_trans(Transition).set_ease(Ease)
func play_sfx(id: int) -> void:
	SoundEffects.play_sound(id)

##Snap the player to climb to the solidup
func is_on_semifloor() -> bool:
	if is_on_floor():
		return %Solidup_Ray_1.is_colliding() or \
		%Solidup_Ray_2.is_colliding() or \
		%Solidup_Ray_3.is_colliding()
	return false


#func snap_solidup(solidup: Node2D):
	#if not is_on_floor() and velocity.y < 0 and solidup.is_in_group("Solidup"):
		#global_position.y = solidup.global_position.y
func get_ladder_top():
	ladders = ladder_box.get_overlapping_bodies()
func play_animation(transition_name, current_transition):
	if transition_name != null:
		AnimationTraveler.set("parameters/" + str(transition_name) + "/current", current_transition)
	else:
		push_error("Animation name has not found!")
func travel_animation(get_animation_node: String, travel: String):
	AnimationTraveler.get("parameters/" + get_animation_node + "/playback").travel(travel)
func disable_wall_raycast():
	"Disable wall ray"
	for ray in Wall_Rays.get_children():
		if ray is RayCast2D:
			ray.enabled = false
func enable_wall_raycast():
	"Enable wall ray"
	for ray in Wall_Rays.get_children():
		if ray is RayCast2D:
			ray.enabled = true

"Bool functions"
func ceil_ray_is_colliding() -> bool:
	return (Ceil_L0.is_colliding() or
	Ceil_L1.is_colliding() or
	Ceil_R0.is_colliding() or
	Ceil_R1.is_colliding())
func ceil_left_is_colliding() -> bool:
	return (Ceil_L0.is_colliding() and !Ceil_L1.is_colliding()
	and !Ceil_R0.is_colliding() and !Ceil_R1.is_colliding())
func ceil_right_is_colliding() -> bool:
	return (Ceil_L0.is_colliding() and !Ceil_L1.is_colliding()
	and !Ceil_R0.is_colliding() and Ceil_R1.is_colliding())
func Left_raycast() -> bool:
	if get_floor_normal() == Vector2.UP or !is_on_floor():
		return (
		Wall_left_ray_0.is_colliding() or
		Wall_left_ray_1.is_colliding() or
		Wall_left_ray_2.is_colliding() or
		Wall_left_ray_3.is_colliding() or
		Wall_left_ray_4.is_colliding()
		)
	else:
		return false
func Right_raycast() -> bool:
	if get_floor_normal() == Vector2.UP or !is_on_floor():
		return (
		Wall_right_ray_0.is_colliding() or
		Wall_right_ray_1.is_colliding() or
		Wall_right_ray_2.is_colliding() or
		Wall_right_ray_3.is_colliding() or
		Wall_right_ray_4.is_colliding() 
		)
	else:
		return false
func WallfloorLeft_raycast() -> bool: #To get if the wallrays from floor is colliding:
	if get_floor_normal() == Vector2.UP or !is_on_floor():
		return (
		WallFloor_left_0.is_colliding() or
		WallFloor_left_1.is_colliding() or
		WallFloor_left_2.is_colliding() or
		WallFloor_left_3.is_colliding() or
		WallFloor_left_4.is_colliding()
		)
	else:
		return false
func WallfloorRight_raycast() -> bool:
	if get_floor_normal() == Vector2.UP or !is_on_floor():
		return (
		WallFloor_right_0.is_colliding() or
		WallFloor_right_1.is_colliding() or
		WallFloor_right_2.is_colliding() or
		WallFloor_right_3.is_colliding() or
		WallFloor_right_4.is_colliding()
		)
	else:
		return false
func On_Wall() -> bool:
	if get_floor_normal() == Vector2.UP or !is_on_floor():
		return Left_raycast() or Right_raycast()
	else:
		return false
func On_Wallfloor() -> bool: #Checkwall when is on floor to idle.
	if get_floor_normal() == Vector2.UP or !is_on_floor():
		return WallfloorLeft_raycast() or WallfloorRight_raycast()
	else:
		return false
func check_ladder_trap() -> bool:
	if not is_on_floor():
		return false
	else:
		return Ladder_ray_1.is_colliding() or \
		Ladder_ray_2.is_colliding() or \
		Ladder_ray_3.is_colliding()
#Check directions:
func velocity_is_to_left() -> bool:
	return velocity.x < 0
func velocity_is_to_right() -> bool:
	return velocity.x > 0
func velocity_is_to_up() -> bool:
	return velocity.y < 0
func velocity_is_to_down() -> bool:
	return velocity.y > 0
func heal_lerped(value: float) -> void:
	UI.can_fill = true
	UI.fill_bar_animation(value)
func update_health(value: int) -> void:
	UI.change_Current_Health_Value(UI.Health_Value + value)
func update_awaken_value(value: int) -> void:
	UI.change_Current_AwakenEnergy_Value(UI.Awaken_Value + value)
func modify_velocity(value: float) -> void:
	velocity_modifier = value
func _Knockbacked(body: Node) -> void:
	#Shake hud
	UI.shake()
	
	#Death pitfall
	if body.is_in_group("pitfall"):
		die()
	
	#if Flockos recives a damage
	if is_immune == false:
		if body.is_in_group("Hurters"):
			Hitted = true
			#hurt direction
			hurt_direction = global_position.direction_to(body.global_position).x
			#give damage types
			#0 = normal damage
			#1 = instant kill
			if body is Static_Hurter:
				if body.damage_type == 0:
					update_health(-body.damage_force)
				elif body.damage_type == 1:
					update_health(-UI.Health_Max)
			else:
				if body.name == "Spikes":
					update_health(-UI.Health_Max/1.5)
				if body is not TileMapLayer:
					update_health(-body.damage_force)
				
			if body is Enemy:
				Hitted = true
				body.hitted(1, true)
			
	#Swing
	if body.is_in_group("Swimmable"):
		is_on_water = true
func _on_Hitbox_body_exited(body: Node2D) -> void:
	#print("Player exited on ", body.name)
	#Swing
	if body.is_in_group("swimmable"):
		is_on_water = false
		is_wet = true
func _on_LadderBox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Climbable") and not area.is_in_group("TopLadders"):
		can_climb = true
func _on_LadderBox_area_exited(area: Area2D) -> void:
	if area.is_in_group("Climbable") and not area.is_in_group("TopLadders"):
		can_climb = false
func _on_spring_box_area_entered(area: Area2D) -> void:
	
	#print("persistent_box_area_entered in ", area.name)
	
	#On Spring
	if area is Spring:
		impulsed_by_spring = true
		velocity = area.spring_force_direction if Input.is_action_pressed("Jump")\
		else area.spring_force_direction/2
		#%Trail.can_trail = Input.is_action_pressed("Jump")
		
		area.get_node("Sprite2D/AnimationPlayer").play("Spring")
		await area.get_node("Sprite2D/AnimationPlayer").animation_finished
		area.get_node("Sprite2D/AnimationPlayer").play("Idle")
func _on_persistent_box_area_entered(area: Area2D) -> void:
	
	#print("persistent_box_area_entered in ", area.name)
		
	
	##On Door
	if area is Door or Checkpoint and not Spring:
		if States.Default_State != EnteringDoorState \
		and States.Default_State != ExitingDoorState:
			show_indicator()
	elif area is Door:
		door_instance = area
	
	##On liquid
	if area.is_in_group("swimmable"):
		is_on_water = true
		
	##On Checkpoint
	if area is Checkpoint:
		checkpoint = area as Area2D
		is_inside_checkpoint = true
		
		
	##Contact with non solid interactives
	if area is Level_Changer:
			
		States.change_state(Stop)
		TransitionFaders.set_animation_fader("CloseEye")
		
		#area destiny -> DirName + LevelArcName + LevelID
		var area_destiny =\
		GlobalEngine.GamePlayer.Universe_2D_Trigger.current_level.current_arc_world+\
		GlobalEngine.GamePlayer.Universe_2D_Trigger.current_level.LevelArcName+\
		str(area.Area_Number) + ".tscn"
		print("area_destiny = " , area_destiny)
		
		if TransitionFaders.current_transition_name == "CloseEye":
			if not TransitionFaders.Transition_Animation_Finished.is_connected(GlobalEngine.GamePlayer.Universe_2D_Trigger.goto_next_level):
				TransitionFaders.Transition_Animation_Finished.connect(
					GlobalEngine.GamePlayer.Universe_2D_Trigger.goto_next_level.bind(
						area_destiny, area.Entrace_Mode, area.Exit_ID, area.Current_Phantom_Camera_ID))
	
	#In kart
	if area.get_parent() is Kart:
		
		set("floor_stop_on_slope", true)
func _hitbox_area_entered(area: Area2D) -> void:
	print(name, " entered on ", area.name)
	if area.is_in_group("Nightmare_Portal"):
		is_on_NIGHTMARE_PORTAL = true
func _hitbox_area_exited(area: Area2D) -> void:
	
	print(name, " exited on", area.name)
	if area.is_in_group("Nightmare_Portal"):
		is_on_NIGHTMARE_PORTAL = false
		
	if area is Door or Checkpoint:
		hide_indicator()
	##Out of door
	elif area is Door:
		var door = area as Door
		if is_on_door == false:
			door_instance = null
	##Out checkpoint
	elif area is Checkpoint:
		is_inside_checkpoint = false
		
	##Out of liquid
	if is_in_group("Swimmable"):
		is_on_water = false
		
	if area.get_parent() is Kart:
		set("floor_stop_on_slope", false)
		
		#
	##Area2D to detect damages
	##Shake hud
	#UI.shake()
	##if Flockos recives a damage
	#if is_immune == false:
		#if area.is_in_group("Hurters"):
			#Hitted = true
			##hurt direction
			#hurt_direction = global_position.direction_to(area.global_position).x
			##give damage types
			##0 = normal damage
			##1 = instant kill
			#if area.get_parent() is Static_Hurter:
				#if area.get_parent().damage_type == 0:
					#update_health(-area.get_parent().damage_force)
				#elif area.get_parent().damage_type == 1:
					#update_health(-UI.Health_Max)
			#
			#
#Area water
func _on_water_box_area_entered(area: Area2D) -> void:
	
	var Drop = preload("res://Scenes/Triggers/FXs/Particles/7.tscn").instantiate()
	
	if area.is_in_group("Swimmable"):
		is_on_water = true
		
		if velocity.y > 800:
			SFX_splash.play()
			Triggers.create_VisualEffectTrigger(3, global_position, Vector2(1.2,1.2))
			Drop.global_position = Vector2(global_position.x, snappedf(position.y, 64.0))
			Drop.set_as_top_level(true)
			Drop.set("z_index", 200)
			add_sibling(Drop)
			
		SFX_splash_water_enter.play()
		SFX_splash_water_exit.stop()
	Gravity = Gravity/2
	JumpState.Jump_height += 180
	DashJumpState.Jump_height += 180
func _on_water_box_area_exited(area: Area2D) -> void:
	if area.is_in_group("Swimmable"):
		is_on_water = false
		is_wet = true
		SFX_splash_water_enter.stop()
		SFX_splash_water_exit.play()
	Gravity = Gravity*2
	JumpState.Jump_height -= 180

	DashJumpState.Jump_height -= 180
func _on_smaller_water_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("Swimmable"):
		is_small_area_on_water = true
func _on_smaller_water_box_area_exited(area: Area2D) -> void:
	if area.is_in_group("Swimmable"):
		is_small_area_on_water = false
func _on_smaller_water_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("Swimmable"):
		is_small_area_on_water = true
func _on_smaller_water_box_body_exited(body: Node2D) -> void:
	if body.is_in_group("Swimmable"):
		is_small_area_on_water = false
#Body water
func _on_WaterBox_body_entered(body: Node2D) -> void:
	
	if body.is_in_group("Swimmable"):
		is_on_water = true
		
		if velocity.y > 800:
			SFX_splash.play()
			Triggers.create_VisualEffectTrigger(3, global_position, Vector2(1.2,1.2))
		
		SFX_splash_water_enter.play()
		SFX_splash_water_exit.stop()
	Gravity = Gravity/2
	JumpState.Jump_height += 180
	DashJumpState.Jump_height += 180
func _on_WaterBox_body_exited(body: Node2D) -> void:
	if body.is_in_group("Swimmable"):
		is_on_water = false
		is_wet = true
		SFX_splash_water_enter.stop()
		SFX_splash_water_exit.play()
	Gravity = Gravity*2
	JumpState.Jump_height -= 180

	DashJumpState.Jump_height -= 180
func _on_EnteringDoor_goto_destination() -> void:
	if is_instance_valid(door_instance):
		var doormanager = door_instance.get_parent() as DoorManager
		var get_scene = doormanager.Scene_Destiny
		match doormanager.Door_Mode:
			doormanager.DoorMode.Wrapper:
				global_position = door_instance.Destination.global_position
			doormanager.DoorMode.SceneChanger:
				#get_tree().change_scene_to_packed(get_scene)
				GlobalEngine.GamePlayer.set_Universe2D_scene(get_scene)
#Play when picking some pickup
func light_pickuping() -> void:
	%FlashHitTree["parameters/playback"].travel("Lighted_Heal")
func enable_snap_floor() -> void:
	floor_snap_length = CURRENT_SNAP_LENGTH
func disable_snap_floor() -> void:
	floor_snap_length = 0
func hide_indicator() -> void:
	indicator_sprite.hide()
	indicator_player.play("res")
func show_indicator() -> void:
	indicator_sprite.show()
	indicator_player.play("!")
func can_be_knockbacked() -> bool:
	return !is_immune and Hitted
func smoke_dash() -> void:
	##Smoke Dash
	if is_on_floor():
		if States.Default_State == DashState or\
		States.Default_State == DashSlashState:
			var timer_caseiro = Timer.new()
			TemporaryNodes.add_child(timer_caseiro)
			timer_caseiro.one_shot = true
			timer_caseiro.start(0.1)
			await timer_caseiro.timeout
			#print("timer_caseiro from ", name ," is finished")
			timer_caseiro.queue_free()
			#Repeat condition of yield stop
			if States.Default_State == DashState or\
			States.Default_State == DashSlashState:
				Triggers.create_VisualEffectTrigger_bydelay(5, global_position, Vector2.ONE, 0.02)

	if States.Default_State == WallSlideState:
		var timer_caseiro = Timer.new()
		TemporaryNodes.add_child(timer_caseiro)
		timer_caseiro.one_shot = true
		timer_caseiro.start(0.1)
		await timer_caseiro.timeout
		#print("timer_caseiro from ", name ," is finished")
		timer_caseiro.queue_free()
		#Repeat condition of yield stop
		if States.Default_State == WallSlideState and velocity.y != 0:
			if $RayCasts/WallFloor_Rays/Left_4.is_colliding() or \
			$RayCasts/WallFloor_Rays/Right_4.is_colliding():
				Triggers.create_VisualEffectTrigger_bydelay(5, %PivotWall.global_position, Vector2.ONE, 0.02)
func _on_slash_delay_timeout() -> void:
	can_slash = true
func _on_hang_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("OneWayTiles"):
		can_hang_top_solid = true
func _on_hang_box_body_exited(body: Node2D) -> void:
	if body.is_in_group("OneWayTiles"):
		can_hang_top_solid = false
func Is_cursor_inside_PetClickZone() -> bool:
	
	return (
		get_global_mouse_position().x > %LeftUp_ClickZone.global_position.x and \
		get_global_mouse_position().y > %LeftUp_ClickZone.global_position.y and \
		get_global_mouse_position().x < %RightDown_ClickZone.global_position.x and \
		get_global_mouse_position().y < %RightDown_ClickZone.global_position.y
	)
func clear_trail() -> void:
	%Trail.clear_points()
func die() -> void:
	print('died')
	is_dead = true
	is_immune = false
func restart_level() -> void:
	
	States.change_state(StartState)
	
	if checkpoint_is_marked and UI.Chances > 0:
		if checkpoint != null:
			#Return chekpoint position
			checkpoint.load_player_properties()
	else:
		var get_checkpoints : Array = get_tree().get_nodes_in_group("Checkpoint")
		for checkpoints in get_checkpoints:
			checkpoints.is_marked = false
		if current_start_point == null:
			global_position = first_position
		else:
			global_position = current_start_point.global_position
		
	GlobalEngine.GamePlayer.Universe_2D_Trigger.current_level.CameraManager.Current_camerazone.global_position = global_position
	
	#Reset player health in his data
	UI.change_Current_Health_Value(UI.Health_Max)
	#is_dead = false
	Hitted = false

	var level = get_tree().get_current_scene()
	
	if level is LevelLogic:
		level.restart_level_scene()
func level_cleared(level: LevelLogic) -> void:
	#level -> the level that was cleared
	
	can_move = false
	current_nightfly_level_cleared = true
	
	##TIMER##
	var timer_caseiro = Timer.new()
	TemporaryNodes.add_child(timer_caseiro)
	timer_caseiro.one_shot = true
	timer_caseiro.start(2.0)
	await timer_caseiro.timeout
	timer_caseiro.queue_free()
	
	if level.next_scene_level != null:
		get_tree().change_scene_to_file(level.next_scene_level)
func _entered_moving_platform_area2D(area: Area2D) -> void:
	if area.name == "GenericPlatformArea2D":# and is_on_floor():
		get_moving_platform = area.get_parent()
		print(area, " area entered")
func _exited_moving_platform_area2D(area: Area2D) -> void:
	if area.name == "GenericPlatformArea2D":# and is_on_floor():
		#get_moving_platform = null
		print(area, " area exited")

#func is_over_water() -> bool:
	#return %PersistentBox.get_overlapping_areas()[0].is_in_group("rippler") if\
	#%PersistentBox.get_overlapping_areas().size() != 0 else false
	#
#func create_rippler() -> void:
	#
	#if is_over_water():
		#var ripple = RIPPLER_FX.instantiate()
		#ripple.global_position = global_position
		#TemporaryNodes.add_child(ripple)
		#
	
###Checkpoint saving
#func save_checkpoint_self_data() -> Dictionary:
	#
	#return Checkpoint_Data
	#
##Global saving
func save_self_data() -> void:
	var data_path = DataManager.SAVE_PATH + "FlockosData" + ".json"
	
	Player_Data.Max_Health = UI.Health_Max
	Player_Data.Max_Energy = UI.Awaken_Max
	Player_Data.Current_Health = UI.Health_Value
	Player_Data.Current_Energy = UI.Awaken_Value
	Player_Data.current_position = global_position
	Player_Data.Current_Score = UI.Score_Value
	Player_Data.Chances = UI.Chances
	
	Data =  {
	"Flockos_Properties" : {
	"Max_Health": Player_Data.Max_Health,
	"Current_Health": Player_Data.Current_Health,
	"Max_Energy": Player_Data.Max_Energy,
	"Current_Energy": Player_Data.Current_Energy,
	"current_position": {
		"x": Player_Data.current_position.x,
		"y": Player_Data.current_position.y
	},
	"Current_Score": Player_Data.Current_Score,
	"Chances": Player_Data.Chances
	}}
	DataManager.save_data(data_path, Data)
##Global loading
func load_self_data() -> void:

	var data_path = DataManager.SAVE_PATH + "FlockosData" + ".json"
	
	UI.Health_Max = DataManager.load_data(data_path).Flockos_Properties.Max_Health
	UI.Awaken_Max = DataManager.load_data(data_path).Flockos_Properties.Max_Energy
	UI.Score_Value = DataManager.load_data(data_path).Flockos_Properties.Current_Score
	UI.Chances = DataManager.load_data(data_path).Flockos_Properties.Chances
	global_position.x = DataManager.load_data(data_path).Flockos_Properties.current_position.x
	global_position.y = DataManager.load_data(data_path).Flockos_Properties.current_position.y
func _on_sliderbody(body: Node2D) -> void:
	if body is SliderBody2D:
		is_on_slider = true
func _out_of_sliderbody(body: Node2D) -> void:
	if body is SliderBody2D:
		is_on_slider = false
