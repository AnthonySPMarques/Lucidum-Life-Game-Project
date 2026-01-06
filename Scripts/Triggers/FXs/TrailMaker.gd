@icon("res://Sprites/Editor Triggers/TrailMaker.png")
class_name Trail2DMaker extends Line2D

@export
var has_line_trail : bool = true
@export
var has_ghost_trail : bool = false
@export 
var length : int
@export
var sprite2D : Sprite2D
@export
var trail_pivot : Node2D
@export 
var ghost_sprite : PackedScene

var can_trail : bool = true
#Delay the ghost creation
var brike : bool = true

var get_arvore = null

func _ready() -> void:

	show()
	get_arvore = get_tree()
	set_as_top_level(true)
	clear_points()
	
func _physics_process(_delta: float) -> void:
	if has_line_trail == true:
		create_trail()
	
func create_trail() -> void:
	modulate.a = sprite2D.modulate.a
	
	if can_trail:
		add_point(trail_pivot.global_position)
		
		if points.size() >= length:
			remove_point(0)
		if has_ghost_trail:
			create_ghost()
			
	else:
		if points.size() > 0:
			set_point_position(points.size()-1, trail_pivot.global_position)
			remove_point(0)

func create_ghost():
	
	if ghost_sprite != null:
		if can_trail:
			if brike == true:
				
				brike = false
				var ghost_ins = ghost_sprite.instantiate()
				
				ghost_ins.texture = sprite2D.texture
				ghost_ins.offset = sprite2D.offset
				ghost_ins.region_enabled = true
				ghost_ins.region_rect = sprite2D.region_rect
				ghost_ins.scale.x = sprite2D.scale.x
				ghost_ins.global_position = sprite2D.global_position
				ghost_ins.set_as_top_level(true)
				
				sprite2D.add_child(ghost_ins)
				##TIMER##
				var timer_caseiro = Timer.new()
				TemporaryNodes.add_child(timer_caseiro)
				timer_caseiro.one_shot = true
				timer_caseiro.start(0.05)
				await timer_caseiro.timeout
				print("timer_caseiro from ", name ," is finished")
				timer_caseiro.queue_free()
				brike = true
	
