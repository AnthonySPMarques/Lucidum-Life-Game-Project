extends Node2D

##Exported variables
@export_subgroup("commons")
#@export var Enemie_group_name : String = ""
@export var slow_engine_time : float = 0.4
@export var time_to_fade_indicator_damage : float
@export var blow_force = 400

#@export_subgroup("Damage_forces")
#@export var Damage_Force_1 : float = 2 #Slash damage towards Enemy
#@export_range(0.000, 10.000) var IdleSlash1_Invencibility_GivenTimer :float= 0 #and how much his invencibility will late depending of the slash
#
#@export var Damage_Force_2 :float= 2
#@export_range(0.000, 10.000) var IdleSlash2_Invencibility_GivenTimer :float= 0
#
#@export var Damage_Force_3 :float= 2
#@export_range(0.000, 10.000) var IdleSlash3_Invencibility_GivenTimer :float= 0
#
#@export var Run_Slash_Force :float= 4
#@export_range(0.000, 10.000) var Run_Slash_Force_Invencibility_GivenTimer :float= 0
#
#@export var Down_Damage_Force_1 :float= 2
#@export_range(0.000, 10.000) var DownSlash1_Invencibility_GivenTimer :float= 0
#
#@export var Down_Damage_Force_2 :float= 2
#@export_range(0.000, 10.000) var DownSlash2_Invencibility_GivenTimer :float= 0
#
#@export var Down_Damage_Force_3 :float= 2
#@export_range(0.000, 10.000) var DownSlash3_Invencibility_GivenTimer :float= 0
#
#@export var AvoiderDown_Damage_Force :float= 2
#@export_range(0.000, 10.000) var AvoiderDown_Invencibility_GivenTimer :float= 0
#
#@export var ClimbSlash_Damage_Force :float= 2
#@export_range(0.000, 10.000) var ClimbSlash_Invencibility_GivenTimer :float= 0
#
#@export var WallSlash_Damage_Force :float= 2
#@export_range(0.000, 10.000) var WallSlash_Invencibility_GivenTimer :float= 0
#
#@export var BladeFan_Slash_Damage_Force :float= 2
#@export_range(0.000, 10.000) var BladeFan_Invencibility_GivenTimer :float= 0
#
#@export var AirSlash_Damage_Force :float= 6
#@export_range(0.000, 10.000) var AirSlash_Invencibility_GivenTimer :float= 0
#
#@export var DashSlash_Damage_Force :float= 4
#@export_range(0.000, 10.000) var DashSlash_Invencibility_GivenTimer :float= 0
#
#@export var CrazyFly_Damage_Force :float= 2
#@export_range(0.000, 10.000) var CrazyFly_Invencibility_GivenTimer :float= 0
#@export var DashCrazyFly_Damage_Force :float= 2
#
#@export var LightingKipe_Damage_Force :float= 1
#@export_range(0.000, 10.000) var LightingKipe_Invencibility_GivenTimer :float= 0
#
#@export var WaterShake_Damage_Force :float= 1
#@export_range(0.000, 10.000) var WaterShake_Invencibility_GivenTimer :float= 0


@export var DelayHitboxes_Slashes = 0.5

##Variables:
var is_slash_charged : bool
var damage_amount : float = 0
var timer_caseiro : float
var shot_timer = false
var is_persistent_mask_colliding = false
var get_bodies = []
#Current value of the damage
var current_DPS = 0
var added_timer = false
var dam = false
var speedester_gametime = 1.0
var blow_dir = 1
var get_framedata

@onready var machine_state: PlayerStateParent = %Machine_State
@onready var animation_traveler: AnimationTree = %Animation_Traveler

##Signals
signal dash_slash_hitbox_collided
signal dash_slash_hitbox_exited

@onready var flockos: Flockos = $".."

func _ready() -> void:
	

	##Give timer_caseiro value
	timer_caseiro = time_to_fade_indicator_damage
	
	#for Y in get_children(false):
		#if Y is Area2D:
			#Y.body_entered.connect(Callable(self, Y.name))
	if machine_state.Default_State != null:
		if machine_state.Default_State.is_in_group("SlashState"):
			
			if machine_state.Default_State != flockos.DashState and \
			machine_state.Default_State != flockos.AirSlashState and \
			machine_state.Default_State != flockos.AirSlashDashState and \
			machine_state.Default_State != flockos.CrazyFlyState and \
			machine_state.Default_State != flockos.DashCrazyFlyState and \
			machine_state.Default_State != flockos.ChargedSlashState: #To both airdash and dash use one framedata
				get_node(machine_state.Default_State.name + "_FrameData").process_funtion()
			
			else:
				if machine_state.Default_State == flockos.DashState:
					$DashSlash_FrameData.process_funtion()
				elif machine_state.Default_State == flockos.AirSlashState \
				or flockos.AirSlashDashState:
					$AirSlash_FrameData.process_funtion()
				elif machine_state.Default_State == flockos.CrazyFlyState \
				or flockos.DashCrazyFlyState:
					$CrazyFly_FrameData.process_funtion()
		else:
			animation_traveler["parameters/TimeScale/scale"] = 1.0
			
			
func _process(delta: float) -> void:
	is_slash_charged = %UserInterface.is_awaken_energy_full
	
	if machine_state.Default_State.is_in_group("SlashState"):
		
		if machine_state.Default_State != flockos.DashState and \
		machine_state.Default_State != flockos.AirSlashState and \
		machine_state.Default_State != flockos.AirSlashDashState and \
		machine_state.Default_State != flockos.CrazyFlyState and \
		machine_state.Default_State != flockos.DashCrazyFlyState and \
		machine_state.Default_State != flockos.ChargedSlashState: #To both airdash and dash use one framedata
			get_node(machine_state.Default_State.name + "_FrameData").process_funtion()
		
		else:
			if machine_state.Default_State == flockos.DashState:
				$DashSlash_FrameData.process_funtion()
			elif machine_state.Default_State == flockos.AirSlashState \
			or flockos.AirSlashDashState:
				$AirSlash_FrameData.process_funtion()
			elif machine_state.Default_State == flockos.CrazyFlyState \
			or flockos.DashCrazyFlyState:
				$CrazyFly_FrameData.process_funtion()
	else:
		animation_traveler["parameters/TimeScale/scale"] = 1.0

	if timer_caseiro > 0 and shot_timer == true:
		timer_caseiro -= delta
	elif timer_caseiro <= 0:
		shot_timer = false
		timer_caseiro = 0
		damage_amount = 0


func enable_clash_areas()-> void:
	
	for Y in get_tree().get_nodes_in_group("ClashAreaParent"):
		Y.enable_clash_areas()
	
func disable_clash_areas()-> void:
	
	for Y in get_tree().get_nodes_in_group("ClashAreaParent"):
		Y.disable_clash_areas()

func disable_all_collision_shapes() -> void:
	
	for parents in get_children():
		for childs in parents.get_children():
			for maskys in childs.get_children():
				if maskys is CollisionShape2D or maskys is CollisionPolygon2D:
					maskys.disabled = true
	
#Every tick from timer out of DPS
func set_damage() -> void:
	if get_bodies != null:
		dam = true
