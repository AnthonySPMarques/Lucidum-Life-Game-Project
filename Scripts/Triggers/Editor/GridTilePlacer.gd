extends ColorRect

func _process(_delta: float) -> void:
	global_position = snapped(get_global_mouse_position()-Vector2(32, 32), Vector2(64, 64))
