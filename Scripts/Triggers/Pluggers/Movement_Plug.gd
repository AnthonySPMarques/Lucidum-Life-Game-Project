###MOVEMENT PLUG:
##Makes a specific node move
class_name MovementPlug
extends Plugger


@export_range(0.0, 10000.0)
var Speed : float = 100.0
@export_range(0.0, 10000.0)
var Acceleration : float = 50.0
@export_range(0.0, 10000.0)
var Friction : float = 30.0
##Speed of the node

@export
var Can_Move : bool = true
@export
var Bounce_Wall : bool = true
##In the node can move

var current_dir : int = 1

func _process(_delta: float) -> void:
	if Can_Move:
		if Node_To_PlugIn is CharacterBody2D:
			
			var Char = Node_To_PlugIn as CharacterBody2D
			#Char.velocity.x = Speed*current_dir
		
			if current_dir == 1:
				Char.velocity.x = min(Char.velocity.x + Acceleration, Speed)

			elif current_dir == -1:
				Char.velocity.x = max(Char.velocity.x - Acceleration, -Speed)

			else:
				#Friction:
				if Char.velocity.x > 0:
					Char.velocity.x = max(Char.velocity.x - Friction, 0)

				if Char.velocity.x < 0:
					Char.velocity.x = min(Char.velocity.x + Friction, 0)
			
			if Bounce_Wall:
				if Char.is_on_wall():
					change_direction()
			
	
#Change direction of the moving node
func change_direction(dir: int = -current_dir) -> void:
	current_dir = dir
	#print("Direction changed to ", dir)
