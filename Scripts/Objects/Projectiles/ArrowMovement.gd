extends Projectile_Hurter
class_name ArrowPattern

@export var linear_speed : float = 15.0
var dir = Vector2.RIGHT

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var hitbox_self: Area2D = %Hitbox_Self
@onready var hitbox_against_meeles: Area2D = %Hitbox_AgainstMeeles

	
func _ready() -> void:
	dir = Vector2.RIGHT.rotated(global_rotation)
	hitbox_against_meeles.area_entered.connect(collided_area)
	hitbox_self.body_entered.connect(collided_body)
	
func _physics_process(_delta: float) -> void:
	var collided = move_and_collide(velocity)
	if collided:
		velocity = Vector2.ZERO
		dir = Vector2.ZERO
		animation_player.play("die")
		
	else:
		velocity = -dir * linear_speed

func collided_area(_area: Area2D) -> void:
	call_deferred("queue_free")

func collided_body(body: Node2D) -> void:
	if body is Flockos:
		if body.is_immune == false:
			body.modify_velocity(body.velocity_modifier-0.9)
			body._Knockbacked(self)
	
	#Triggers.create_VisualEffectTrigger(15, global_position, Vector2i.ONE)
	call_deferred("queue_free")

func _on_visible_rect_screen_exited() -> void:
	call_deferred("queue_free")
