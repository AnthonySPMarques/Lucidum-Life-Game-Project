extends CharacterBody2D
class_name Projectile_Hurter

enum enum_damage {By_Force, InstantKill}
@export var damage_type : enum_damage = enum_damage.By_Force

@export var damage_force = 1

func _enter_tree() -> void:

	#group to all objects that hurts
	self.add_to_group("Hurters", true)
