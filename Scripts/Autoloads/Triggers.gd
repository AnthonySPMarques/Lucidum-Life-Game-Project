#Singleton Triggers.gd#
extends Node

var VisualEffectTrigger : PackedScene = preload("res://Scenes/Triggers/FXs/EffectCreator.tscn")
var VisualRigidEffectTrigger : PackedScene = preload("res://Scenes/Triggers/FXs/RigidEffectCreator.tscn")

var brake = true

var current_shake_force : int = 0

func create_VisualEffectTrigger(Effect_ID: int, Position: Vector2, Scale: Vector2 = Vector2i.ONE) -> EffectCreator:
	#print("created visual effect trigger")
	#Effect IDs
	#0 = Strike
	
	#Effect_Types
	#0 = particle
	#1 = sprite animated
	
	var VisualEffectInstance = VisualEffectTrigger.instantiate()
	VisualEffectInstance.set_effect_id = Effect_ID
	VisualEffectInstance.global_position = Position
	VisualEffectInstance.scale = Scale
	get_parent().call_deferred("add_child", VisualEffectInstance)
	
	return VisualEffectInstance

func create_RigidVisualEffectTrigger(Effect_ID: int, Position: Vector2, Scale: Vector2 = Vector2i.ONE) -> RigidEffectCreator:
	#print("created rigid visual effect trigger")
	#Effect IDs
	#0 = Strike
	
	#Effect_Types
	#0 = particle
	#1 = sprite animated
	
	var VisualRigidEffectInstance = VisualRigidEffectTrigger.instantiate()
	VisualRigidEffectInstance.set_effect_id = Effect_ID
	VisualRigidEffectInstance.global_position = Position
	VisualRigidEffectInstance.scale = Scale
	get_parent().call_deferred("add_child", VisualRigidEffectInstance)
	
	return VisualRigidEffectInstance

func create_VisualEffectTrigger_bydelay(Effect_ID: int, Position: Vector2, Scale: Vector2, Delay: float) -> EffectCreator:
	#print("created visual effect trigger by delay")
	#Effect IDs
	#0 = Strike
	
	#Effect_Types
	#0 = particle
	#1 = sprite animated
	var VisualEffectInstance = VisualEffectTrigger.instantiate()
	var timer_caseiro = Timer.new()
	TemporaryNodes.add_child(timer_caseiro)
	timer_caseiro.one_shot = true
	timer_caseiro.start(Delay)
	
	if brake == true:
		brake = false
		VisualEffectTrigger.duplicate()
		VisualEffectInstance.set_effect_id = Effect_ID
		VisualEffectInstance.global_position = Position
		VisualEffectInstance.scale = Scale
		get_parent().call_deferred("add_child", VisualEffectInstance)
		await timer_caseiro.timeout
		timer_caseiro.queue_free()
		#print("timer_caseiro from Triggers.gd is finished")
		brake = true
	
	return VisualEffectInstance
	
func create_ParticleTrigger(Particle_Scene: PackedScene,
Position: Vector2, 
Scale: Vector2 = Vector2.ONE,
ProcessMaterial: ParticleProcessMaterial = null, 
ParticleAmountRatio: float = 1) -> void:
	
	#print("created particle trigger")
	
	if not GameSettings.ConfigurationManager.GameplaySettings.Game_Configurations_Dictionary.Disable_Particles:
		##Store instantiated particle scene
		var Particle_Node = Particle_Scene.instantiate() as GPUParticles2D
		
		##Store procress material from the scene
		if ProcessMaterial == null: ##If no process_material has been put when calling this function
			##Then it gets the original process material from the scene if it isn't null
			ProcessMaterial = Particle_Node.process_material\
			if Particle_Node.process_material != null else null
			#print("Trigger particle process material is ", ProcessMaterial)
			
		##Store ProcessMaterial inside another var
		var Particle_Behavior = ProcessMaterial if not null else null
		#Double restart to prevent bugs
		Particle_Node.restart()
		Particle_Node.set_as_top_level(true)
		Particle_Node.restart()
		
		Particle_Node.set("global_position", Position)
		Particle_Node.scale = Scale
		Particle_Node.amount_ratio = clampf(ParticleAmountRatio, 0.0, 1.0)
		
		if Particle_Behavior is ParticleProcessMaterial:
			Particle_Node.set("process_material", Particle_Behavior)

		call_deferred("add_child", Particle_Node)
	
	
func create_Projectile(Projectile: PackedScene, 
Position: Vector2, Scale: Vector2i) -> Node2D:
	
	#print("created projectile")
	
	if is_instance_valid(Projectile.instantiate()):
		var Proj_instance = Projectile.instantiate()
		Proj_instance.global_position = Position
		Proj_instance.scale = Scale
		Proj_instance.set_as_top_level(true)
		get_parent().call_deferred("add_child", Proj_instance)
		return Proj_instance
	return null

func CreateTweenProperty(NodeToTween: Node2D,
Property: String,
Value: Variant,
Duration: float,
EaseType: Tween.EaseType,
TransType: Tween.TransitionType) -> void:
	
	var T = create_tween()
	T.tween_property(NodeToTween,
	Property,
	Value,
	Duration).set_ease(EaseType).set_trans(TransType)
	T.play()
	
	
	
	
	
	
