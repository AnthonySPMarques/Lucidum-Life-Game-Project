class_name EffectCreator extends Node2D

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
		
func self_playsound() -> void:
	asfx_explosion.play()
		
func kill(_anim: StringName) -> void:
	call_deferred("queue_free")
