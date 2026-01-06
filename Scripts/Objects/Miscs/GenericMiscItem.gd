class_name MiscCollectables
extends Collectable_Logic

##Key values must match with existing var names on PlayerResources

@export var visibility_mask : Node2D
##Name of th method that will update the named value of some variable from player.UI
@export var UI_method_name : StringName

var own_resource = null
var start_timer : bool = false
var current_phy = preload("res://tres/PhysicsMaterial_RigidBody2D/CapsulePhysicMaterial.tres")
var current_display_name : StringName = ""
var data_2_modify : Dictionary

var PLAYER_HEALTHMAX : int
var PLAYER_AWAKENMAX : int

@onready var stat_player: AnimationPlayer = %StatPlayer
@onready var anim_player: AnimationPlayer = %AnimPlayer
@onready var is_in_editor = true #Disable playing tool when game starts

func _ready() -> void:
	
	if GlobalEngine.flockos != null:
		PLAYER_HEALTHMAX = GlobalEngine.flockos.UI.Health_Max
		PLAYER_AWAKENMAX = GlobalEngine.flockos.UI.Awaken_Max
		
	data_2_modify = Pickup_Resource.Property_To_Modify

	"Print what will change"
	print(name,  ".[GenericMiscitem.gd] data_2_modify = ", data_2_modify)
	"How it will change"
	if GlobalEngine.flockos != null:
		print("GlobalEngine.flockos.Player_Data = ", GlobalEngine.flockos.Player_Data)
	else:
		printerr("Object [Flockos] is null")
	current_display_name = Pickup_Resource.PickUp_Display
	print(current_display_name)
	
	
	if Item_Body is CharacterBody2D and has_gravity:
		if apply_straight_impulse:
			Item_Body.velocity.y = -CharacterBody_height_impulse
	
	if visibility_mask != null:
		visibility_mask.show()
	own_resource = Pickup_Resource
	if Item_Body is RigidBody2D:
		Item_Body.physics_material_override = current_phy
		Item_Body.continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE
	
	is_in_editor = false
	LifeTime = life_time
	start_timer = true
	
	if not picked_up.is_connected(_on_picked_up):
		picked_up.connect(_on_picked_up)
	
	#Connect kill for exiting from scene
	if not Ignore_VisibilityArea_Remove:
		if visibility_mask != null:
			if not visibility_mask.screen_entered.is_connected(kill):
				visibility_mask.screen_exited.connect(kill)
	anim_player.play(own_resource.PickUp_Display)
	
	if apply_random_impulse:
		if Item_Body is RigidBody2D:
			Item_Body.apply_impulse(
				Vector2(randf_range(MinItemRigidImpulse_X, MaxItemRigidImpulse_X),
				randf_range(-MinItemRigidImpulse_Y, -MaxItemRigidImpulse_Y)),
				Item_Body.global_position)

func _physics_process(delta: float) -> void:
	if Item_Body is CharacterBody2D:
		if has_gravity:
			apply_physics_process(delta)
	if start_timer == true and has_life_time:
		if LifeTime > 0:
			LifeTime -= delta
		else:
			kill()
		
		if LifeTime < life_time/3:
			stat_player.play(&"Disappearing")
	if is_in_editor == true:
		if anim_player.has_animation(own_resource.PickUp_Display):
			anim_player.play(own_resource.PickUp_Display)
		else:
			printerr("Non animation or maybe name in enum string is mistyped")

"Make this function global to be usable to all function"

func _on_picked_up(body: PhysicsBody2D) -> void:
	
	if body is Flockos:
		var flockos = body as Flockos
		
		flockos.light_pickuping() #Shine when picking something
		Triggers.create_VisualEffectTrigger(
			10, self.global_position, Vector2.ONE
		) #Create picked up visual effect
		
		var get_FlockosDataValue = flockos.Own_Player_Data.get(data_2_modify.keys()[0])
		
		"Change from UI display"
		#(Signal name, value, plus)
		##Update UI display of values
		if flockos.UI.has_method(UI_method_name):
			if get_FlockosDataValue == null:
				push_error("Rename dict key to exact var name from data_2_modify to PlayerData.\n
				Important change it inside resource so it can be saved later")
				breakpoint
			if UI_method_name != "Change_general_values":
				##Update it to a specific thing with differnet amount of arguments
				flockos.UI.call(UI_method_name,
				
				##------------------------------------------------
				
				####[value]####
				##If key is int
				flockos.Own_Player_Data.get(data_2_modify.keys()[0])+data_2_modify.values()[0] 
				if data_2_modify.values()[0] is int else #Get path to a variable
				
				##If key is stringname (dont plus)
				flockos.Own_Player_Data.get(data_2_modify.keys()[0])+get(data_2_modify.values()[0])
				if (data_2_modify.values()[0] is String or
				data_2_modify.values()[0] is StringName) else 
				
				##If is not a string nor int
				data_2_modify.values()[0]
				)
				####[/value]####
			else:
				##Update it as having 3 arguments ##(Variable_name, Value, Plus)
				flockos.UI.call(UI_method_name,
				
				####[Variable]####
				##Get var name
				data_2_modify.keys()[0],
				####[/Variable]####
				
				##------------------------------------------------
				
				####[Value]####
				##If key is int
				flockos.Own_Player_Data.get(data_2_modify.keys()[0])
				if data_2_modify.values()[0] is int else #Get path to a variable
				##If key is stringname (dont plus)
				get(data_2_modify.values()[0])
				if data_2_modify.values()[0] is String else 
				##If is not a string nor int
				data_2_modify.values()[0],
				####[/Value]####
				
				##------------------------------------------------
				
				####[Plus]####
				true
				####[/Plus]####
				)
				##"Must return the value of the health capsule"
		kill()
		##Animationplim already kill this node when ending
