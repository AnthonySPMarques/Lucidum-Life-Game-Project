extends Node

@export
var Body : CharacterBody2D

@export
var Vertical_Impulse : float = 128.0

@export
var Gravity_Multiplier : float = 1.1 

var gravity_engine : float = ProjectSettings.get_setting("physics/2d/default_gravity")
var x_destiny : float = 0
var target : Node2D


func set_target(target_node: Node2D) -> void:
	target = target_node
	shoot(target.global_position)
			
func _physics_process(delta: float) -> void:
	Body.velocity.y += (gravity_engine*Gravity_Multiplier) * delta

#func get_arc_range(main_pos: Vector2, destination_pos: Vector2, height: float, current_gravity : float) -> Vector2:
	#var distance : Vector2 = destination_pos.round() - main_pos.round()
	#print("[Trajectory_Behavior.gd] get_arc_range - distance: " ,distance)
	#
	#if distance.y > height and (distance.x != 0 and distance.y != 0 and height != 0):
		#
		#print("[Trajectory_Behavior.gd] get_arc_range - height: " ,height)
		#
		#var up = -sqrt(2* height/ current_gravity)
		#var down = sqrt(2* (distance.y - height)/ current_gravity)
		#
		#print("[Trajectory_Behavior.gd] up : ", up)
		#print("[Trajectory_Behavior.gd] down : ", down)
		#
		#Body.velocity.x = distance.x / (-up + down)
		#Body.velocity.y = -sqrt(-2 * current_gravity * height)
		#print("[Trajectory_Behavior.gd] Body.velocity : ", Body.velocity)
		#return Body.velocity
	#return Vector2.ONE

func get_arc_range(main_pos: Vector2, destination_pos: Vector2, height: float, current_gravity : float) -> Vector2:
	var distance : Vector2 = destination_pos - main_pos
	##Increase Y arc trajectory depending of player's Y pos
	var default_arc = Vector2(distance.x/1.5, -Vertical_Impulse - destination_pos.y)
	
	if current_gravity == 0:
		push_error("Gravidade não pode ser zero.")
		return default_arc
	
	if distance.y > height:
		var up_factor = -2.0 * height / current_gravity
		var down_factor = 2.0 * (distance.y - height) / current_gravity
		print("up_factor: ", up_factor, " down_factor: ", down_factor)
		if up_factor < 0 or down_factor < 0:
			
			print("Fatores inválidos para raiz quadrada. Então o valor padrão será retornado")
			print("Fup_factor: ", up_factor, " Fdown_factor: ", down_factor)
			return default_arc
		
		var up = sqrt(up_factor)
		var down = sqrt(down_factor)
		
		var total_time = up + down
		if total_time == 0:
			printerr("Tempo total de voo é zero. Então o valor padrão será retornado")
			return default_arc
		
		var velocity_x = distance.x / total_time
		var velocity_y = -sqrt(-2.0 * current_gravity * height)
		
		if is_nan(velocity_x) or is_nan(velocity_y):
			push_error("Velocidade resultou em NaN. Então o valor padrão será retornado")
			return default_arc

		Body.velocity = Vector2(velocity_x, velocity_y)
	else:
		push_warning("Distância vertical muito baixa para o arco desejado. Então o valor padrão será retornado")
		Body.velocity = default_arc

	return Body.velocity


func shoot(destination_pos: Vector2) -> void:
	#var arc_height = max(40, abs(destination_pos.y - Body.global_position.y) * 0.5)
	var height = destination_pos.y - Body.global_position.y - Vertical_Impulse
	
	#print("[Trajectory_Behavior.gd] arc_height : ", arc_height)
	print("[Trajectory_Behavior.gd] height : ", height)
	print("[Trajectory_Behavior.gd] destination_pos.y : ", destination_pos.y)
	print("[Trajectory_Behavior.gd] Body.global_position.y : ", Body.global_position.y)
	print("[Trajectory_Behavior.gd] ", name," arc range is " ,get_arc_range(Body.global_position, destination_pos, height,
	gravity_engine*Gravity_Multiplier))
	
	Body.velocity = get_arc_range(Body.global_position, destination_pos, height,
	gravity_engine*Gravity_Multiplier)
	
