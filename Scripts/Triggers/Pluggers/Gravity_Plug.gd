###GRAVITY PLUG:
##Makes the plugged node have gravity
class_name GravityPlug
extends Plugger

@export var Impulse_Gravity : float = 1.5
var Gravity : float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	if Node_To_PlugIn == null:
		printerr("Node to plug in not found")
		breakpoint
		
func _physics_process(delta: float) -> void:
	if Node_To_PlugIn is CharacterBody2D:
		
		if not Node_To_PlugIn.is_on_floor():
			Node_To_PlugIn.velocity.y += (Gravity * Impulse_Gravity) * delta
		else:
			Node_To_PlugIn.velocity.y = 0
