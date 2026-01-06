extends EnemyStateMaker

@export var Gravity : float = 1000.0

#var PrismaPierceB_packedscene : PackedScene = preload("res://Scenes/Objects/Actors/Enemies/PiercedPrisma_Blue.tscn")
#var PrismaPierceR_packedscene : PackedScene = preload("res://Scenes/Objects/Actors/Enemies/PiercedPrisma_Red.tscn")

var PrismaPierce_packedscene : PackedScene = preload("res://Scenes/Objects/Actors/Enemies/PiercedPrisma.tscn")

func enter() -> void:
	super()
	
	
func physics_process(delta: float) -> EnemyStateMaker:
	
	if !enemy.is_on_floor():
		enemy.velocity.y += Gravity*delta
	enemy.move_and_slide()
	return null
	
func process(_delta: float) -> EnemyStateMaker:
	if %Player_Detector.get_overlapping_bodies().size() > 0:
		if %Player_Detector.get_overlapping_bodies()[0] is Flockos:
			
			var PrismaPierce_red = PrismaPierce_packedscene.instantiate()
			var PrismaPierce_blue = PrismaPierce_packedscene.instantiate()
			var get_prisma_state_r = PrismaPierce_red.get_node("EnemyMachine_State/GeminiPrisma_PlinkSlide")
			var get_prisma_state_b = PrismaPierce_blue.get_node("EnemyMachine_State/GeminiPrisma_PlinkSlide")
			
			Triggers.create_VisualEffectTrigger(17, %Pivot.global_position, Vector2(2,2))
			
			PrismaPierce_red.global_position = enemy.global_position
			get_prisma_state_r.Current_PrismaSide = get_prisma_state_r.PrismaSide.Red
			PrismaPierce_red.set_as_top_level(true)
			enemy.call_deferred("add_sibling", PrismaPierce_red)

			PrismaPierce_blue.global_position = enemy.global_position
			get_prisma_state_b.Current_PrismaSide = get_prisma_state_b.PrismaSide.Blue
			PrismaPierce_blue.set_as_top_level(true)
			enemy.call_deferred("add_sibling", PrismaPierce_blue)
			
			enemy.call_deferred("queue_free")
	return null
