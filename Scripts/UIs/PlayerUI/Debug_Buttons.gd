extends Control

#@export var function_to_call : StringName
var button : TextureButton

func _ready() -> void:
	button = get_child(0)

func _process(_delta: float) -> void:
	
	if button.is_hovered() and !button.button_pressed:
		button.modulate = Color(2, 2, 2)
		
	elif button.button_pressed:
		button.modulate = Color(0.6, 0.6, 0.6)
	else:
		button.modulate = Color(1, 1, 1)
	
