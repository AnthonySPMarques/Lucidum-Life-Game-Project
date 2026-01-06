extends Node
class_name GamePlayerManager

@export_group("Scenes")
@export_file("*.tscn") var First_Scene : String

@export var Universe_2D_Trigger : World2D_manager
@export var Universe_3D_Trigger : Node3D
@export var GUI_Trigger: Control

##Children of each trigger exported var
var current_Scene2D : Node2D
var current_Scene3D : Node3D
var current_GUI : Control

func _enter_tree() -> void:
	GlobalEngine.GamePlayer = self
	
	if First_Scene != null:
		set_Universe2D_scene(First_Scene)
	else:
		printerr("There is no first scene setted")
		breakpoint
func set_GUI_scene(new_scene:String, delete:bool=true,
keep_run:bool=false) -> void:
	if current_GUI != null:
		if delete == true:
			if is_instance_valid(current_GUI):
				current_GUI.call_deferred("queue_free") #Delete forever
		elif keep_run == true:
			current_GUI.hide() #Only disable node but doesn't delete
		else:
			if GUI_Trigger.has_node(current_GUI.get_path()):
				GUI_Trigger.remove_child(current_GUI) #Delete but keep data
	
	var new_current = load(new_scene).instantiate()
	GUI_Trigger.call_deferred("add_child", new_current)
	current_GUI = new_current
	
	print("The current scene typed as GUI is %s" % current_GUI.name)
	
	
func set_Universe2D_scene(new_scene: String, delete:bool=true,
keep_run:bool=false) -> void:
	
	if current_Scene2D != null:
		if delete == true:
			if is_instance_valid(current_Scene2D):
				current_Scene2D.call_deferred("queue_free") #Delete forever
		elif keep_run == true:
			if is_instance_valid(current_Scene2D):
				current_Scene2D.hide() #Only disable node but doesn't delete
		else:
			#if GUI_Trigger.has_node(current_Scene2D.get_path()):
			if is_instance_valid(current_Scene2D):
				Universe_2D_Trigger.remove_child(current_Scene2D) #Delete but keep data

	var new_current = load(new_scene).instantiate()
	new_current.global_position = Vector2.ZERO
	Universe_2D_Trigger.call_deferred("add_child" , new_current)
	current_Scene2D = new_current
	Universe_2D_Trigger.current_level = current_Scene2D
	
	print("The current scene typed as Scene2D is %s" % current_Scene2D.name)
	
