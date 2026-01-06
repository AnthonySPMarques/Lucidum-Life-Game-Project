extends Area2D
class_name Door

enum DoorTexture {Thenlla_House = 1}
enum DoorMode {Enter = 0, Exit = 1}

@export var Door_Texture : DoorTexture = DoorTexture.Thenlla_House
@export var Door_Mode : DoorMode = DoorMode.Enter

@export var AnimationPlayerNode : AnimationPlayer

var Destination : Door = null
var play_mode : String = "ToInside_"

@onready var enter_player_tree: AnimationTree = %EnterPlayerTree
@onready var exit_player_tree: AnimationTree = %ExitPlayerTree

func _ready() -> void:
	
	AnimationPlayerNode.play("DoorClosed_" + str(Door_Texture))
	#get_node("Mostrador" + str(self.name)).screen_entered.connect(show)
	#get_node("Mostrador" + str(self.name)).screen_exited.connect(hide)
	#visible = false
	
	
	match Door_Mode:
		DoorMode.Enter:
			Destination = %DoorExit
		DoorMode.Exit:
			Destination = %DoorEnter

func travel_door_animation(current_door: Door) -> void:
	
	if current_door == %DoorEnter:
		#var delay = Timer.new() ##Create delay to open and close doors.
		#add_child(delay) ##Add timer to scene.
		
		##Set the main enter door to open to inside.
		enter_player_tree.set("parameters/DoorOpenings/Reverse/scale", 2.0)
		enter_player_tree.get("parameters/playback").travel("DoorOpenings")
		enter_player_tree.set("parameters/DoorOpenings/OpenMode/transition_request", "In")
		SoundEffects.play_sound(SoundEffects.SFX_OPENINGDOOR)
		
		##Start timer delay to make the destination door play the paralel animation from
		##the enter door, in that case, play door opening to outside.
		##TIMER##
		var timer_caseiro = Timer.new()
		TemporaryNodes.add_child(timer_caseiro)
		timer_caseiro.one_shot = true
		timer_caseiro.start(0.9)
		await timer_caseiro.timeout
		print("timer_caseiro from ", name ," is finished")
		timer_caseiro.queue_free()
		
		##Set the destination door to open to outside.
		exit_player_tree.set("parameters/DoorOpenings/Reverse/scale", 2.0)
		exit_player_tree.get("parameters/playback").travel("DoorOpenings")
		exit_player_tree.set("parameters/DoorOpenings/OpenMode/transition_request", "Out")
		
		##Reverse enter door playback speed.
		enter_player_tree.set("parameters/DoorOpenings/Reverse/scale", -2.0)
		
		##Shut one more time the delay and then,
		##reverse exit door playback speed.
		##TIMER##
		TemporaryNodes.add_child(timer_caseiro)
		timer_caseiro.one_shot = true
		timer_caseiro.start(1.0)
		await timer_caseiro.timeout
		print("timer_caseiro from ", name ," is finished")
		timer_caseiro.queue_free()
		
		##Right here.
		exit_player_tree.set("parameters/DoorOpenings/Reverse/scale", -2.0)
		
		##TIMER##
		TemporaryNodes.add_child(timer_caseiro)
		timer_caseiro.one_shot = true
		timer_caseiro.start(0.7)
		await timer_caseiro.timeout
		print("timer_caseiro from ", name ," is finished")
		timer_caseiro.queue_free()
		
		SoundEffects.play_sound(SoundEffects.SFX_CLOSINGDOOR)
		
	##The same for the elif statement but in reverse.
	elif current_door == %DoorExit:

		exit_player_tree.set("parameters/DoorOpenings/Reverse/scale", 2.0)
		exit_player_tree.get("parameters/playback").travel("DoorOpenings")
		exit_player_tree.set("parameters/DoorOpenings/OpenMode/transition_request", "In")
		SoundEffects.play_sound(SoundEffects.SFX_OPENINGDOOR)
		
		##TIMER##
		var timer_caseiro = Timer.new()
		TemporaryNodes.add_child(timer_caseiro)
		timer_caseiro.one_shot = true
		timer_caseiro.start(0.9)
		await timer_caseiro.timeout
		print("timer_caseiro from ", name ," is finished")
		timer_caseiro.queue_free()
		
		enter_player_tree.set("parameters/DoorOpenings/Reverse/scale", 2.0)
		enter_player_tree.get("parameters/playback").travel("DoorOpenings")
		enter_player_tree.set("parameters/DoorOpenings/OpenMode/transition_request", "Out")

		exit_player_tree.set("parameters/DoorOpenings/Reverse/scale", -2.0)
		
		##TIMER##
		TemporaryNodes.add_child(timer_caseiro)
		timer_caseiro.one_shot = true
		timer_caseiro.start(1.0)
		await timer_caseiro.timeout
		print("timer_caseiro from ", name ," is finished")
		timer_caseiro.queue_free()
		
		enter_player_tree.set("parameters/DoorOpenings/Reverse/scale", -2.0)
		
		##TIMER##
		TemporaryNodes.add_child(timer_caseiro)
		timer_caseiro.one_shot = true
		timer_caseiro.start(0.7)
		await timer_caseiro.timeout
		print("timer_caseiro from ", name ," is finished")
		timer_caseiro.queue_free()
		
		SoundEffects.play_sound(SoundEffects.SFX_CLOSINGDOOR)
	
