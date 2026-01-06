class_name RigidParticleLogic
extends RigidBody2D

var angular_force = 50000
var target = position + Vector2.UP

func _ready() -> void:
	linear_velocity.y -= 1000
	

func shut_force(force: Vector2) -> void:
	add_constant_central_force(force)

func _exit_tree() -> void:
	call_deferred("queue_free")
