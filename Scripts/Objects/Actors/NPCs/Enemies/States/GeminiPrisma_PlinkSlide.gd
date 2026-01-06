extends EnemyStateMaker

enum PrismaSide {Red, Blue}

const CRYSTAL_SPLING_BLUE = preload("res://Sprites/Non Atlas support/CrystalSpling_blue.png")
const CRYSTAL_SPLING_RED = preload("res://Sprites/Non Atlas support/CrystalSpling_Red.png")

@export var Speed : float = 300.0
@export var ImpulseJump : float = 300.0

@export var Current_PrismaSide : PrismaSide

var current_direction = 1

@onready var left_a: RayCast2D = $"../../Raycasts/Left_A"
@onready var left_b: RayCast2D = $"../../Raycasts/Left_B"
@onready var right_a: RayCast2D = $"../../Raycasts/Right_A"
@onready var right_b: RayCast2D = $"../../Raycasts/Right_B"
@onready var crystal_splings: CPUParticles2D = %CrystalSplings_Particles

func enter() -> void:
	#Deactivate particles when enemy spawn into the scene and 
	#then activate later
	if crystal_splings.emitting:
		crystal_splings.emitting = false
		
	match Current_PrismaSide:
		PrismaSide.Red:
			crystal_splings.texture = CRYSTAL_SPLING_RED
			crystal_splings.scale.x = -1
			%AnimationPlayer.play("RedPrisma")
			enemy.global_position.x -= 24
			current_direction = -1
			
		PrismaSide.Blue:
			crystal_splings.texture = CRYSTAL_SPLING_BLUE
			crystal_splings.scale.x = 1
			%AnimationPlayer.play("BluePrisma")
			enemy.global_position.x += 24
			current_direction = 1
			
	enemy.velocity.y = -ImpulseJump
	enemy.velocity.x = Speed*current_direction
			
	super()
	
func process(delta: float) -> EnemyStateMaker:
	
	crystal_splings.emitting = enemy.is_on_floor()
		
	enemy.velocity.x = Speed*current_direction
	
	if !enemy.is_on_floor():
		enemy.velocity.y += enemy.gravity_engine*delta
	else:
		enemy.velocity.y = 0
	
	if (left_a.is_colliding() or left_b.is_colliding()):
		current_direction = 1
		
	elif (right_a.is_colliding() or right_b.is_colliding()):
		current_direction = -1
	
	if enemy.is_on_wall():
		Triggers.create_VisualEffectTrigger(17, enemy.global_position)
	return null
	
