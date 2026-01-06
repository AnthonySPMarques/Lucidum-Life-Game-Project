###SHAKE PLUG:
##Makes the plugged node shake
class_name ShakePlug
extends Plugger

@export var ShakeForce : float = 200.0
@export var ShakeDuration : float = 1.0
var rng = RandomNumberGenerator.new()

var current_shake_force : float = 0.0

var previous_pos = null
var current_pos = null

func _ready() -> void:
	set_unique_name_in_owner(true)
	previous_pos = Node_To_PlugIn.global_position
	
func apply_shake() -> void:
	set_physics_process(true)
	current_shake_force = ShakeForce
	
func _physics_process(_delta: float) -> void:
	#print(Shake())
	if current_shake_force > 0:
		current_shake_force = lerp(current_shake_force, 0.0,
		ShakeDuration)
		Node_To_PlugIn.global_position += Shake()
	else:
		if previous_pos != null:
			current_pos = lerp(Node_To_PlugIn.global_position, 
			previous_pos, 0.2)
			
			#DisplayServer.window_set_position(current_pos)
			set_physics_process(false)
	
	print(previous_pos)
	print(current_pos)
	
func Shake() -> Vector2:
	return Vector2(rng.randf_range(-current_shake_force, current_shake_force), 
	rng.randf_range(-current_shake_force, current_shake_force))
	
