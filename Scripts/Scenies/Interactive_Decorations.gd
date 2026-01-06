extends AnimatedSprite2D
class_name Scenies

const Particle_Leaves = preload("res://Scenes/Triggers/FXs/Particles/10.tscn")
const BURNING_SPRAY = preload("res://tres/Materials/BurningSpray.tres")

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Slashbite_Area"):
		Triggers.create_ParticleTrigger(Particle_Leaves, global_position)
		Triggers.create_VisualEffectTrigger(15, global_position, Vector2(0.8,0.8))
		queue_free()


func _on_visible_on_screen_enabler_2d_screen_entered() -> void:
	if !$Area2D.is_connected("area_entered", _on_area_2d_area_entered):
		$Area2D.area_entered.connect(_on_area_2d_area_entered)
func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	if $Area2D.is_connected("area_entered", _on_area_2d_area_entered):
		$Area2D.area_entered.disconnect(_on_area_2d_area_entered)
