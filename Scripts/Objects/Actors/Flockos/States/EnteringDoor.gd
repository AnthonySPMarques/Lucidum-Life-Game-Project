extends StateMaker

var animation_finished = false

signal goto_destination
var TimerToDestination

func enter() -> void:
	super()
	%Hitbox.disable_hitboxes()
	
	"Setters"
	player.AnimationTraveler.set("parameters/Is_On_Floor/current", 
	0)
	player.AnimationTraveler.set("parameters/Is_Interating_Door/current", 
	0)
	player.AnimationTraveler.set("parameters/Is_On_Door/current", 
	0)
	
	player.hide_indicator()
	
	if is_instance_valid(player.door_instance):
		player.global_position.x = player.door_instance.global_position.x
		player.door_instance.travel_door_animation(player.door_instance)
		
		#player.door_instance.open_door()
		
	pass

func exit() -> void:
	animation_finished = false

func process(_delta: float) -> StateMaker:

	if animation_finished:
		goto_destination.emit()
		return player.ExitingDoorState
	
	return null

func set_animation_finished() -> void:
	animation_finished = true
