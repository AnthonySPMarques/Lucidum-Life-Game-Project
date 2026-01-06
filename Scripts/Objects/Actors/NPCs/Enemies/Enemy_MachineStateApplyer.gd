extends Node

@export var Start_State : EnemyStateMaker

var Default_State : EnemyStateMaker
var Previous_State : EnemyStateMaker

func change_state(new_state: EnemyStateMaker) -> void:
	if Default_State:
		Default_State.exit()
		Previous_State = Default_State
		

	Default_State = new_state
	Default_State.enter()
	
# Initialize the state machine by giving each state a reference to the objects
# owned by the parent that they should be able to take control of
# and set a default state
func init(enemy: EnemyObject) -> void:
	for child in get_children():
		child.enemy = enemy
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
