extends Projectile_Hurter
class_name CannonBall

@onready var trajectory_behavior: Node = %TrajectoryBehavior

func _ready() -> void:
	trajectory_behavior.set_target(GlobalEngine.flockos)
	
func _physics_process(delta: float) -> void:
	move_and_collide((velocity*1.1)*delta)
	
#If collides with slash bite
func _on_area_2d_area_entered(_area: Area2D) -> void:
	var pierce_a = Triggers.create_RigidVisualEffectTrigger(0, global_position, Vector2i.ONE)
	var pierce_b = Triggers.create_RigidVisualEffectTrigger(1, global_position, Vector2i.ONE)
	
	var get_spark = load("res://Scenes/Triggers/FXs/Particles/4.tscn")
	
	SoundEffects.play_sound(0)
	
	Triggers.create_ParticleTrigger(get_spark,
	global_position, Vector2i.ONE, null, 0.2)
	
	pierce_a.disable_selfkill = true
	pierce_b.disable_selfkill = true
	
	pierce_a.applyself_rigidbody(Vector2(-100, 2), Vector2(-100, 2))
	pierce_b.applyself_rigidbody(Vector2(100, -24), Vector2(100, 2))
	
	#print(name, " died of colliding with slashbite")
	call_deferred("queue_free")

#If collides with Flockos
func _on_hitbox_self_body_entered(body: Node2D) -> void:
	if body is Flockos:
		if body.is_immune == false and body.Hitted == false:
			body._Knockbacked(self)
	Triggers.create_VisualEffectTrigger(15, global_position, Vector2i.ONE)
	#print(name, " died of colliding with something")
	call_deferred("queue_free")


func _on_visible_rect_screen_exited() -> void:
	#print(name, " died of rect screen exitedosis")
	call_deferred("queue_free")
