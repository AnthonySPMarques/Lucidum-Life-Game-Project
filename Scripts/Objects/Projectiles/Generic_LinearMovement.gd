extends Projectile_Hurter
class_name GenericLinearBullet

@export var linear_speed : float = 15.0
@export var area2d_hurter : Area2D
@export var visibility_area : VisibleOnScreenNotifier2D
var dir = Vector2.RIGHT

func _ready() -> void:
	print(name, " is in scene")
	dir = Vector2.RIGHT.rotated(global_rotation)
	if area2d_hurter != null:
		area2d_hurter.body_entered.connect(collided_body)
	if visibility_area != null:
		visibility_area.screen_exited.connect(_on_out_of_view)
	
func _physics_process(_delta: float) -> void:
	var collided = move_and_collide(velocity)
	if collided:
		Triggers.create_VisualEffectTrigger(18, global_position)
		call_deferred("queue_free")
	else:
		velocity = -dir * linear_speed

func collided_body(body: Node2D) -> void:
	##generic damage collision
	if body is Flockos:
		if body.is_immune == false:
			body._Knockbacked(self)
	
	Triggers.create_VisualEffectTrigger(18, global_position)
	##Remove bullet when collided player
	call_deferred("queue_free")

func _on_out_of_view() -> void:
	area2d_hurter.body_entered.disconnect(collided_body)
	#Remove bullet when exited screen
	print(name, " removed from scene")
	call_deferred("queue_free")
