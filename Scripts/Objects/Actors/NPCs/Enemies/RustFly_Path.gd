extends Node2D

func _start_path() -> void:
	%Pather.play("Travel_2_End")
	
func _back_path() -> void:
	%Pather.play("Travel_Back")
	
