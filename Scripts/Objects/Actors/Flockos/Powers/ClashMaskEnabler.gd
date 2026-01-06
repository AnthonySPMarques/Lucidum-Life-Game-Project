class_name ClashAreaNode extends Node2D

func play_attackhit() -> void:
	SoundEffects.play_sound(0)

func enable_clash_areas() -> void:
	
	for Y in get_children():
		for Z in Y.get_children():
			if Z is CollisionShape2D or Z is CollisionPolygon2D:
				#print("collision mask ", Z.name, " has been enabled")
				Z.disabled = false
				
func disable_clash_areas() -> void:
	
	for Y in get_children():
		for Z in Y.get_children():
			if Z is CollisionShape2D or Z is CollisionPolygon2D:
				#print("collision mask ", Z.name, " has been disabled")
				Z.disabled = true
				
