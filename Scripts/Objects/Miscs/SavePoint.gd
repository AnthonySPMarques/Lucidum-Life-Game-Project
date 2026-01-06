extends Node2D


const SAVE_FILE = "FlockosData"
const FORMAT = ".json"
@onready var area_2d: Area2D = $Area2D

var player_is_inside = false
var get_player : Flockos

var pa = 0

var data_path = DataManager.SAVE_PATH + SAVE_FILE + FORMAT

func _process(_delta: float) -> void:
	if player_is_inside:
		if Input.is_action_just_pressed("Down"):
			if get_player != null:
				get_player.save_self_data()
				pa += 1
				DataManager.save_data(data_path, get_player.Data)
			prints("Saved as", DataManager.SAVE_PATH + SAVE_FILE)
			return
		if Input.is_action_just_pressed("Up"):
			if get_player != null and FileAccess.file_exists(DataManager.SAVE_PATH + SAVE_FILE + FORMAT):
				get_player.load_self_data()
				DataManager.load_data(data_path)
			prints("Loaded as", DataManager.SAVE_PATH + SAVE_FILE + FORMAT)
			return
		
func player_recevied(body: Node2D) -> void:
	if body is Flockos:
		get_player = body
		player_is_inside = true
		
func player_out(body: Node2D) -> void:
	if body is Flockos:
		get_player = null
		player_is_inside = false
