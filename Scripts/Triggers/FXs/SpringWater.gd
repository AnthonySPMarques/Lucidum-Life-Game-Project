#Script refence
#https://youtu.be/RXIRkou021U
class_name SpringWater extends Node2D

#signal shake_spring #Assign signal

var velocity = 0 #Spring current velocity
var strengh = 0 #Force to be added in spring
var height_fix = position.y #current height of spring
var target_height = position.y + 80 #natural spring position
var id = 0 #INITALIZEEEE AGAINNNNN by the index of the spring
var fator_de_motion = 0.02 #Flexibility of the spring movement after splash

@onready var Area_2d = $Area2D as Area2D
@onready var Mask = $Area2D/Mask as CollisionShape2D

func shake_spring(spring_const, dampening) -> void:
	#Apply hooke's law toward the spring strengh

	#Update height based on the current position
	height_fix = position.y
	
	#spring extention
	var x = height_fix - target_height
	
	#Friction
	var fric = -dampening * velocity
	
	#hooke's law logic
	strengh = -spring_const * x + fric
	
	#Apply force toward the current velocity
	velocity += strengh
	
	#Apply movement on spring:
	position.y += velocity
	pass
	
func initialize(x_pos, index):
	height_fix = position.y
	target_height = position.y
	velocity = 0
	position.x = x_pos
	id = index
	pass
	
func change_collision_size(size):
	
	#Apply mask around the springs
	
	var extent_size = Mask.shape.get_extents()
	
	var updated_extent_size = Vector2(size/2, extent_size.y)
	Mask.shape.set_extents(updated_extent_size)
	pass

func _on_Area2D_body_entered(body: Node2D):

	if body is Flockos:
		var flockos = body as Flockos
		var velocity_f = flockos.velocity.y * fator_de_motion + 222
		
		shake_spring(id, velocity_f)
		
	pass
