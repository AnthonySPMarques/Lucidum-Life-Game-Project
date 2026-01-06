@tool
class_name DoorManager
extends Node2D

enum DoorMode {Wrapper, SceneChanger}
enum DoorEf {Fade, Follow, Instant}

@export var Door_Mode : DoorMode = DoorMode.Wrapper
@export var Door_Effect : DoorEf = DoorEf.Instant
var SceneDestination : String :
	set(value):
		SceneDestination = value
		notify_property_list_changed() #Notifvy exported var changed

#@export_file("*.tscn") var Scene_Destiny : String

@onready var door_enter_player: AnimationPlayer = $DoorEnter/DoorEnterPlayer
@onready var door_exit_player: AnimationPlayer = $DoorExit/DoorExitPlayer

@onready var Door_enter : Area2D = %DoorEnter
@onready var Door_exit : Area2D = %DoorExit

func _enter_tree() -> void:
	$DoorEnter/Icon.hide()
	$DoorExit/Icon.hide()
	%Liner.hide()
	

func _process(_delta):
	%Liner.set_point_position(0, $DoorEnter/Icon.global_position)
	%Liner.set_point_position(1, $DoorExit/Icon.global_position)
	match Door_Effect:
		DoorEf.Instant:
			pass
	match Door_Mode:
		DoorMode.Wrapper:
			Door_exit.show()
		DoorMode.SceneChanger:
			Door_exit.hide()
	


##Set advanced exported variables
func _get_property_list():
	if Engine.is_editor_hint():
		var def : Array = []
		match Door_Mode:
			DoorMode.SceneChanger:
				def.append({
				"name": &"SceneDestination",
				"type": TYPE_STRING,
				"usaage": PROPERTY_USAGE_DEFAULT,
				"hint": PROPERTY_HINT_RESOURCE_TYPE,
				"hint_string": "PackedScene",
				})
		return def
	
