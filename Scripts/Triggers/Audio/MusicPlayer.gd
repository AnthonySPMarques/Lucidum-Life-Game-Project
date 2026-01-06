@icon("res://Sprites/EditorTriggers/MusicPlayer.png")
extends Node
var is_any_song_playing : bool = false


func play_song(songname: String)->void:
	##Returns script to not execute any song if songname is "none"
	if songname == "none":
		is_any_song_playing = false
		return
	
	var Song = get_node(songname) as AudioStreamPlayer
	if Song.get_child_count() == 1:
		var intro_song = Song.get_child(0) as AudioStreamPlayer
		intro_song.play()
		await intro_song.finished
		intro_song.stop()
		Song.play()
	is_any_song_playing = true


func stop_song(songname: String)->void:
	##Returns script to not execute any song if songname is "none"
	if songname == "none":
		return
		
	var Song = get_node(songname) as AudioStreamPlayer
	if Song.get_child_count() == 1:
		var intro_song = Song.get_child(0) as AudioStreamPlayer
		intro_song.stop()
		Song.stop()
	is_any_song_playing = false
		
func stop_ALL_songs() -> void:
	
	for SONG in get_children():
		if SONG is AudioStreamPlayer:
			SONG.stop()
			if SONG.get_child_count() != 0:
				if SONG.get_child(0) is AudioStreamPlayer:
					SONG.get_child(0).stop()
	is_any_song_playing = false
