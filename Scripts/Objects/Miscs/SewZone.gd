extends Control
class_name SewZone

var get_sew_count : int = 0
var get_sews : Array = []
var get_sewed_points : Array = []

var current_pressed_sew : Control

var String_points_amount : int = 0
var String_get_last_point = null
##If mouse is being pressed down
var is_sewing : bool = false

@onready var string2D: Line2D = %String


func _ready() -> void:
	for Sew in get_children():
		if Sew is SewPoint:
			get_sews.append(Sew)
			Sew.pressed.connect(store_pressed_sew_button.bind(Sew))
			Sew.pressed.connect(remove_pressed_sew_button.bind())
	get_sew_count = get_sews.size()
	
	print(get_sew_count)

func store_pressed_sew_button(button: Control) -> void:
	current_pressed_sew = button
	
	if String_points_amount == 0:
		string2D.add_point(current_pressed_sew.global_position, 0)
	create_point(current_pressed_sew.global_position)
	
	is_sewing = true
	
	
	print("Sew pressed is = ", current_pressed_sew)
	
func remove_pressed_sew_button() -> void:
	current_pressed_sew = null

func count_sewed_points() -> void:
	for Sewed in get_sews:
		if Sewed.is_sewed:
			print(Sewed, " has been sewed")
			get_sewed_points.append(Sewed)

func create_point(pos:Vector2) -> void:
	string2D.add_point(pos)

func manipulate_point_pos(point_id:int)->void:
	string2D.set_point_position(point_id, get_global_mouse_position())

func remoce_point(all:bool, point_id:int)->void:
	if all:
		string2D.clear_points()
	else:
		string2D.remove_point(point_id)


func _process(_delta: float) -> void:
	String_points_amount = string2D.get_point_count()
	if String_points_amount > 0:
		String_get_last_point = string2D.points[String_points_amount-1]
		
	print("String_points_amount = " , String_points_amount)
	print("String_last_point = " , String_get_last_point)
	
	if is_sewing == true and String_points_amount > 0:
		manipulate_point_pos(String_points_amount)
		
	if Input.is_action_just_released(&"Mouse_L"):
		is_sewing = false
		
	
		
