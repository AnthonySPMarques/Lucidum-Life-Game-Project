"Spring point script"
class_name SpringPoint extends Area2D

"Vars"
var Forca_Elastica : float
var altura : float = position.y
var altura_natural : float = position.y + 80.0
var velocidade : float = 0
var index : int = 0
var collided_with = null

@onready var mask : CollisionShape2D = $Mask

func _ready() -> void:
	body_entered.connect(_on_Spring_Point_body_entered)
	
#Aplicar força
func mola(mola_constante: float, damp: float) -> void:
	
	#Dado o valor da altura pela posição Y do node
	altura = position.y
	
	#X
	var X = altura - altura_natural
	var Perda = -damp * velocidade
	
	#Operação de Hooke.
	#A força elástica da água é determinada pela seguinte multiplicação
	#K * X
	#K corresponde a constante da mola negativa
	Forca_Elastica = -mola_constante * X + Perda # <- X = altura - altura_natural
	velocidade += Forca_Elastica
	position.y += velocidade
	pass

#func set_collision_width(value):
#	#this function will set the collision shape size of our springs
#	var extents = mask.shape.get_extents()
#
#	#the new extents will mantain the value on the y width
#	#the "value" variable is the space between springs, which we already have
#	var new_extents = Vector2(value/2, extents.y)
#
#	#set the new extents
#	mask.shape.set_extents(new_extents)
#	pass

func initialize(id: int) -> void:
	altura = position.y
	altura_natural = position.y
	velocidade = 0
	index = id

func _on_Spring_Point_body_entered(body: Node2D) -> void:

	if body is Flockos:
		
		if get_parent().rotation_degrees == 0: #up
			if body.velocity.y > 0:
				get_parent().splash(index, body.velocity.y * get_parent().speed_factor)
			else:
				get_parent().splash(index, body.velocity.y * get_parent().speed_factor * 0.2)
		elif get_parent().rotation_degrees == 90 or get_parent().rotation_degrees == -270: #right
			if body.velocity.x < 0:
				get_parent().splash(index, body.velocity.y * get_parent().speed_factor)
			else:
				get_parent().splash(index, body.velocity.y * get_parent().speed_factor * 0.2)
		elif get_parent().rotation_degrees == 180 or get_parent().rotation_degrees == -180: #down
			if body.velocity.y < 0:
				get_parent().splash(index, body.velocity.y * get_parent().speed_factor)
			else:
				get_parent().splash(index, body.velocity.y * get_parent().speed_factor * 0.2)
			
		elif get_parent().rotation_degrees == -90 or get_parent().rotation_degrees == 270: #left
			if body.velocity.x > 0:
				get_parent().splash(index, body.velocity.y * get_parent().speed_factor)
			else:
				get_parent().splash(index, body.velocity.y * get_parent().speed_factor * 0.2)
			
				
			
			
			
			
			
			
			
			
			
			
			
			
			
