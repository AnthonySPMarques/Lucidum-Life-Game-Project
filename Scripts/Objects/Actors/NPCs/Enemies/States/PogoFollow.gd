extends EnemyStateMaker

@export var Pogo_hit_state : EnemyStateMaker

@export var Min_Bounce_Force : float = 600.0
@export var Max_Bounce_Force : float = 1400.0

@export var Time_To_Bounce : float = 2.0

@export_category("Velocity values")
@export var velocity_speed : float = 350.0 ##Velocidade do movimento
@export var acceleration : float = 100.0 ##Força da aceleração de movimento
@export var Gravity_Multiplier : float = 2.0

var bounce_rdom :int= 0

var get_player : Flockos = null

var elec_pogo : PackedScene = preload("res://Scenes/Objects/Actors/NPCs/interactive_non_living_characters/Vehiles/ElecPogo.tscn")

var hit : bool = false

func enter() -> void:
	hit = false
	
	if get_player == null:
		get_player = get_tree().get_nodes_in_group("Player")[0] as Flockos
		
	super()

func physics_process(delta: float) -> EnemyStateMaker:
	
	if hit:
		return Pogo_hit_state
	
	if enemy.is_on_floor():
		bounce_rdom = randi_range(0, 1)
		
		bounce()
	else:
		if enemy.velocity.y < enemy.max_gravity_force:
			enemy.velocity.y += (enemy.gravity_engine * Gravity_Multiplier) * delta
		else:
			enemy.velocity.y = enemy.max_gravity_force
	
	if get_player != null:
		if get_player.global_position.x < enemy.global_position.x:
			%Sprite.scale.x = -1
			Left()
		else:
			%Sprite.scale.x = 1
			Right()
	
	return null
	
func bounce() -> void:
	%SFX_Poing.play()
	Triggers.create_VisualEffectTrigger(17, enemy.global_position)
	if bounce_rdom == 0:
		enemy.velocity.y = -Min_Bounce_Force
	elif bounce_rdom == 1:
		enemy.velocity.y = -Max_Bounce_Force

func Left() -> void:
	enemy.velocity.x = max(enemy.velocity.x - acceleration, -velocity_speed)
	
func Right() -> void:
	enemy.velocity.x = min(enemy.velocity.x + acceleration, velocity_speed)


func _on_enemy_health_is_over() -> void:
	if get_tree().get_nodes_in_group("ElecPogo").size() == 0:
		var Epogo = elec_pogo.instantiate() as ElecPogo
		Epogo.global_position = enemy.global_position
		#enemy.call_deferred("add_sibling", Epogo)
		enemy.get_parent().call_deferred("add_sibling", Epogo)
		

func _on_pogo_doll_enemy_is_hit() -> void:
	hit = true
