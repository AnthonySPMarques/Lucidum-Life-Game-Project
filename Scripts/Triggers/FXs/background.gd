extends Node
class_name Background

@export var offset: Vector2 = Vector2.ZERO
@export var CurrentBackground : PackedScene :
	set = change_background


func change_background(background_packedscene: PackedScene) -> void:
	var background_scene = background_packedscene.instantiate()
	
	if get_child_count() > 0:
		if get_child(0).name != background_scene.name:
			for Y in get_children():
				Y.queue_free()
			print("removed previous bg")
	background_scene.get_child(0).position += offset
	add_child(background_scene)
	
