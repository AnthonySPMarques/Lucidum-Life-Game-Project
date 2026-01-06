extends Control

var connects

@export var Buttons: Array[NodePath]

#Vaule indicator or return
var adex = 0

#Button_5
@export var Skins: Array[StringName]

@onready var get_player := get_tree().get_nodes_in_group("Player")

var current_skin : int

func _ready() -> void:
	current_skin = 0

	#for Y in Buttons:
		#var turn_index = get_node(Buttons[adex])
		#if turn_index.get_child(0) is TextureButton:
			#
			#turn_index.get_child(0).pressed.connect(turn_index.function_to_call)
		#adex = adex + 1
		
	%SoundEffect_Label.text = "Sound " + str(%Volume_SFXs.value) + "%"
	
	
func _process(_delta: float) -> void:
	
	#Toogle opitions
	$Hacks/Buttons.set("visible", $Hacks.get("button_pressed"))
	#$"%SkinText".text = Skins[current_skin]
	
	if Input.is_action_pressed("Ctrl_Key"):
		%Volume_SFXs.step = 0.05
	else:
		%Volume_SFXs.step = 0.01
	
	#if %Volume_SFXs.drag_started:
		#%SoundEffect_Label.text = "Sound " + str(%Volume_SFXs.value*100) + "%"
		#AudioServer.set_bus_volume_db(2, linear_to_db(%Volume_SFXs.value))
		#AudioServer.set_bus_volume_db(3, linear_to_db(%Volume_SFXs.value))
		#AudioServer.set_bus_volume_db(4, linear_to_db(%Volume_SFXs.value))
		
		
func fill_awaken() -> void:
	if get_player[0] is Flockos:
		var flockos = get_player[0] as Flockos
		flockos.UI.Awaken_Value = flockos.UI.Awaken_Max
func fill_health() -> void:
	if get_player[0] is Flockos:
		var flockos = get_player[0] as Flockos
		flockos.UI.Health_Value = flockos.UI.Health_Max
func hit_player() -> void:
	#Show current function modifier while hide others
	%Spinbox.visible = !%Spinbox.visible 
	%TimeEdit.visible = false
	
	
	var damage = %Spinbox.value
	if int(damage) > 0:
		get_player[0].Hitted = true
		get_player[0].update_health(int(damage) * -1)

func slow_engine() -> void:
	
	#Show current function modifier while hide others
	%TimeEdit.visible = !%TimeEdit.visible 
	%Spinbox.visible = false
	
	
	if $"../../..".Show_Debug_Cheats == true:
		if !%TimeEdit.visible:
			GlobalEngine.ChangingGameSpeed = true
			var time_fps = float(%TimeEdit.value)
			
			if time_fps > 0.000:
				GlobalEngine.change_gamespeed(time_fps, 999.999)
			else:
				printerr("Write a positive value greater than 0")
			
			if time_fps == 1.0:
				GlobalEngine.ChangingGameSpeed = false
				

func _save() -> void:
	#GameSettings.save_data(GlobalDatas.Data, 0)
	print("save_data deactived")
	
func _load() -> void:
	#GameSettings.load_data()
	print("load_data deactived")

func _on_Previous_pressed():
	if current_skin > 0:
		current_skin -= 1
	else:
		current_skin = Skins.size() - 1
	
func _on_Next_pressed():
	if current_skin < Skins.size() - 1:
		current_skin += 1
	else:
		current_skin = 0


func _volume_button_pressed() -> void:
	%Panel.visible = !%Panel.visible
	SoundEffects.play_sound(int($Hacks/Buttons/Button_9/B/Panel/ID.value))
