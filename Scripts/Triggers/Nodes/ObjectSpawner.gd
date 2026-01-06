@icon("res://Sprites/EditorTriggers/SpawnerIco.png")
class_name Spawner 
extends Node2D

func spawn_object(object: PackedScene, objectspawnerpos: SpawnerPos) -> void:
	if object != null:
		if is_instance_valid(object.instantiate()):
			var object_instance = object.instantiate()
			
			#Verify if there is an object and if it is only one.
			if objectspawnerpos.object_is_alive == false and \
			objectspawnerpos.get_child_count() < 2:
				##Trying to fix elem error thing
				if object_instance.get_parent():
					print("object has a parent")
					remove_child(object_instance)
				objectspawnerpos.add_child(object_instance.duplicate())
				print("Spawned object")
