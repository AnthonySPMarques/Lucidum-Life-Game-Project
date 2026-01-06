extends Area2D
class_name Spring


var Spring_Force : float = 1200.0 #Velocity to give to player
var spring_force_direction : Vector2

func _process(_delta:float) -> void:
	spring_force_direction = Vector2.UP.rotated(rotation).normalized()*Spring_Force
	
	#print("Spring_ rotation_degrees = ", rotation)
	#print("Spring_ Vector2.UP.rotated(rotation_degrees).normalized() = ", Vector2.UP.rotated(rotation_degrees).normalized())
	#print(name, " Spring_ spring_force_direction = ", spring_force_direction)
