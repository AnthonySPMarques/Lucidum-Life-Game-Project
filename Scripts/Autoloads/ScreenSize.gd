extends Node

var enable_fullscreen = false

func _input(_event: InputEvent) -> void:
	set_physics_process_priority(2)
	
	
	if Input.is_action_just_pressed("ScreenChanger") and !Input.is_action_pressed("Ctrl_Key"):
		enable_fullscreen = !enable_fullscreen
		if enable_fullscreen:
			fullscreen()
		else:
			windowscreen()
		
		
	
func fullscreen() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func windowscreen() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
