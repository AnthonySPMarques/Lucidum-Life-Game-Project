extends StaticBody2D
class_name Static_Hurter

enum enum_damage {By_Force, InstantKill}
@export var damage_type : enum_damage = enum_damage.By_Force

@export var damage_force = 1

func _ready() -> void:

	#group to all objects that hurts
	self.add_to_group("Hurters", true)
	#additional name
	self.add_to_group("StaticHurters", true)
