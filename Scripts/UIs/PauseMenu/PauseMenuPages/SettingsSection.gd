extends Control

var master_bus_channel: int
var music_bus_channel: int
var soundeffect_bus_channel: int

@export var parent_pause : MenuPause

@onready var volume_slider_master: HSlider = %VolumeSlider_Master
@onready var volume_slider_music: HSlider = %VolumeSlider_Music
@onready var volume_slider_sound: HSlider = %VolumeSlider_Sound
@onready var back_button: Button = $VBoxContainer/Button/BackButton

func _ready() -> void:
	hide()
	
	master_bus_channel = AudioServer.get_bus_index(&"Master")
	music_bus_channel = AudioServer.get_bus_index(&"BGM")
	soundeffect_bus_channel = AudioServer.get_bus_index(&"SFXs")
	
	
		
	######CONNECTS
	##BACK BUTTON
	if not back_button.pressed.is_connected(backbutton):
		back_button.pressed.connect(backbutton)
	##MASTER
	if not volume_slider_master.value_changed.is_connected(Master_volume_change):
		volume_slider_master.value_changed.connect(Master_volume_change)
	##MUSIC
	if not volume_slider_music.value_changed.is_connected(Music_volume_change):
		volume_slider_music.value_changed.connect(Music_volume_change)
	##SOUND
	if not volume_slider_sound.value_changed.is_connected(Sound_volume_change):
		volume_slider_sound.value_changed.connect(Sound_volume_change)
	######CONNECTS END
	
	
	volume_slider_master.value = db_to_linear(
		AudioServer.get_bus_volume_db(master_bus_channel))
	volume_slider_music.value = db_to_linear(
		AudioServer.get_bus_volume_db(music_bus_channel))
	volume_slider_sound.value = db_to_linear(
		AudioServer.get_bus_volume_db(soundeffect_bus_channel))
	
	
func backbutton() -> void:
	parent_pause.change_section(parent_pause.vbox_placeholder, self)
	
func Master_volume_change(value: float) -> void:
	AudioServer.set_bus_volume_db(master_bus_channel, linear_to_db(value))
	print("[SettingsSection.gd] master volume = ",db_to_linear(AudioServer.get_bus_volume_db(master_bus_channel)))

func Music_volume_change(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus_channel, linear_to_db(value))
	print("[SettingsSection.gd] music volume = ",db_to_linear(AudioServer.get_bus_volume_db(music_bus_channel)))

func Sound_volume_change(value: float) -> void:
	AudioServer.set_bus_volume_db(soundeffect_bus_channel, linear_to_db(value))
	print("[SettingsSection.gd] sound volume = ",db_to_linear(AudioServer.get_bus_volume_db(soundeffect_bus_channel)))
	
