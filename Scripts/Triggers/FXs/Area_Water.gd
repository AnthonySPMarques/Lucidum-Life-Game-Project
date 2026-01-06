extends Water

@export var K_springs_constant_elastic : float = 0.015
@export var D_dampening_force : float  = 0.03
@export var Spread : float  = 0.002
@export var Splash_Speed : float = 5

#Distance beetween each spring point
@export var distance_beetween_spring_points : int = 32

#Number of springs
@export var number_of_springs : int = 6

@export var depth : int = 1000

#Amount of springs
var springs : Array = []
#How much repeat the spring spread
var times_to_repeat : int = 9

var water_length : int = distance_beetween_spring_points * number_of_springs

@onready var spring_point : PackedScene = preload("res://Scenes/Triggers/FXs/Tilers/SpringWater.tscn")

var target_height : float
var bottom_height : float

@onready var water_filler = $WaterFiller as Polygon2D

#Apply all values inside the spring children
func _ready():
	
	#Ready vars
	target_height = global_position.y
	bottom_height = target_height * depth
	
	#Add children to an array and apply
	#for each one
	for Y in range(number_of_springs):
		
		#generate from left to right --> N+1. N = distance_beetween_spring_points
		var x_pos = distance_beetween_spring_points * Y
		var wa = spring_point.instance() as SpringWater
		call_deferred("add_child", wa)
		springs.append(wa)
		wa.initialize(x_pos, Y)
		wa.change_collision_size(distance_beetween_spring_points)
		wa.emit_signal("shake_spring", self, "shake_spring")
		
		
func _physics_process(_delta):
	
	#Move all spring points
	for Y in springs:
		Y.shake_spring(K_springs_constant_elastic, D_dampening_force)
	
	#Move childrens from sides
	var left_deltas = []
	var right_deltas = []
	
	
	#Apply all values to zero
	for Y in range (springs.size()):
		left_deltas.append(0)
		right_deltas.append(0)
		pass
		
	for X in range(times_to_repeat):
		#Loops through each spring point from array
		for Y in range (springs.size()):
			#If child have a left node
			if Y > 0:
				left_deltas[Y] = Spread * (springs[Y].height_fix - springs[Y-1].height_fix)
				springs[Y-1].velocity += left_deltas[Y]
			#If child have a right node
			if Y < springs.size()-1:
				right_deltas[Y] = Spread * (springs[Y].height_fix - springs[Y+1].height_fix)
				springs[Y+1].velocity += right_deltas[Y]
	
	#Fill the water with points
	fill_water()
	pass
	
func shake_spring(index, speed):

	if index >= 0 and index < springs.size():
		springs[index].velocity += speed
		
	pass

func fill_water():
	
	var surface_points = []
	
	for Y in range(springs.size()):
		surface_points.append(springs[Y].position)
		
	#Get the first and last point of surface
	var first_id = 1
	var last_id = surface_points.size() - 1
	
	#Water fill will get the points of the surface
	var water_fill_points = surface_points
	
	#Fill the bottom closing the points under the depth
	water_fill_points.append(Vector2(surface_points[last_id].x, bottom_height))
	water_fill_points.append(Vector2(surface_points[first_id].x, bottom_height))
	
	water_fill_points = PackedVector2Array(water_fill_points)
	
	water_filler.set_polygon(water_fill_points)
	
