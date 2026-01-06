extends Node
class_name CutsceneVideoPlayer

signal cutscene_finished

@export var Video2Play_Path : VideoStream
@onready var video_player: VideoStreamPlayer = %VideoPlayer

func _ready() -> void:
	#video_player.hide()
	video_player.finished.connect(anim_ended)
	
func anim_ended() -> void:
	if not cutscene_finished.is_connected(stop_video):
		cutscene_finished.connect(stop_video)
	cutscene_finished.emit()

func play_video() -> void:
	print("called to play vid")
	if Video2Play_Path != null:
		print("Video playing")
		video_player.show()
		video_player.stream = Video2Play_Path
		video_player.play()
	else:
		push_error("Video not found, path is null.")
		
func stop_video() -> void:
	video_player.stop()
	video_player.hide()
