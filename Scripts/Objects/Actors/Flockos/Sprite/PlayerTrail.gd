extends Line2D

@export var length : int = 30

var can_trail = false

#Delay the ghost creation
var brike = true

var ghost_sprite = preload("res://Scenes/SeparatedVisualEffects/ghoster_sprite_trail.tscn")
var get_arvore

func _ready() -> void:

	show()
	get_arvore = get_tree()
	set_as_top_level(true)
	clear_points()
	
func _physics_process(_delta: float) -> void:
	create_trail()
	
func create_trail() -> void:
	modulate.a = %FlockosSprite.modulate.a
	
	if can_trail:
		add_point(%PivotTrail.global_position)
		
		if points.size() > length:
			remove_point(0)
		create_ghost()
			
	else:
		if points.size() > 0:
			set_point_position(points.size()-1, %PivotTrail.global_position)
			remove_point(0)

func create_ghost():
	
	if can_trail:
		
		if brike == true:
			
			brike = false
			var ghost_ins = ghost_sprite.instantiate()
			
			ghost_ins.texture = %FlockosSprite.texture
			ghost_ins.offset = %FlockosSprite.offset
			ghost_ins.region_enabled = true
			ghost_ins.region_rect = %FlockosSprite.region_rect
			ghost_ins.scale.x = %FlockosSprite.scale.x
			ghost_ins.global_position = %FlockosSprite.global_position + (Vector2(-5 * %FlockosSprite.scale.x, 0))
			ghost_ins.set_as_top_level(true)
			
			%FlockosSprite.call_deferred("add_child", ghost_ins)
			
			##TIMER##
			var timer_caseiro = Timer.new()
			TemporaryNodes.add_child(timer_caseiro)
			timer_caseiro.one_shot = true
			timer_caseiro.start(0.04)
			await timer_caseiro.timeout
			#print("timer_caseiro from ", name ," is finished")
			timer_caseiro.queue_free()
			
			brike = true
	
