extends Node

@export var enable_print : bool = false
var all_actions = InputMap.get_actions()

func _process(_delta: float) -> void:
	if enable_print:
		for action in all_actions:
			if Input.is_action_pressed(action):
				print("Ação pressionada: ", action)
	
