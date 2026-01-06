@icon("res://Sprites/EditorTriggers/WaterMaker.png")
extends Node2D
class_name WaterMaker

const SNAPx : int = 64

@export var Enable_Left_Border_Spring : bool = false
@export var Enable_Right_Border_Spring : bool = false
@export var Enable_Up_Border_Spring : bool = true
@export var Enable_Down_Border_Spring : bool = false

@export var altura_px : int = 1 #Depth * 64
@export var largura_px : int = 1 # largura_px * distance
@export var Water_Colors : Color
@export var speed_factor : float = 0.003
@export var K : float = 0.015 #Hooke
@export var D : float = 0.03 #Damp
@export var distance : int = 64 #distance beetween springs
@export var border_thickness = 1.1

var spring_point : PackedScene = preload("res://Scenes/Triggers/FXs/Tilers/Spring_Point.tscn")
var water_line_load : PackedScene = preload("res://Scenes/Triggers/FXs/Tilers/WaterLine.tscn")
var pre_polygon : PackedScene = preload("res://Scenes/Triggers/FXs/Tilers/PolygonWaterFiller.tscn")
var waterline : Path2D #Declared variable in _ready()
var water_length = null
var altura_natural = null
var bottom = null
var polygon = null
var spread : float = 0.2 #Spread
var array_spring_points : Array = []
var passes : int = 8

func _ready() -> void:
	var largura_int = largura_px
	#pq por algum caralho ele precisa estar com mais 1 de valor para ter um valor
	#exato de largura x por 64 no editor
	largura_px += 1
	
	spread /= 1000
	
	polygon = pre_polygon.instantiate()
	call_deferred("add_child", polygon)
	polygon.color = Color(0.184, 0.306, 0.776, 0.655)
	
	
	waterline = water_line_load.instantiate()
	call_deferred("add_child", waterline)
	waterline.width = border_thickness
	
	#+1 cuz the first px is not counted
	largura_px *= SNAPx * distance
	
	altura_natural = global_position.y #Target height
	bottom = altura_px * 64
	
	water_length = SNAPx * largura_int
	
	for X in range(largura_int):
		var Spoint = spring_point.instantiate()
		@warning_ignore("integer_division")
		var x_pos = (SNAPx / distance) * X
		
		Spoint.initialize(X)
		@warning_ignore("integer_division")
		Spoint.get_node("Mask").shape.extents.x = (SNAPx / distance)/2
		#Spoint.set_collision_width(SNAPx)
		add_child(Spoint)
		Spoint.position.x = x_pos
		print(largura_int)
		print(x_pos)
	
	
	#Adiciona os spring point nodes para o array
	for Y in get_children():
		if Y is SpringPoint:
			array_spring_points.append(Y)
	
	
	
func _physics_process(_delta: float) -> void:
	
	draw_water()
	new_border()
	
	for Y in array_spring_points:
		Y.mola(K, D)
		
	
	var left_points= []
	var right_points= []
	
	
	for Y in range( array_spring_points.size() ):
		left_points.append(0)
		right_points.append(0)
		pass
		
	for Z in range(passes):
		for Y in range( array_spring_points.size() ):
			if Y > 0:
				left_points[Y] = spread * ( 
				array_spring_points[Y].altura - array_spring_points[Y-1].altura
				)
				array_spring_points[Y-1].velocidade += left_points[Y]
			
			if Y < array_spring_points.size()-1:
				right_points[Y] = spread * ( 
				array_spring_points[Y].altura-array_spring_points[Y+1].altura
				)
				array_spring_points[Y+1].velocidade += right_points[Y]
	
func draw_water() -> void:

	#var water_polygon_points = points
	var surface_points = []
	var water_polygon_points = surface_points
#
	for Y in range(array_spring_points.size()):
		surface_points.append(array_spring_points[Y].position)
	
	var first_index = 0
	var last_index = surface_points.size()-1
	
	water_polygon_points.append(Vector2(surface_points[last_index].x, bottom))
	water_polygon_points.append(Vector2(surface_points[first_index].x, bottom))
	
	water_polygon_points = PackedVector2Array(water_polygon_points)
	
	polygon.set_polygon(water_polygon_points)
	polygon.set_uv(water_polygon_points)
	
	pass
	
func new_border() -> void:
	
	var curve = Curve2D.new().duplicate()
	
	var surface_points = []
	for Y in range(array_spring_points.size()):
		surface_points.append(array_spring_points[Y].position)
		
	for Y in range(surface_points.size()):
		curve.add_point(surface_points[Y])
		
	waterline.curve = curve
	waterline.smooth(true)
	waterline.queue_redraw()
	
	
func splash(index: int, speed: float) -> void:
	
	if index >= 0 and index < array_spring_points.size():
		array_spring_points[index].velocidade += speed
	pass
