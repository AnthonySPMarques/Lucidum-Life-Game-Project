extends Node2D
@onready var animation_player: AnimationPlayer = %ShPlayer

func _ready() -> void:
	animation_player.play("ripple")
	await animation_player.animation_finished
	queue_free()
