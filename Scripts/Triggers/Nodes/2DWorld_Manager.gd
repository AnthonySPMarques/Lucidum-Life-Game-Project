extends Node2D
class_name World2D_manager

var current_level : LevelLogic

func goto_next_level(scene: String, entrace_mode, exit_id: int, current_phantom_camera: int = 0) -> void:
	
	
	
			
	GlobalEngine.flockos.checkpoint_is_marked = false
	#Add new scene
	
	
	GlobalEngine.GamePlayer.set_Universe2D_scene(scene)
	current_level.CameraManager.update_appends()
	var camera = current_level.CameraManager.Phantoms_Children[current_phantom_camera]
	
	
	current_level.CameraManager.Set_CurrentZone(GlobalEngine.flockos, camera)
	
	camera.set_priority(111)
	
	for ph in current_level.CameraManager.Phantoms_Children:
		ph.set_tween_resource(preload("uid://dubbita2r8n7"))
	
	print("Phantoms_Children[current_phantom_camera] ", current_level.CameraManager.Phantoms_Children[current_phantom_camera])
	
	
	
	@warning_ignore("int_as_enum_without_cast")
	GlobalEngine.flockos.Start_Scene_By = entrace_mode
	GlobalEngine.flockos.current_start_point = current_level.EntracesMarker.get_child(exit_id)
	print("by ",GlobalEngine.flockos.Start_Scene_By, GlobalEngine.flockos.Entering_Scene_Transition.keys()[entrace_mode])
	GlobalEngine.flockos.global_position = current_level.EntracesMarker.get_child(exit_id).global_position
	
	GlobalEngine.flockos.States.change_state(GlobalEngine.flockos.StartState)
	camera.global_position = GlobalEngine.flockos.global_position+Vector2(0,-64)
	
	###And set Flockos current entrace animations
	##Initialize player position and intro animation
	#GlobalEngine.GamePlayer.set_level_entrace(
		#entrace_mode, #To flockos intro mode
		#current_level.EntracesMarker.get_child(exit_id).global_position)
	
	if TransitionFaders.Transition_Animation_Finished.is_connected(goto_next_level):
		TransitionFaders.Transition_Animation_Finished.disconnect(goto_next_level)
		goto_next_level.unbind(goto_next_level.get_argument_count())
	
