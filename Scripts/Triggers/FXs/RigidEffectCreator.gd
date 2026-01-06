class_name RigidEffectCreator extends Node2D
@export var set_effect_id : int = 10
@onready var asfx_explosion: AudioStreamPlayer2D = $ASFX_Explosion
@onready var effect_animation_player: AnimationPlayer = %EffectAnimationPlayer
@onready var sprite: Node2D = %Sprite

var disable_selfkill : bool = false

func _ready():
	
	if %EffectAnimationPlayer.current_animation != "":
		%EffectAnimationPlayer.stop(true)
	%EffectSprite.show()
	%EffectAnimationPlayer.play(str(set_effect_id).pad_zeros(3))
	
	if not disable_selfkill:
		%EffectAnimationPlayer.animation_finished.connect(kill)
		%RigidBody2D.freeze = true
		%CollisionShape2D.disabled = true
		
func applyself_rigidbody(impulse: Vector2, impulse_position: Vector2) -> void:
	%RigidBody2D.freeze = false
	%CollisionShape2D.disabled = false
	%areamask.disabled = false
	
	%RigidBody2D.apply_impulse(impulse, impulse_position)
	
func kill(_anim: StringName) -> void:
	call_deferred("queue_free")


func self_playsound() -> void:
	asfx_explosion.play()

func effect_is_explosion() -> bool:
	return set_effect_id == 2 or \
	set_effect_id == 3

func _on_area_2d_body_entered(_body: Node2D) -> void:
	if set_effect_id == 0 or set_effect_id == 1:
		Triggers.create_RigidVisualEffectTrigger(3, %RigidBody2D.global_position, Vector2i.ONE)
		call_deferred("queue_free")
		


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	call_deferred("queue_free")
