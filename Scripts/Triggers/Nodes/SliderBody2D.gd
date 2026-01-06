@icon("res://Sprites/EditorTriggers/SliderBody2D.png")
extends StaticBody2D
class_name SliderBody2D



@export_range(1.0, 4000.0) var SliderSpeed : float = 200.0 
@export_enum("Bottom", "Top", "Left", "Right") var FloorSlide_Direction = "Top"

var current_floor_direction : Vector2

func _ready() -> void:
	#Init vecs
	match FloorSlide_Direction:
		"Top":
			current_floor_direction = Vector2.UP
		"Bottom":
			current_floor_direction = Vector2.DOWN
		"Left":
			current_floor_direction = Vector2.LEFT
		"Right":
			current_floor_direction = Vector2.RIGHT
			
		
	
