extends Node
class_name PlayerStateParent

@export var Start_State : StateMaker

var Default_State : StateMaker
var Previous_State : StateMaker

func change_state(new_state: StateMaker) -> void:
	if Default_State:
		###print(Default_State)
		Previous_State = Default_State
		Default_State.exit()
		
		

	Default_State = new_state
	Default_State.enter()
# Initialize the state machine by giving each state a reference to the objects
# owned by the parent that they should be able to take control of
# and set a default state

func init(player: Flockos) -> void:
	for child in get_children():
		child.player = player
	# Initialize with a default state of idle
	change_state(Start_State)

# Pass through functions for the Player to call,
# handling state changes as needed
func physics_process(delta: float) -> void:
	var new_state = Default_State.physics_process(delta)
	if new_state:
		change_state(new_state)
		
	
func input(event: InputEvent) -> void:
	var new_state = Default_State.input(event)
	if new_state:
		change_state(new_state)

func process(delta: float) -> void:
	var new_state = Default_State.process(delta)
	if new_state:
		change_state(new_state)

func go_dash() -> void:
	var new_state = Default_State.go_dash()
	if new_state:
		change_state(new_state)
