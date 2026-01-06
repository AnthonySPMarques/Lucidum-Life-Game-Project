#@tool
class_name LevelLogic extends Node2D


#Set current arc
@export_subgroup("Arc settings")
enum LevelPathsName {LULLABY_BLUE_DIR}
const ARC_DIRECTORIES = {
	LevelPathsName.LULLABY_BLUE_DIR: "res://Scenes/Levels/Arc_LulabbyBlue/"
}
@export var Arc_World : LevelPathsName
@onready var current_arc_world = ARC_DIRECTORIES[Arc_World]

@export_enum("Lullaby Blue - ") var LevelArcName : String = "Lullaby Blue - "

@export_category("Universe Paths")
@export var Nightmare_Level_Path: PackedScene
@export var Normal_Level_Path: PackedScene

@export_category("Others")
@export var enable_fade_transition : bool = true
##Select scene music
@export var CameraManager : CameraZonesManager
@export_enum("none", "Sleep Too!") var Music_to_play = "none"
@export var EntracesMarker : Node2D #Get in this way so array loads already fully


func _ready() -> void:
	
	print("current_arc_world = ", current_arc_world)
	CameraManager.update_appends()
	if EntracesMarker == null:
		printerr("EntracesMarker is null")
		breakpoint
	print(EntracesMarker, " ", name)
	if !self.is_in_group("Level"):
		add_to_group("Level")
	
func _enter_tree() -> void:
	
	##Play song
	if MusicPlayer.is_any_song_playing == false and Music_to_play != "none":
		MusicPlayer.stop_song(Music_to_play)
		MusicPlayer.play_song(Music_to_play)
	
	#gamestarted = true

func restart_level_scene() -> void:
	##Play song
	MusicPlayer.stop_song(Music_to_play)
	MusicPlayer.play_song(Music_to_play)


#When entered nightmare world
func turn_into_nightmare_travel() -> void:
	pass
	
#When returned to normal world
func return_into_normal_travel() -> void:
	pass
